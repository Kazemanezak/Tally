import Foundation

struct MilestoneDefinition: Identifiable, Equatable, Hashable {
    let id = UUID()
    let name: String
    let emoji: String
    let threshold: Int
    let animationType: AnimationType
}

enum AnimationType: Equatable, Hashable {
    case particleBurst
    case flame
    case lightning
    case supernova
    case legendBadge
}

struct MilestoneService {

    private let streakEngine: StreakEngine

    init(streakEngine: StreakEngine = StreakEngine()) {
        self.streakEngine = streakEngine
    }

    static let allMilestones: [MilestoneDefinition] = [
        MilestoneDefinition(name: "Spark", emoji: "✨", threshold: 3, animationType: .particleBurst),
        MilestoneDefinition(name: "Fire", emoji: "🔥", threshold: 7, animationType: .flame),
        MilestoneDefinition(name: "Lightning", emoji: "⚡", threshold: 14, animationType: .lightning),
        MilestoneDefinition(name: "Supernova", emoji: "💥", threshold: 30, animationType: .supernova),
        MilestoneDefinition(name: "Legend", emoji: "🏆", threshold: 100, animationType: .legendBadge)
    ]

    static var all: [MilestoneDefinition] {
        allMilestones
    }

    func checkMilestone(streak: Int) -> MilestoneDefinition? {
        Self.allMilestones
            .filter { streak >= $0.threshold }
            .max(by: { $0.threshold < $1.threshold })
    }

    func checkMilestone(previousBestStreak: Int, newStreak: Int) -> MilestoneDefinition? {
        guard newStreak > previousBestStreak else { return nil }

        let previouslyEarnedThreshold = highestThresholdReached(by: previousBestStreak)

        return Self.allMilestones
            .filter { newStreak >= $0.threshold && $0.threshold > previouslyEarnedThreshold }
            .max(by: { $0.threshold < $1.threshold })
    }

    func earnedMilestones(for habit: Habit, asOf date: Date = Date()) -> [MilestoneDefinition] {
        let best = streakEngine.bestStreak(for: habit, asOf: date)

        return Self.allMilestones
            .filter { best >= $0.threshold }
            .sorted { $0.threshold < $1.threshold }
    }

    private func highestThresholdReached(by streak: Int) -> Int {
        Self.allMilestones
            .filter { streak >= $0.threshold }
            .map(\.threshold)
            .max() ?? 0
    }
}
