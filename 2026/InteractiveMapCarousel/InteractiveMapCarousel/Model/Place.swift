//
//  Place.swift
//  InteractiveMapCarousel
//
//  Created by EdwardElric on 2026/1/3.
//

import SwiftUI
import MapKit

struct Place: Identifiable {
    var id: UUID = .init()
    var name: String
    var coordinate: CLLocationCoordinate2D
    var mapItem: MKMapItem
}
