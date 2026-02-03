//
//  CalendarView.swift
//  InfiniteScrollViewCalendar
//
//  Created by EdwardElric on 2026/1/30.
//

import SwiftUI

let monthHeight: CGFloat = 400

struct CalendarView: View {
    @State private var months: [Month] = []
    @State private var scrollPosition: ScrollPosition = .init()
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
                ForEach(months) { month in
                    MonthView(month: month)
                }
            }
        }
        .scrollPosition($scrollPosition)
        .defaultScrollAnchor(.center)
        .onAppear(perform: loadInitialDate)
    }
    
    func loadInitialDate() {
        guard months.isEmpty else { return }
        months = Date.now.initialLoadMonths
        /// Centering Scroll Position
        let centerOffset = (CGFloat(months.count / 2) * monthHeight) - (monthHeight / 2)
        scrollPosition.scrollTo(y: centerOffset)
    }
}

/// Month View
struct MonthView: View {
    var month: Month
    var body: some View {
        Text("Hello world")
    }
}

#Preview {
    ContentView()
}
