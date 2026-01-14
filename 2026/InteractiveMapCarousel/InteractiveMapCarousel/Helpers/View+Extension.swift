//
//  View+Extension.swift
//  InteractiveMapCarousel
//
//  Created by EdwardElric on 2026/1/3.
//

import SwiftUI

extension View {
    @ViewBuilder
    func optionalGlassEffect(_ colorScheme: ColorScheme, cornerRadius: CGFloat = 30) -> some View {
        let backgroudColor = colorScheme == .dark ? Color.black : Color.white
        
        if #available(iOS 26, *) {
            self
                .glassEffect(.clear.tint(backgroudColor.opacity(0.75)).interactive(), in: .rect(cornerRadius: cornerRadius, style: .continuous))
        } else {
            self
                .background {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(backgroudColor)
                }
        }
    }
}
