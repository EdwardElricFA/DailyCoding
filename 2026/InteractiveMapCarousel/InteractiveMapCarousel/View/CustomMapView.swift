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
    /// Enviroment Properties
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            Map(position: $cameraPosition)
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
                                    .font(.largeTitle)
                                    .foregroundStyle(Color.primary)
                            }
                            
                        }
                    }
                }
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
                }
            }
            .scrollTargetLayout()
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
        .scrollTargetBehavior(.paging)
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
                    .disabled(true)
                }
                .redacted(reason: .placeholder)
            }
        }
        .padding(15)
        /// Applying Glass Effect
        .optionalGlassEffect(colorScheme)
    }
    /// Fetching Lookup Places
    private func fetchPlaces() {
        Task {
            let request = MKLocalSearch.Request()
            request.region = userRegion
            request.naturalLanguageQuery = lookupText
            
            let search = MKLocalSearch(request: request)
            if let items = try? await search.start().mapItems {
                    print(items)
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
                }
            }
        }
    }
    
    var animation: Animation {
        .smooth(duration: 0.45, extraBounce: 0)
    }
}

#Preview {
    CustomMapView(
        userRegion: .appleStore,
        userCoordinates: MKCoordinateRegion.appleStore.center,
        lookupText: "星巴克",
        limit: 3
    )
}
