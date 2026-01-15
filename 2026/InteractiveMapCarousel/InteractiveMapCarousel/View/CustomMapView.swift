//
//  CustomMapView.swift
//  InteractiveMapCarousel
//
//  Created by EdwardElric on 2026/1/3.
//

import SwiftUI
import MapKit

struct CustomMapView: View {
    var userRegion: MKCoordinateRegion
    var userCoordinates: CLLocationCoordinate2D
    var lookupText: String
    var limit: Int
    init(userRegion: MKCoordinateRegion, userCoordinates: CLLocationCoordinate2D, lookupText: String, limit: Int = 10) {
        self.userRegion = userRegion
        self.userCoordinates = userCoordinates
        self.lookupText = lookupText
        self.limit = limit
        self._cameraPosition = .init(initialValue: .region(userRegion))
    }
    /// View Properties
    /// For Animated Camera Updates
    @State private var cameraPosition: MapCameraPosition
    @State private var places: [Place] = []
    @State private var selectedPlaceID: UUID?
    @State private var expandedItem: Place?
    /// Enviroment Properties
    @Namespace private var animationID
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            Map(position: $cameraPosition) {
                ForEach(places) { place in
                    Annotation(place.name, coordinate: place.coordinates) {
                        AnnotationView(place)
                    }
                }
            }
                /// Overlaying a Dark Background until the places is being fetched!
                .overlay {
                    LoadingOverlay()
                }
                /// Bottom Carousel using SafeAreaInset, so that the Map Legal Link will be visible!
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    GeometryReader {
                        let size = $0.size
                        
                        BottomCarousel(size)
                        
                        /// Placeholder Card, until the place is loading up!
                        if places.isEmpty {
                            BottomCarouselCardView(nil)
                                .padding(.horizontal, 15)
                                .frame(width: size.width, height: size.height)
                        }
                    }
                    .frame(height: 200)
                }
                .navigationTitle("Nearby Places")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        if #available(iOS 26, *) {
                            Button(role: .close) {
                                dismiss()
                            }
                        } else {
                            Button {
                                
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(Color.primary)
                            }
                            
                        }
                    }
                }
        }
        .sheet(item: $expandedItem) { place in
            DetailView(place: place)
                .navigationTransition(.zoom(sourceID: place.id, in: animationID))
        }
        .onAppear {
            guard places.isEmpty else { return }
            fetchPlaces()
        }
    }
    
    @ViewBuilder
    private func LoadingOverlay() -> some View {
        Rectangle()
            .fill(.black.opacity(places.isEmpty ? 0.35 : 0))
    }
    
    @ViewBuilder
    func BottomCarousel(_ size: CGSize) -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(places) { place in
                    BottomCarouselCardView(place)
                        .padding(.horizontal, 15)
                        .frame(width: size.width, height: size.height)
                        .matchedTransitionSource(id: place.id, in: animationID)
                }
            }
            .scrollTargetLayout()
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $selectedPlaceID, anchor: .center)
        .onChange(of: selectedPlaceID) { oldValue, newValue in
            guard let coordinates = places.first(where: { $0.id == newValue })?.coordinates else {
                return
            }
            
            withAnimation(animation) {
                cameraPosition = .camera(.init(centerCoordinate: coordinates, distance: 25000))
            }
        }
    }
    
    @ViewBuilder
    func BottomCarouselCardView(_ place: Place?) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let place {
                Text(place.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                Text(place.address)
                    .lineLimit(2)
                if let phoneNumber = place.phoneNumber, let url = URL(string: "tel:\(phoneNumber)") {
                    Link("Phone Number: **\(phoneNumber)**", destination: url)
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
                
                Spacer(minLength: 0)
                
                Button {
                    expandedItem = place
                } label: {
                    Text("Learn More")
                        .frame(maxWidth: .infinity)
                        .fontWeight(.semibold)
                        .padding(.vertical, 4)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .buttonBorderShape(.capsule)
            } else {
                /// Placeholder card
                Group {
                    Text("CoffeeShop Name")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Some random address here, for a placeholder reason")
                        .lineLimit(2)
                    
                    Text("Telephone Number Here")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    
                    Spacer(minLength: 0)
                    
                    Button {
                        
                    } label: {
                        Text("Learn More")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                            .padding(.vertical, 4)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .buttonBorderShape(.capsule)
                }
                .disabled(true)
                .redacted(reason: .placeholder)
            }
        }
        .padding(15)
        /// Applying Glass Effect
        .optionalGlassEffect(colorScheme)
    }
    
    @ViewBuilder
    func AnnotationView(_ place:Place) -> some View {
        let isSelected = place.id == selectedPlaceID
        
        Image(.logo)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: isSelected ? 50 : 20, height: isSelected ? 50 : 20)
            .background {
                Circle()
                    .fill(.white)
                    .padding(-1)
            }
            .animation(animation, value: isSelected)
            .background {
                if isSelected {
                    PulseRingView(tint: colorScheme == .dark ? .white : .orange, size: 80)
                }
            }
            .contentShape(.rect)
            .onTapGesture {
                withAnimation(animation) {
                    selectedPlaceID = place.id
                }
            }
    }
    /// Fetching Lookup Places
    private func fetchPlaces() {
        Task {
            let request = MKLocalSearch.Request()
            request.region = userRegion
            request.naturalLanguageQuery = lookupText
            
            let search = MKLocalSearch(request: request)
            if let items = try? await search.start().mapItems {
                /// print(items)
                try? await Task.sleep(for: .seconds(0.5))
                /// Converting mapItems into Places
                let places = items.compactMap { item in
                    let name = item.name ?? "Unknown"
                    var coordinates: CLLocationCoordinate2D
                    if #available(iOS 26, *) {
                        coordinates = item.location.coordinate
                    } else {
                        coordinates = item.placemark.coordinate
                    }
                    
                    return Place(name: name, coordinates: coordinates, mapItem: item)
                }.prefix(limit).compactMap({ $0 })
                
                /// Animating Map Items
                withAnimation(animation) {
                    self.places = places
                    /// first place as active item
                    self.selectedPlaceID = places.first?.id
                }
            }
        }
    }
    
    var animation: Animation {
        .smooth(duration: 0.45, extraBounce: 0)
    }
}

struct DetailView: View {
    var place: Place
    var body: some View {
        Text("This is a detail view!")
            .presentationDetents([.medium])
    }
}

#Preview {
    CustomMapView(
        userRegion: .appleStore,
        userCoordinates: MKCoordinateRegion.appleStore.center,
        lookupText: "星巴克",
        limit: 5
    )
}
