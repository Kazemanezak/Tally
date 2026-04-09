//
//  MilestoneService.swift
//  Tally
//
//  Created by David Castaneda on 3/29/26.
//

import Foundation

struct MilestoneDefinition: Equatable, Hashable {
    let name: String
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
        MilestoneDefinition(name: "Spark", threshold: 3, animationType: .particleBurst),
        MilestoneDefinition(name: "Fire", threshold: 7, animationType: .flame),
        MilestoneDefinition(name: "Lightning", threshold: 14, animationType: .lightning),
        MilestoneDefinition(name: "Supernova", threshold: 30, animationType: .supernova),
        MilestoneDefinition(name: "Legend", threshold: 100, animationType: .legendBadge)
    ]

    /// Returns the highest milestone reached for a raw streak value.
    /// This is the simple TRD-specified form.
    func checkMilestone(streak: Int) -> MilestoneDefinition? {
        Self.allMilestones
            .filter { streak >= $0.threshold }
            .max(by: { $0.threshold < $1.threshold })
    }

    /// Returns the highest newly reached milestone, if any,
    /// by comparing the old best streak to the new streak.
    ///
    /// Example:
    /// previousBestStreak = 6, newStreak = 7 -> Fire
    /// previousBestStreak = 14, newStreak = 14 -> nil
    func checkMilestone(previousBestStreak: Int, newStreak: Int) -> MilestoneDefinition? {
        guard newStreak > previousBestStreak else { return nil }

        let previouslyEarnedThreshold = highestThresholdReached(by: previousBestStreak)

        return Self.allMilestones
            .filter { newStreak >= $0.threshold && $0.threshold > previouslyEarnedThreshold }
            .max(by: { $0.threshold < $1.threshold })
    }

    /// Returns all milestones the habit has earned based on best streak.
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
