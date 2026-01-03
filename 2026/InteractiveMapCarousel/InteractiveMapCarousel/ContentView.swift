//
//  ContentView.swift
//  InteractiveMapCarousel
//
//  Created by EdwardElric on 2026/1/3.
//

import SwiftUI

struct ContentView: View {
    @State private var showView: Bool = false
    var body: some View {
        NavigationStack {
            List {
                Button("Show View") {
                    showView.toggle()
                }
            }
            .navigationTitle("Map Carousel")
        }
        .fullScreenCover(isPresented: $showView) {
           // CustomMapView()
        }
    }
}

#Preview {
    ContentView()
}
