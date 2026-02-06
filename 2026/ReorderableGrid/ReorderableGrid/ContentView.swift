//
//  ContentView.swift
//  ReorderableGrid
//
//  Created by EdwardElric on 2026/2/6.
//

import SwiftUI

struct Item: Identifiable, SortableGridProtocol {
    var id: String = UUID().uuidString
    var color: Color
    var position: CGRect = .zero
}

struct ContentView: View {
    @State private var items: [Item] = [
        .init(color: .red),
        .init(color: .blue),
        .init(color: .green),
        .init(color: .orange),
        .init(color: .yellow),
        .init(color: .purple)
    ]
    
    
    var body: some View {
        SortableGridView(config: .init(), items: $items) { item in
            ItemView(item)
        } draggingPreview: { previewItem in
            ItemView(previewItem)
        } onDraggingChange: { location, offset, isDragging in
            
        }
        .padding(15)

    }
    
    @ViewBuilder
    func ItemView(_ item: Item) -> some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(item.color.gradient)
            .frame(height: 150)
        
    }
}

#Preview {
    ContentView()
}
