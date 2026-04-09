import Foundation
import SwiftData

@MainActor
@Observable
final class HomeViewModel {

    var habits: [Habit] = []
    var pendingUndoLog: HabitLog?
    var undoHabit: Habit?
    var showUndoToast: Bool = false

    private let modelContext: ModelContext
    private let streakEngine = StreakEngine()
    private var undoTask: Task<Void, Never>?

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchHabits()
    }

    // MARK: - Data

    func fetchHabits() {
        let descriptor = FetchDescriptor<Habit>(
            predicate: #Predicate { !$0.isArchived },
            sortBy: [SortDescriptor(\.sortOrder)]
        )
        habits = (try? modelContext.fetch(descriptor)) ?? []
    }

    // MARK: - Logging

    func logCompletion(for habit: Habit) {
        let today = DateHelpers.startOfDay(Date())
        let existingLog = habit.logs.first { DateHelpers.isSameDay($0.date, today) && !$0.didSlip }

        let streakBefore = streakEngine.currentStreak(for: habit)

        if let log = existingLog {
            log.completionCount += 1
            pendingUndoLog = log
        } else {
            let newLog = HabitLog(date: Date(), completionCount: 1, habit: habit)
            modelContext.insert(newLog)
            pendingUndoLog = newLog
        }

        undoHabit = habit
        try? modelContext.save()

        let streakAfter = streakEngine.currentStreak(for: habit)

        if let milestone = MilestoneService.reachedMilestone(from: streakBefore, to: streakAfter) {
            MilestoneService.playHaptic(for: milestone)
        } else if streakAfter > streakBefore {
            HapticManager.medium()
        } else {
            HapticManager.light()
        }

        startUndoTimer()
    }

    func recordSlip(for habit: Habit) {
        let newLog = HabitLog(date: Date(), completionCount: 0, didSlip: true, habit: habit)
        modelContext.insert(newLog)
        pendingUndoLog = newLog
        undoHabit = habit
        try? modelContext.save()

        HapticManager.heavy()
        startUndoTimer()
    }

    func undoLastLog() {
        guard let log = pendingUndoLog else { return }

        if !log.didSlip && log.completionCount > 1 {
            log.completionCount -= 1
        } else {
            modelContext.delete(log)
        }

        pendingUndoLog = nil
        undoHabit = nil
        showUndoToast = false
        undoTask?.cancel()
        try? modelContext.save()
        fetchHabits()
    }

    // MARK: - Reorder

    func moveHabit(from source: IndexSet, to destination: Int) {
        habits.move(fromOffsets: source, toOffset: destination)
        for (index, habit) in habits.enumerated() {
            habit.sortOrder = index
        }
        try? modelContext.save()
    }

    // MARK: - Streak Helpers

    func streakCount(for habit: Habit) -> Int {
        streakEngine.currentStreak(for: habit)
    }

    func completionProgress(for habit: Habit) -> (current: Int, goal: Int) {
        (streakEngine.completionsInCurrentPeriod(for: habit), habit.frequencyGoal)
    }

    func isGoalMet(for habit: Habit) -> Bool {
        streakEngine.isGoalMetToday(for: habit)
    }

    // MARK: - Private

    private func startUndoTimer() {
        undoTask?.cancel()
        showUndoToast = true
        undoTask = Task {
            try? await Task.sleep(for: .seconds(5))
            guard !Task.isCancelled else { return }
            showUndoToast = false
            pendingUndoLog = nil
            undoHabit = nil
        }
    }
}
