import Foundation

enum DateHelpers {
    static var calendar: Calendar = {
        var calendar = Calendar.current
        calendar.timeZone = .autoupdatingCurrent
        return calendar
    }()

    static func startOfDay(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    static func isSameDay(_ lhs: Date, _ rhs: Date) -> Bool {
        calendar.isDate(startOfDay(lhs), inSameDayAs: startOfDay(rhs))
    }

    static func startOfWeek(for date: Date) -> Date {
        let normalizedDate = startOfDay(date)
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: normalizedDate)
        return calendar.date(from: components) ?? normalizedDate
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