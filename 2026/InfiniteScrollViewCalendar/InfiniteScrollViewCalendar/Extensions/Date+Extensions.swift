//
//  Date+Extensions.swift
//  InfiniteScrollViewCalendar
//
//  Created by EdwardElric on 2026/1/16.
//

import SwiftUI

extension Date {
    /// Returns 10 months from the current date!
    var initialLoadMonths: [Month] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        
        var months: [Month] = []
        
        for offset in -5...4 {
            if let date = calendar.date(byAdding: .month, value: offset, to: self) {
                let monthName = formatter.string(from: date)
            }
        }
        
        return months
    }
    
    /// Extracing Month's Week from the given date
    
}
