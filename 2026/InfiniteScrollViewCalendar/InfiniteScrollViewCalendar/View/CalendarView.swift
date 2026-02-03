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
                        .frame(height: monthHeight)
                }
            }
        }
        .scrollPosition($scrollPosition)
        .defaultScrollAnchor(.center)
        .onAppear(perform: loadInitialDate)
        .safeAreaInset(edge: .top, spacing: 0) {
            SymbolView()
        }
    }
    
    @ViewBuilder
    func SymbolView() -> some View {
        HStack(spacing: 0) {
            ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 15)
        .overlay(alignment: .bottom) {
            Divider()
        }
        .background(.ultraThinMaterial)
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
        VStack(alignment: .leading, spacing: 0) {
            Text(month.name)
                .font(.title2)
                .fontWeight(.bold)
                .frame(height: 50, alignment: .bottom)
            
            /// Weeks View
            VStack(spacing: 0) {
                ForEach(month.weeks) { week in
                    HStack(spacing: 0) {
                        /// Days View
                        ForEach(week.days) { day in
                            DaysView(day: day)
                        }
                    }
                    .frame(maxHeight: .infinity)
                    .overlay(alignment: .bottom) {
                        if !week.isLast {
                            Divider()
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 15)
    }
}


/// Days View
struct DaysView: View {
    var day: Day
    var body: some View {
        if let dayValue = day.value, let date = day.date, !day.isPlaceholder {
            let isToday = Calendar.current.isDateInToday(date)
            
            Text("\(dayValue)")
                .font(.callout)
                .fontWeight(isToday ? .semibold : .regular)
                .foregroundStyle(isToday ? .white : .primary)
                .frame(width: 30, height: 50)
                .background {
                    if isToday {
                        Circle().fill(.blue.gradient)
                    }
                }
                .frame(maxWidth: .infinity)
        } else {
            Color.clear
        }
    }
}

#Preview {
    ContentView()
}
