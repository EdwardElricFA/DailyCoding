//
//  ScrollToTopDisable.swift
//  InfiniteScrollViewCalendar
//
//  Created by EdwardElric on 2026/2/3.
//

/// 禁用触摸顶栏，日历跳转到最上方的一个月
import SwiftUI

struct  ScrollToTopDisable: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        DispatchQueue.main.async {
            if let scrollView = view.superview?.superview?.subviews.last?.subviews.first as? UIScrollView {
                scrollView.scrollsToTop = false
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
    
}
