//
//  PulseRingView.swift
//  InteractiveMapCarousel
//
//  Created by EdwardElric on 2026/1/15.
//

import SwiftUI

struct PulseRingView: View {
    var tint: Color
    var size: CGFloat
    /// View Propertites
    @State private var animate:[Bool] = [false, false, false]
    @State private var showView: Bool = false
    @Environment(\.scenePhase) private var scenePhase
    var body: some View {
        ZStack {
            if showView {
                ZStack {
                    RingView(index: 0)
                    RingView(index: 1)
                    RingView(index: 2)
                }
            }
        }
        .onChange(of: scenePhase, initial: true) { oldValue, newValue in
            showView = newValue != .background
            if showView {
                start()
            } else {
                reset()
            }
        }
        .onAppear {
            showView = true
            start()
        }
        .onDisappear {
            reset()
            showView = false
        }
        .frame(width: size, height: size)
    }
    
    private func start() {
        /// Start Animating!
        for index in 0..<animate.count {
            let delay = Double(index) * 0.2
            withAnimation(.easeOut(duration: 2).repeatForever(autoreverses: false).delay(delay)) {
                animate[index] = true
            }
        }
    }
    
    private func reset() {
        /// Stop Animating!
        animate = [false, false, false]
    }
    
    @ViewBuilder
    func RingView(index: Int) -> some View {
        Circle()
            .fill(tint)
            .opacity(animate[index] ? 0 : 0.4)
            .scaleEffect(animate[index] ? 2 : 0)
    }
    
}

#Preview {
    PulseRingView(tint: .primary, size: 100)
}
