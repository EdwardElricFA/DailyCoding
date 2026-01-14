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
    static var appleStore: Self {
        Self(
            center: CLLocationCoordinate2D(latitude: 30.2542, longitude: 120.1634),
            latitudinalMeters: 250000,
            longitudinalMeters: 250000
        )
    }
}
