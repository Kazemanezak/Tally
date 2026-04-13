import Foundation

struct StreakEngine {

    private var calendar: Calendar {
        DateHelpers.calendar
    }

    func currentStreak(for habit: Habit, asOf date: Date = Date()) -> Int {
        switch habit.type {
        case .build:
            switch habit.frequencyPeriod {
            case .daily:
                return currentDailyBuildStreak(for: habit, asOf: date)
            case .weekly:
                return currentWeeklyBuildStreak(for: habit, asOf: date)
            }
        case .break:
            return currentBreakStreak(for: habit, asOf: date)
        }
    }

    func bestStreak(for habit: Habit, asOf date: Date = Date()) -> Int {
        switch habit.type {
        case .build:
            switch habit.frequencyPeriod {
            case .daily:
                return bestDailyBuildStreak(for: habit, asOf: date)
            case .weekly:
                return bestWeeklyBuildStreak(for: habit, asOf: date)
            }
        case .break:
            return bestBreakStreak(for: habit, asOf: date)
        }
    }

    func completionsInCurrentPeriod(for habit: Habit, asOf date: Date = Date()) -> Int {
        let normalizedLogs = normalizedBuildLogs(for: habit)

        switch habit.frequencyPeriod {
        case .daily:
            let today = DateHelpers.startOfDay(date)
            return normalizedLogs[today] ?? 0

        case .weekly:
            let weekStart = DateHelpers.startOfWeek(for: date)
            return normalizedLogs
                .filter { DateHelpers.startOfWeek(for: $0.key) == weekStart }
                .reduce(0) { $0 + $1.value }
        }
    }

    func isGoalMetToday(for habit: Habit, asOf date: Date = Date()) -> Bool {
        guard habit.type == .build else { return false }
        return completionsInCurrentPeriod(for: habit, asOf: date) >= habit.frequencyGoal
    }
}

// MARK: - Private helpers
private extension StreakEngine {

    func normalizedBuildLogs(for habit: Habit) -> [Date: Int] {
        var result: [Date: Int] = [:]

        for log in habit.logs where !log.didSlip {
            let day = DateHelpers.startOfDay(log.date)
            result[day, default: 0] += log.completionCount
        }

        return result
    }

    func normalizedSlipDays(for habit: Habit) -> [Date] {
        habit.logs
            .filter(\.didSlip)
            .map { DateHelpers.startOfDay($0.date) }
            .sorted()
    }

    // MARK: - Build / Daily

    func currentDailyBuildStreak(for habit: Habit, asOf date: Date) -> Int {
        let logsByDay = normalizedBuildLogs(for: habit)
        let asOfDay = DateHelpers.startOfDay(date)
        let createdDay = DateHelpers.startOfDay(habit.createdAt)

        guard asOfDay >= createdDay else { return 0 }

        var streak = 0
        var cursor = asOfDay

        while cursor >= createdDay {
            let completions = logsByDay[cursor] ?? 0
            guard completions >= habit.frequencyGoal else { break }

            streak += 1

            guard let previousDay = DateHelpers.dayBefore(cursor) else { break }
            cursor = previousDay
        }

        return streak
    }

    func bestDailyBuildStreak(for habit: Habit, asOf date: Date) -> Int {
        let logsByDay = normalizedBuildLogs(for: habit)
        let createdDay = DateHelpers.startOfDay(habit.createdAt)
        let endDay = max(
            createdDay,
            min(
                DateHelpers.startOfDay(date),
                logsByDay.keys.max() ?? createdDay
            )
        )

        let allDays = DateHelpers.datesInRange(from: createdDay, to: endDay)

        var best = 0
        var current = 0

        for day in allDays {
            let completions = logsByDay[day] ?? 0
            if completions >= habit.frequencyGoal {
                current += 1
                best = max(best, current)
            } else {
                current = 0
            }
        }

        return best
    }

    // MARK: - Build / Weekly

    func currentWeeklyBuildStreak(for habit: Habit, asOf date: Date) -> Int {
        let weekTotals = weeklyCompletionTotals(for: habit)
        let currentWeek = DateHelpers.startOfWeek(for: date)
        let createdWeek = DateHelpers.startOfWeek(for: habit.createdAt)

        guard currentWeek >= createdWeek else { return 0 }

        var streak = 0
        var cursor = currentWeek

        while cursor >= createdWeek {
            let completions = weekTotals[cursor] ?? 0
            guard completions >= habit.frequencyGoal else { break }

            streak += 1

            guard let previousWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: cursor) else { break }
            cursor = DateHelpers.startOfWeek(for: previousWeek)
        }

        return streak
    }

    func bestWeeklyBuildStreak(for habit: Habit, asOf date: Date) -> Int {
        let weekTotals = weeklyCompletionTotals(for: habit)
        let createdWeek = DateHelpers.startOfWeek(for: habit.createdAt)
        let endWeek = max(
            createdWeek,
            min(
                DateHelpers.startOfWeek(for: date),
                weekTotals.keys.max() ?? createdWeek
            )
        )

        let allWeeks = weekSequence(from: createdWeek, to: endWeek)

        var best = 0
        var current = 0

        for week in allWeeks {
            let completions = weekTotals[week] ?? 0
            if completions >= habit.frequencyGoal {
                current += 1
                best = max(best, current)
            } else {
                current = 0
            }
        }

        return best
    }

    func weeklyCompletionTotals(for habit: Habit) -> [Date: Int] {
        let logsByDay = normalizedBuildLogs(for: habit)
        var totals: [Date: Int] = [:]

        for (day, count) in logsByDay {
            let weekStart = DateHelpers.startOfWeek(for: day)
            totals[weekStart, default: 0] += count
        }

        return totals
    }

    func weekSequence(from start: Date, to end: Date) -> [Date] {
        guard start <= end else { return [] }

        var weeks: [Date] = []
        var cursor = DateHelpers.startOfWeek(for: start)
        let endWeek = DateHelpers.startOfWeek(for: end)

        while cursor <= endWeek {
            weeks.append(cursor)
            guard let next = calendar.date(byAdding: .weekOfYear, value: 1, to: cursor) else { break }
            cursor = DateHelpers.startOfWeek(for: next)
        }

        return weeks
    }

    // MARK: - Break

    func currentBreakStreak(for habit: Habit, asOf date: Date) -> Int {
        let today = DateHelpers.startOfDay(date)
        let createdDay = DateHelpers.startOfDay(habit.createdAt)
        let slips = normalizedSlipDays(for: habit)

        guard today >= createdDay else { return 0 }

        guard let lastSlip = slips.last else {
            return max(0, DateHelpers.daysBetween(createdDay, today))
        }

        return max(0, DateHelpers.daysBetween(lastSlip, today))
    }

    func bestBreakStreak(for habit: Habit, asOf date: Date) -> Int {
        let createdDay = DateHelpers.startOfDay(habit.createdAt)
        let today = DateHelpers.startOfDay(date)
        let slips = normalizedSlipDays(for: habit)

        guard today >= createdDay else { return 0 }

        guard !slips.isEmpty else {
            return max(0, DateHelpers.daysBetween(createdDay, today))
        }

        var best = max(0, DateHelpers.daysBetween(createdDay, slips[0]))

        for index in 1..<slips.count {
            let previousSlip = slips[index - 1]
            let currentSlip = slips[index]
            let streak = max(0, DateHelpers.daysBetween(previousSlip, currentSlip))
            best = max(best, streak)
        }

        if let lastSlip = slips.last {
            best = max(best, max(0, DateHelpers.daysBetween(lastSlip, today)))
        }

        return best
    }
}