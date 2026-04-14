import Foundation
import SwiftData

struct DemoData {

    /// Seeds the model context with demo habits and log history.
    /// Only seeds if the database is empty (no existing habits).
    @MainActor
    static func seedIfNeeded(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<Habit>()
        let existingCount = (try? modelContext.fetchCount(descriptor)) ?? 0
        guard existingCount == 0 else { return }
        seed(modelContext: modelContext)
    }

    /// Clears all habits and logs, then re-seeds demo data.
    @MainActor
    static func forceSeed(modelContext: ModelContext) {
        clearAll(modelContext: modelContext)
        seed(modelContext: modelContext)
    }

    /// Clears all habits and logs.
    @MainActor
    static func clearAll(modelContext: ModelContext) {
        do {
            try modelContext.delete(model: HabitLog.self)
            try modelContext.delete(model: Habit.self)
            try modelContext.save()
        } catch {
            print("Failed to clear data: \(error)")
        }
    }

    /// Shifts all habit creation dates and log dates back by one day,
    /// simulating time advancing forward. Streaks grow, goals reset.
    @MainActor
    static func simulateNextDay(modelContext: ModelContext) {
        let calendar = Calendar.current
        let descriptor = FetchDescriptor<Habit>()

        guard let habits = try? modelContext.fetch(descriptor) else { return }

        for habit in habits {
            habit.createdAt = calendar.date(byAdding: .day, value: -1, to: habit.createdAt)!

            for log in habit.logs {
                log.date = calendar.date(byAdding: .day, value: -1, to: log.date)!
            }
        }

        do {
            try modelContext.save()
        } catch {
            print("Failed to simulate next day: \(error)")
        }
    }

    // MARK: - Private

    @MainActor
    private static func seed(modelContext: ModelContext) {
        let today = DateHelpers.startOfDay(Date())
        let calendar = Calendar.current

        // 1. "Morning Run" — 35-day streak, hits Supernova (30d)
        let run = Habit(
            name: "Morning Run",
            emoji: "figure.run",
            type: .build,
            frequencyGoal: 1,
            frequencyPeriod: .daily,
            accentColor: "#22C55E",
            sortOrder: 0,
            createdAt: calendar.date(byAdding: .day, value: -40, to: today)!
        )
        modelContext.insert(run)
        addDailyLogs(for: run, streakDays: 35, asOf: today, calendar: calendar, modelContext: modelContext)

        // 2. "Read 30 min" — 15-day streak, hits Lightning (14d)
        let read = Habit(
            name: "Read 30 min",
            emoji: "book.fill",
            type: .build,
            frequencyGoal: 1,
            frequencyPeriod: .daily,
            accentColor: "#6366F1",
            sortOrder: 1,
            createdAt: calendar.date(byAdding: .day, value: -20, to: today)!
        )
        modelContext.insert(read)
        addDailyLogs(for: read, streakDays: 15, asOf: today, calendar: calendar, modelContext: modelContext)

        // 3. "Drink Water" — 8-day streak, goal of 3/day, hits Fire (7d)
        let water = Habit(
            name: "Drink Water",
            emoji: "drop.fill",
            type: .build,
            frequencyGoal: 3,
            frequencyPeriod: .daily,
            accentColor: "#06B6D4",
            sortOrder: 2,
            createdAt: calendar.date(byAdding: .day, value: -12, to: today)!
        )
        modelContext.insert(water)
        addDailyLogs(for: water, streakDays: 8, asOf: today, calendar: calendar, modelContext: modelContext, completionsPerDay: 3)

        // 4. "Meditate" — 3-day streak, hits Spark (3d)
        let meditate = Habit(
            name: "Meditate",
            emoji: "brain.head.profile",
            type: .build,
            frequencyGoal: 1,
            frequencyPeriod: .daily,
            accentColor: "#A855F7",
            sortOrder: 3,
            createdAt: calendar.date(byAdding: .day, value: -5, to: today)!
        )
        modelContext.insert(meditate)
        addDailyLogs(for: meditate, streakDays: 3, asOf: today, calendar: calendar, modelContext: modelContext)

        // 5. "No Social Media" — Break habit, 10 days clean
        let noSocial = Habit(
            name: "No Social Media",
            emoji: "iphone.slash",
            type: .break,
            frequencyGoal: 1,
            frequencyPeriod: .daily,
            accentColor: "#EF4444",
            sortOrder: 4,
            createdAt: calendar.date(byAdding: .day, value: -10, to: today)!
        )
        modelContext.insert(noSocial)

        // 6. "No Junk Food" — Break habit with a slip 4 days ago
        let noJunk = Habit(
            name: "No Junk Food",
            emoji: "fork.knife.circle",
            type: .break,
            frequencyGoal: 1,
            frequencyPeriod: .daily,
            accentColor: "#F97316",
            sortOrder: 5,
            createdAt: calendar.date(byAdding: .day, value: -14, to: today)!
        )
        modelContext.insert(noJunk)
        let slipDate = calendar.date(byAdding: .day, value: -4, to: today)!
        let slipLog = HabitLog(date: slipDate, completionCount: 0, didSlip: true, habit: noJunk)
        modelContext.insert(slipLog)

        // 7. "Gym" — Weekly habit, 3-week streak (hits Spark at 3)
        let gym = Habit(
            name: "Gym",
            emoji: "dumbbell.fill",
            type: .build,
            frequencyGoal: 3,
            frequencyPeriod: .weekly,
            accentColor: "#F59E0B",
            sortOrder: 6,
            createdAt: calendar.date(byAdding: .day, value: -25, to: today)!
        )
        modelContext.insert(gym)
        addWeeklyLogs(for: gym, weeks: 3, asOf: today, calendar: calendar, modelContext: modelContext)

        do {
            try modelContext.save()
        } catch {
            print("Failed to seed demo data: \(error)")
        }
    }

    private static func addDailyLogs(
        for habit: Habit,
        streakDays: Int,
        asOf today: Date,
        calendar: Calendar,
        modelContext: ModelContext,
        completionsPerDay: Int = 1
    ) {
        let preStreakDays = [5, 8, 12, 15].filter { $0 > streakDays }
        for daysBack in preStreakDays {
            let date = calendar.date(byAdding: .day, value: -daysBack, to: today)!
            let log = HabitLog(date: date, completionCount: 1, habit: habit)
            modelContext.insert(log)
        }

        for daysBack in 0..<streakDays {
            let date = calendar.date(byAdding: .day, value: -daysBack, to: today)!
            let log = HabitLog(date: date, completionCount: completionsPerDay, habit: habit)
            modelContext.insert(log)
        }
    }

    private static func addWeeklyLogs(
        for habit: Habit,
        weeks: Int,
        asOf today: Date,
        calendar: Calendar,
        modelContext: ModelContext
    ) {
        for week in 0..<weeks {
            let weekStart = calendar.date(byAdding: .day, value: -(week * 7), to: today)!
            for i in 0..<habit.frequencyGoal {
                let date = calendar.date(byAdding: .day, value: -i, to: weekStart)!
                let log = HabitLog(date: date, completionCount: 1, habit: habit)
                modelContext.insert(log)
            }
        }
    }
}
