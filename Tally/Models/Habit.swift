//
//  Habit.swift
//  Tally
//
//  Created by David Castaneda on 3/29/26.
//

import Foundation
import SwiftData

@Model
final class Habit {
    var id: UUID
    var name: String
    var emoji: String
    var type: HabitType
    var frequencyGoal: Int
    var frequencyPeriod: Period
    var accentColor: String
    var sortOrder: Int
    var isArchived: Bool
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \HabitLog.habit)
    var logs: [HabitLog]

    init(
        id: UUID = UUID(),
        name: String,
        emoji: String,
        type: HabitType,
        frequencyGoal: Int,
        frequencyPeriod: Period,
        accentColor: String = "#4F46E5",
        sortOrder: Int = 0,
        isArchived: Bool = false,
        createdAt: Date = Date(),
        logs: [HabitLog] = []
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.type = type
        self.frequencyGoal = max(1, frequencyGoal)
        self.frequencyPeriod = frequencyPeriod
        self.accentColor = accentColor
        self.sortOrder = sortOrder
        self.isArchived = isArchived
        self.createdAt = createdAt
        self.logs = logs
    }
}