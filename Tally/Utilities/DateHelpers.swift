//
//  DateHelpers.swift
//  Tally
//
//  Created by David Castaneda on 3/29/26.
//

import Foundation

enum DateHelpers {
    static let calendar: Calendar = {
        var calendar = Calendar.current
        calendar.timeZone = .current
        return calendar
    }()

    static func startOfDay(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    static func isSameDay(_ lhs: Date, _ rhs: Date) -> Bool {
        calendar.isDate(lhs, inSameDayAs: rhs)
    }

    static func startOfWeek(for date: Date) -> Date {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components) ?? startOfDay(date)
    }

    static func isSameWeek(_ lhs: Date, _ rhs: Date) -> Bool {
        startOfWeek(for: lhs) == startOfWeek(for: rhs)
    }

    static func dayBefore(_ date: Date) -> Date? {
        calendar.date(byAdding: .day, value: -1, to: startOfDay(date))
    }

    static func dayAfter(_ date: Date) -> Date? {
        calendar.date(byAdding: .day, value: 1, to: startOfDay(date))
    }

    static func daysBetween(_ start: Date, _ end: Date) -> Int {
        let startDay = startOfDay(start)
        let endDay = startOfDay(end)
        return calendar.dateComponents([.day], from: startDay, to: endDay).day ?? 0
    }

    static func weeksBetween(_ start: Date, _ end: Date) -> Int {
        let startWeek = startOfWeek(for: start)
        let endWeek = startOfWeek(for: end)
        return calendar.dateComponents([.weekOfYear], from: startWeek, to: endWeek).weekOfYear ?? 0
    }

    static func datesInRange(from start: Date, to end: Date) -> [Date] {
        let startDay = startOfDay(start)
        let endDay = startOfDay(end)

        guard startDay <= endDay else { return [] }

        var dates: [Date] = []
        var current = startDay

        while current <= endDay {
            dates.append(current)
            guard let next = dayAfter(current) else { break }
            current = next
        }

        return dates
    }
}