//
//  CalendarDate.swift
//  InfiniteScrollViewCalendar
//
//  Created by EdwardElric on 2026/1/16.
//

import SwiftUI

struct Month: Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var weeks: [Week]
}

struct Week: Identifiable {
    var id: String = UUID().uuidString
    var days: [Day]
    var isLast: Bool = false
}

struct Day: Identifiable {
    var id: String = UUID().uuidString
    var value: Int?
    var date: Int?
    var isPlaceholder: Bool
}


