//
//  SortableGridView.swift
//  ReorderableGrid
//
//  Created by EdwardElric on 2026/2/6.
//

import SwiftUI


///因为在拖拽过程中要对各个元素进行排序，我们必须先知道每个元素的位置，才能与当前正在拖拽的元素进行比较；如果某个元素的位置落在它们之间，那么我们就可以让它们彼此交换位置。正因为如此，实现一个自定义协议，用来通过 onGeometryChange 修饰符保存元素的当前位置。
protocol SortableGridProtocol: Identifiable {
    var position: CGRect { get set }
}

struct SortableGridView<Content: View, DraggingPreview: View, Data: RandomAccessCollection>: View where Data.Element: SortableGridProtocol, Data: MutableCollection {
    var config: SortableGridConfig
    @Binding var items: Data
    @ViewBuilder var content: (Data.Element) -> Content /// 内容视图
    @ViewBuilder var draggingPreview: (Data.Element) -> DraggingPreview /// 拖拽预览视图
    var onDraggingChange: (_ location: CGPoint, _ offset: CGSize, _ isDragging: Bool) -> ()
    /// View Propertites
    @State private var isDragging: Bool = false
    @State private var draggingItem : Data.Element?
    @State private var draggingStartRect: CGRect?
    @State private var draggingOffset: CGSize = .zero
    var body: some View {
        let columns: [GridItem] = Array(repeating: GridItem(spacing: config.spacing), count: config.count)
        LazyVGrid(columns: columns, spacing: config.spacing) {
            ForEach($items) { $item in
                content(item)
                    .opacity(draggingItem?.id == item.id ? 0 : 1)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onGeometryChange(for: CGRect.self) {
                        $0.frame(in: .named("SORTABLEGRID"))
                    } action: { newValue in
                        item.position = newValue
                    }
                ///使用原生的 SwiftUI 手势在交互过程中会破坏其他手势的行为，尤其是 ScrollView。为了解决这个问题，我使用了 UIKit 的 UILongPressGestureRecognizer 来识别按住、位移以及触摸位置。这样就可以根据这些信息对各个元素进行相互排序。
                    .gesture(
                        CustomLongPressGesture(onChanged: { location, offset in
                            /// if开始状态
                            if draggingItem == nil { ///触发中
                                draggingItem = item
                                draggingStartRect = item.position
                                isDragging = true
                            }
                            
                            draggingOffset = offset
                        }, onEnd: { ///结束
                            isDragging = false
                            draggingOffset = .zero
                            draggingItem = nil
                            draggingStartRect = nil
                        })
                    )
            }
            
        }
        ///拖拽时上层添加一个预览视图
        .overlay(alignment: .topLeading) {
            if let draggingItem, let draggingStartRect {
                draggingPreview(draggingItem)
                    .disabled(true)
                    .allowsHitTesting(false)
                    .frame(width: draggingStartRect.width, height: draggingStartRect.height)
                    .offset(x: draggingStartRect.minX, y: draggingStartRect.minY)
                    .offset(draggingOffset)
            }
        }
        .coordinateSpace(.named("SORTABLEGRID"))
    }
}

struct SortableGridConfig {
    var spacing: CGFloat = 10
    var count: Int = 2
    /// Add More Propertites According to Your Needs !
}


/// 长按、拖拽手势
fileprivate struct CustomLongPressGesture: UIGestureRecognizerRepresentable {
    var duration: CGFloat = 0.16
    var onChanged: (_ location: CGPoint, _ offset: CGSize) -> ()
    var onEnd: () -> ()
    
    @State private var startLocation: CGPoint?
    func makeUIGestureRecognizer(context: Context) -> UILongPressGestureRecognizer {
        let gesture = UILongPressGestureRecognizer()
        gesture.minimumPressDuration = duration
        gesture.numberOfTapsRequired = 0
        gesture.numberOfTouchesRequired = 1
        return gesture
    }
    
    func updateUIGestureRecognizer(_ recognizer: UILongPressGestureRecognizer, context: Context) {  }
    
    func handleUIGestureRecognizerAction(_ recognizer: UILongPressGestureRecognizer, context: Context) {
        let state = recognizer.state
        let location = recognizer.location(in: recognizer.view)
        /// Converting Location into Translation by Storing the first staring location
        /// 通过保存最初的起始位置，将位置（Location）转换为位移（Translation）
        /// As this avoids the usage of another gesture (Pan)
        switch state {
        case .began, .changed:
            if startLocation == nil { startLocation = location }
            guard let startLocation else { return }
            let translation: CGSize = .init(
                width: location.x - startLocation.x,
                height: location.y - startLocation.y
            )
            
            onChanged(location, translation)
            ///print(translation)
            ///print("Recognized and updating it's location")
        default:
            startLocation = nil
            onEnd()
            ///print("Ended")
        }
    }
}

#Preview {
    ContentView()
}
