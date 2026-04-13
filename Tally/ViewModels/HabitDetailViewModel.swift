import Foundation

@MainActor
@Observable
final class HabitDetailViewModel {
    let habit: Habit
    private let streakEngine = StreakEngine()
    private let milestoneService = MilestoneService()

    init(habit: Habit) {
        self.habit = habit
    }

    var currentStreak: Int {
        streakEngine.currentStreak(for: habit)
    }

    var bestStreak: Int {
        streakEngine.bestStreak(for: habit)
    }

    var totalCompletions: Int {
        switch habit.type {
        case .build:
            return habit.logs
                .filter { !$0.didSlip }
                .reduce(0) { $0 + $1.completionCount }

        case .break:
            let slipCount = habit.logs.filter { $0.didSlip }.count
            let totalDays = max(
                0,
                DateHelpers.daysBetween(
                    DateHelpers.startOfDay(habit.createdAt),
                    DateHelpers.startOfDay(Date())
                )
            )
            return max(0, totalDays - slipCount)
        }
    }

    var sortedLogs: [HabitLog] {
        habit.logs.sorted { $0.date > $1.date }
    }

    var recentLogs: [HabitLog] {
        Array(sortedLogs.prefix(10))
    }

    var totalSlipCount: Int {
        habit.logs.filter { $0.didSlip }.count
    }

    var totalSuccessfulLogs: Int {
        habit.logs.filter { !$0.didSlip && $0.completionCount > 0 }.count
    }

    var averageCompletionsPerLog: Double {
        let successfulBuildLogs = habit.logs.filter { !$0.didSlip && $0.completionCount > 0 }
        guard !successfulBuildLogs.isEmpty else { return 0 }

        let total = successfulBuildLogs.reduce(0) { $0 + $1.completionCount }
        return Double(total) / Double(successfulBuildLogs.count)
    }

    // MARK: - Heat Map Data

    func heatMapData() -> [Date: Int] {
        let today = DateHelpers.startOfDay(Date())
        guard let ninetyDaysAgo = Calendar.current.date(byAdding: .day, value: -89, to: today) else {
            return [:]
        }

        var data: [Date: Int] = [:]
        let dates = DateHelpers.datesInRange(from: ninetyDaysAgo, to: today)

        for date in dates {
            data[date] = 0
        }

        for log in habit.logs {
            let logDay = DateHelpers.startOfDay(log.date)

            guard logDay >= ninetyDaysAgo && logDay <= today else { continue }

            switch habit.type {
            case .build:
                data[logDay, default: 0] += log.completionCount

            case .break:
                if log.didSlip {
                    data[logDay] = -1
                }
            }
        }

        return data
    }

    func earnedMilestones() -> [MilestoneDefinition] {
        milestoneService.earnedMilestones(for: habit)
    }
}
