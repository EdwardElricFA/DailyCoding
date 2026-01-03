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
    var body: some View {
        NavigationStack {
            Map(position: $cameraPosition)
                .navigationTitle("Nearby Places")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        if #available(iOS 26, *) {
                            Button(role: .close) {
                                
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
    }
}

#Preview {
    CustomMapView(
        userRegion: .applePark,
        userCoordinates: MKCoordinateRegion.applePark.center,
        lookupText: "Starbucks"
    )
}
