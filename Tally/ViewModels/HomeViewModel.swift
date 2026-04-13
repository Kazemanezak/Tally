import Foundation
import SwiftData

@MainActor
@Observable
final class HomeViewModel {

    var habits: [Habit] = []
    var archivedHabits: [Habit] = []

    var pendingUndoLog: HabitLog?
    var undoHabit: Habit?
    var showUndoToast: Bool = false

    var milestoneToShow: MilestoneDefinition?
    var showMilestoneOverlay: Bool = false

    private let modelContext: ModelContext
    private let streakEngine = StreakEngine()
    private let milestoneService = MilestoneService()
    private var undoTask: Task<Void, Never>?

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchHabits()
        fetchArchivedHabits()
    }

    // MARK: - Data

    func fetchHabits() {
        let descriptor = FetchDescriptor<Habit>(
            predicate: #Predicate { !$0.isArchived },
            sortBy: [SortDescriptor(\.sortOrder)]
        )

        do {
            habits = try modelContext.fetch(descriptor)
        } catch {
            print("❌ Failed to fetch habits:", error)
            habits = []
        }
    }

    func fetchArchivedHabits() {
        let descriptor = FetchDescriptor<Habit>(
            predicate: #Predicate { $0.isArchived },
            sortBy: [SortDescriptor(\.sortOrder)]
        )

        do {
            archivedHabits = try modelContext.fetch(descriptor)
        } catch {
            print("❌ Failed to fetch archived habits:", error)
            archivedHabits = []
        }
    }

    // MARK: - Archive

    func archiveHabit(_ habit: Habit) {
        habit.isArchived = true
        saveContext()
        fetchHabits()
        fetchArchivedHabits()
    }

    func unarchiveHabit(_ habit: Habit) {
        habit.isArchived = false
        saveContext()
        fetchHabits()
        fetchArchivedHabits()
    }

    // MARK: - Logging

    func logCompletion(for habit: Habit) {
        let today = DateHelpers.startOfDay(Date())
        let existingLog = habit.logs.first {
            DateHelpers.isSameDay($0.date, today) && !$0.didSlip
        }

        let previousBestStreak = streakEngine.bestStreak(for: habit)

        if let log = existingLog {
            log.completionCount += 1
            pendingUndoLog = log
        } else {
            let newLog = HabitLog(date: Date(), completionCount: 1, habit: habit)
            modelContext.insert(newLog)
            pendingUndoLog = newLog
        }

        undoHabit = habit
        saveContext()

        let newBestStreak = streakEngine.bestStreak(for: habit)

        if let milestone = milestoneService.checkMilestone(
            previousBestStreak: previousBestStreak,
            newStreak: newBestStreak
        ) {
            milestoneToShow = milestone
            showMilestoneOverlay = true
        } else if streakEngine.currentStreak(for: habit) > 0 {
            HapticManager.medium()
        } else {
            HapticManager.light()
        }

        fetchHabits()
        fetchArchivedHabits()
        startUndoTimer()
    }

    func recordSlip(for habit: Habit) {
        let newLog = HabitLog(date: Date(), completionCount: 0, didSlip: true, habit: habit)
        modelContext.insert(newLog)
        pendingUndoLog = newLog
        undoHabit = habit

        saveContext()

        HapticManager.heavy()
        fetchHabits()
        fetchArchivedHabits()
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

        saveContext()
        fetchHabits()
        fetchArchivedHabits()
    }

    func dismissMilestoneOverlay() {
        showMilestoneOverlay = false
        milestoneToShow = nil
    }

    // MARK: - Reorder

    func moveHabit(from source: IndexSet, to destination: Int) {
        habits.move(fromOffsets: source, toOffset: destination)

        for (index, habit) in habits.enumerated() {
            habit.sortOrder = index
        }

        saveContext()
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

    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("❌ Failed to save context:", error)
        }
    }
}
