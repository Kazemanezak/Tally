//
//  HabitLog.swift
//  Tally
//
//  Created by David Castaneda on 3/29/26.
//

import Foundation
import SwiftData

@Model
final class HabitLog {
    var id: UUID
    var date: Date
    var completionCount: Int
    var didSlip: Bool
    var habit: Habit?

    init(
        id: UUID = UUID(),
        date: Date,
        completionCount: Int = 0,
        didSlip: Bool = false,
        habit: Habit? = nil
    ) {
        self.id = id
        self.date = date
        self.completionCount = max(0, completionCount)
        self.didSlip = didSlip
        self.habit = habit
    }
}
