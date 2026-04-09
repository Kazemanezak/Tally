import Foundation

@MainActor
@Observable
final class HabitDetailViewModel {
    let habit: Habit
    private let streakEngine = StreakEngine()

    var currentStreak: Int { streakEngine.currentStreak(for: habit) }
    var bestStreak: Int { streakEngine.bestStreak(for: habit) }

    var totalCompletions: Int {
        switch habit.type {
        case .build:
            return habit.logs.filter { !$0.didSlip }.reduce(0) { $0 + $1.completionCount }
        case .break:
            let slipCount = habit.logs.filter { $0.didSlip }.count
            let totalDays = max(0, DateHelpers.daysBetween(DateHelpers.startOfDay(habit.createdAt), DateHelpers.startOfDay(Date())))
            return totalDays - slipCount
        }
    }

    init(habit: Habit) {
        self.habit = habit
    }

    // MARK: - Heat Map Data

    /// Returns a dictionary mapping each date (start of day) in the last 90 days to its completion count.
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
            if logDay >= ninetyDaysAgo && logDay <= today {
                if habit.type == .build {
                    data[logDay, default: 0] += log.completionCount
                } else if log.didSlip {
                    // For break habits, mark slip days as -1 (red)
                    data[logDay] = -1
                }
            }
        }

        return data
    }

    /// Returns milestone thresholds that the habit has reached.
    func earnedMilestones() -> [MilestoneDefinition] {
        let streak = streakEngine.bestStreak(for: habit)
        return MilestoneDefinition.all.filter { streak >= $0.threshold }
    }
}

// MARK: - Milestone Definitions

struct MilestoneDefinition: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let threshold: Int

    static let all: [MilestoneDefinition] = [
        MilestoneDefinition(name: "Spark", emoji: "✨", threshold: 3),
        MilestoneDefinition(name: "Fire", emoji: "🔥", threshold: 7),
        MilestoneDefinition(name: "Lightning", emoji: "⚡", threshold: 14),
        MilestoneDefinition(name: "Supernova", emoji: "💥", threshold: 30),
        MilestoneDefinition(name: "Legend", emoji: "🏆", threshold: 100),
    ]
}
