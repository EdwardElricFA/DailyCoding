//
//  MKCoordinateRegion+Extension.swift
//  InteractiveMapCarousel
//
//  Created by EdwardElric on 2026/1/3.
//

import SwiftUI
import MapKit

extension MKCoordinateRegion {
    /// Acts as user current location
    static var applePark: Self {
        Self(
            center: CLLocationCoordinate2D(latitude: 37.3346, longitude: -122.0090),
            latitudinalMeters: 250000,
            longitudinalMeters: 250000
        )
    }
}
