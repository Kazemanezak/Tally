//
//  StreakEngineTests.swift
//  Tally
//
//  Created by David Castaneda on 3/29/26.
//

import XCTest
@testable import Tally

final class StreakEngineTests: XCTestCase {

    private let engine = StreakEngine()
    private let calendar = Calendar.current

    // MARK: - Helpers

    private func makeDate(_ year: Int, _ month: Int, _ day: Int) -> Date {
        let components = DateComponents(year: year, month: month, day: day)
        guard let date = calendar.date(from: components) else {
            fatalError("Failed to create date: \(year)-\(month)-\(day)")
        }
        return date
    }

    private func makeBuildHabit(
        createdAt: Date,
        frequencyGoal: Int = 1,
        period: Period = .daily,
        logs: [HabitLog] = []
    ) -> Habit {
        Habit(
            name: "Build Habit",
            emoji: "💪",
            type: .build,
            frequencyGoal: frequencyGoal,
            frequencyPeriod: period,
            accentColor: "#4F46E5",
            sortOrder: 0,
            isArchived: false,
            createdAt: createdAt,
            logs: logs
        )
    }

    private func makeBreakHabit(
        createdAt: Date,
        logs: [HabitLog] = []
    ) -> Habit {
        Habit(
            name: "Break Habit",
            emoji: "🚭",
            type: .break,
            frequencyGoal: 1,
            frequencyPeriod: .daily,
            accentColor: "#EF4444",
            sortOrder: 0,
            isArchived: false,
            createdAt: createdAt,
            logs: logs
        )
    }

    private func makeBuildLog(
        date: Date,
        count: Int
    ) -> HabitLog {
        HabitLog(
            date: date,
            completionCount: count,
            didSlip: false
        )
    }

    private func makeSlipLog(
        date: Date
    ) -> HabitLog {
        HabitLog(
            date: date,
            completionCount: 0,
            didSlip: true
        )
    }

    // MARK: - Daily Build Streak Tests

    func testCurrentDailyBuildStreak_countsConsecutiveSuccessfulDays() {
        let createdAt = makeDate(2026, 4, 1)
        let asOf = makeDate(2026, 4, 4)

        let logs = [
            makeBuildLog(date: makeDate(2026, 4, 2), count: 1),
            makeBuildLog(date: makeDate(2026, 4, 3), count: 1),
            makeBuildLog(date: makeDate(2026, 4, 4), count: 1)
        ]

        let habit = makeBuildHabit(
            createdAt: createdAt,
            frequencyGoal: 1,
            period: .daily,
            logs: logs
        )

        let streak = engine.currentStreak(for: habit, asOf: asOf)
        XCTAssertEqual(streak, 3)
    }

    func testCurrentDailyBuildStreak_breaksOnMissedDay() {
        let createdAt = makeDate(2026, 4, 1)
        let asOf = makeDate(2026, 4, 4)

        let logs = [
            makeBuildLog(date: makeDate(2026, 4, 1), count: 1),
            makeBuildLog(date: makeDate(2026, 4, 2), count: 1),
            // missed 4/3
            makeBuildLog(date: makeDate(2026, 4, 4), count: 1)
        ]

        let habit = makeBuildHabit(
            createdAt: createdAt,
            frequencyGoal: 1,
            period: .daily,
            logs: logs
        )

        let streak = engine.currentStreak(for: habit, asOf: asOf)
        XCTAssertEqual(streak, 1)
    }

    func testBestDailyBuildStreak_returnsLongestRun() {
        let createdAt = makeDate(2026, 4, 1)

        let logs = [
            makeBuildLog(date: makeDate(2026, 4, 1), count: 1),
            makeBuildLog(date: makeDate(2026, 4, 2), count: 1),
            // missed 4/3
            makeBuildLog(date: makeDate(2026, 4, 4), count: 1),
            makeBuildLog(date: makeDate(2026, 4, 5), count: 1),
            makeBuildLog(date: makeDate(2026, 4, 6), count: 1)
        ]

        let habit = makeBuildHabit(
            createdAt: createdAt,
            frequencyGoal: 1,
            period: .daily,
            logs: logs
        )

        let best = engine.bestStreak(for: habit, asOf: makeDate(2026, 4, 6))
        XCTAssertEqual(best, 3)
    }

    func testDailyBuildStreak_requiresMeetingFrequencyGoal() {
        let createdAt = makeDate(2026, 4, 1)
        let asOf = makeDate(2026, 4, 3)

        let logs = [
            makeBuildLog(date: makeDate(2026, 4, 1), count: 2),
            makeBuildLog(date: makeDate(2026, 4, 2), count: 1), // below goal
            makeBuildLog(date: makeDate(2026, 4, 3), count: 2)
        ]

        let habit = makeBuildHabit(
            createdAt: createdAt,
            frequencyGoal: 2,
            period: .daily,
            logs: logs
        )

        let current = engine.currentStreak(for: habit, asOf: asOf)
        let best = engine.bestStreak(for: habit, asOf: asOf)

        XCTAssertEqual(current, 1)
        XCTAssertEqual(best, 1)
    }

    // MARK: - Weekly Build Streak Tests

    func testCompletionsInCurrentWeek_sumsLogsAcrossWeek() {
        let createdAt = makeDate(2026, 4, 1)
        let asOf = makeDate(2026, 4, 9)

        let logs = [
            makeBuildLog(date: makeDate(2026, 4, 7), count: 1),
            makeBuildLog(date: makeDate(2026, 4, 8), count: 1),
            makeBuildLog(date: makeDate(2026, 4, 9), count: 1)
        ]

        let habit = makeBuildHabit(
            createdAt: createdAt,
            frequencyGoal: 2,
            period: .weekly,
            logs: logs
        )

        let completions = engine.completionsInCurrentPeriod(for: habit, asOf: asOf)
        XCTAssertEqual(completions, 3)
    }

    func testCurrentWeeklyBuildStreak_countsConsecutiveSuccessfulWeeks() {
        let createdAt = makeDate(2026, 3, 24)
        let asOf = makeDate(2026, 4, 9)

        let logs = [
            // Week 1
            makeBuildLog(date: makeDate(2026, 3, 24), count: 1),
            makeBuildLog(date: makeDate(2026, 3, 25), count: 1),

            // Week 2
            makeBuildLog(date: makeDate(2026, 3, 31), count: 1),
            makeBuildLog(date: makeDate(2026, 4, 1), count: 1),

            // Week 3
            makeBuildLog(date: makeDate(2026, 4, 8), count: 2)
        ]

        let habit = makeBuildHabit(
            createdAt: createdAt,
            frequencyGoal: 2,
            period: .weekly,
            logs: logs
        )

        let streak = engine.currentStreak(for: habit, asOf: asOf)
        XCTAssertEqual(streak, 3)
    }

    func testCurrentWeeklyBuildStreak_breaksWhenWeekGoalNotMet() {
        let createdAt = makeDate(2026, 3, 24)
        let asOf = makeDate(2026, 4, 9)

        let logs = [
            // Earlier good week
            makeBuildLog(date: makeDate(2026, 3, 24), count: 1),
            makeBuildLog(date: makeDate(2026, 3, 25), count: 1),

            // Missed/failed week
            makeBuildLog(date: makeDate(2026, 3, 31), count: 1),

            // Current good week
            makeBuildLog(date: makeDate(2026, 4, 8), count: 2)
        ]

        let habit = makeBuildHabit(
            createdAt: createdAt,
            frequencyGoal: 2,
            period: .weekly,
            logs: logs
        )

        let streak = engine.currentStreak(for: habit, asOf: asOf)
        XCTAssertEqual(streak, 1)
    }

    func testBestWeeklyBuildStreak_returnsLongestRunOfSuccessfulWeeks() {
        let createdAt = makeDate(2026, 3, 1)
        let asOf = makeDate(2026, 4, 15)

        let logs = [
            // Week A success
            makeBuildLog(date: makeDate(2026, 3, 2), count: 2),

            // Week B success
            makeBuildLog(date: makeDate(2026, 3, 9), count: 2),

            // Week C fail
            makeBuildLog(date: makeDate(2026, 3, 16), count: 1),

            // Week D success
            makeBuildLog(date: makeDate(2026, 3, 23), count: 2),

            // Week E success
            makeBuildLog(date: makeDate(2026, 3, 30), count: 2),

            // Week F success
            makeBuildLog(date: makeDate(2026, 4, 6), count: 2)
        ]

        let habit = makeBuildHabit(
            createdAt: createdAt,
            frequencyGoal: 2,
            period: .weekly,
            logs: logs
        )

        let best = engine.bestStreak(for: habit, asOf: asOf)
        XCTAssertEqual(best, 3)
    }

    // MARK: - Goal / Period Tests

    func testCompletionsInCurrentDay_returnsDailyCount() {
        let createdAt = makeDate(2026, 4, 1)
        let asOf = makeDate(2026, 4, 3)

        let logs = [
            makeBuildLog(date: makeDate(2026, 4, 3), count: 2),
            makeBuildLog(date: makeDate(2026, 4, 2), count: 1)
        ]

        let habit = makeBuildHabit(
            createdAt: createdAt,
            frequencyGoal: 2,
            period: .daily,
            logs: logs
        )

        let completions = engine.completionsInCurrentPeriod(for: habit, asOf: asOf)
        XCTAssertEqual(completions, 2)
    }

    func testIsGoalMetToday_returnsTrueWhenDailyGoalReached() {
        let createdAt = makeDate(2026, 4, 1)
        let asOf = makeDate(2026, 4, 3)

        let logs = [
            makeBuildLog(date: makeDate(2026, 4, 3), count: 2)
        ]

        let habit = makeBuildHabit(
            createdAt: createdAt,
            frequencyGoal: 2,
            period: .daily,
            logs: logs
        )

        XCTAssertTrue(engine.isGoalMetToday(for: habit, asOf: asOf))
    }

    func testIsGoalMetToday_returnsFalseForBreakHabit() {
        let habit = makeBreakHabit(createdAt: makeDate(2026, 4, 1))
        XCTAssertFalse(engine.isGoalMetToday(for: habit, asOf: makeDate(2026, 4, 3)))
    }

    // MARK: - Break Habit Tests

    func testCurrentBreakStreak_withoutSlips_countsDaysSinceCreation() {
        let createdAt = makeDate(2026, 4, 1)
        let asOf = makeDate(2026, 4, 6)

        let habit = makeBreakHabit(createdAt: createdAt)

        let streak = engine.currentStreak(for: habit, asOf: asOf)
        XCTAssertEqual(streak, 5)
    }

    func testCurrentBreakStreak_withSingleSlip_countsDaysSinceLastSlip() {
        let createdAt = makeDate(2026, 4, 1)
        let asOf = makeDate(2026, 4, 10)

        let logs = [
            makeSlipLog(date: makeDate(2026, 4, 7))
        ]

        let habit = makeBreakHabit(createdAt: createdAt, logs: logs)

        let streak = engine.currentStreak(for: habit, asOf: asOf)
        XCTAssertEqual(streak, 3)
    }

    func testBestBreakStreak_returnsLongestGapBetweenSlips() {
        let createdAt = makeDate(2026, 4, 1)
        let asOf = makeDate(2026, 4, 20)

        let logs = [
            makeSlipLog(date: makeDate(2026, 4, 4)),   // streak from creation: 3
            makeSlipLog(date: makeDate(2026, 4, 10)),  // streak between slips: 6
            makeSlipLog(date: makeDate(2026, 4, 13))   // streak between slips: 3
        ]

        let habit = makeBreakHabit(createdAt: createdAt, logs: logs)

        let best = engine.bestStreak(for: habit, asOf: asOf)
        XCTAssertEqual(best, 7) // current run from 4/13 to 4/20
    }

    func testBestBreakStreak_withoutSlips_matchesCurrentRun() {
        let createdAt = makeDate(2026, 4, 1)
        let asOf = makeDate(2026, 4, 8)

        let habit = makeBreakHabit(createdAt: createdAt)

        let best = engine.bestStreak(for: habit, asOf: asOf)
        XCTAssertEqual(best, 7)
    }

    // MARK: - Edge / Aggregation Tests

    func testMultipleLogsSameDay_areSummedForBuildHabits() {
        let createdAt = makeDate(2026, 4, 1)
        let asOf = makeDate(2026, 4, 2)

        let logs = [
            makeBuildLog(date: makeDate(2026, 4, 2), count: 1),
            makeBuildLog(date: makeDate(2026, 4, 2), count: 1)
        ]

        let habit = makeBuildHabit(
            createdAt: createdAt,
            frequencyGoal: 2,
            period: .daily,
            logs: logs
        )

        let completions = engine.completionsInCurrentPeriod(for: habit, asOf: asOf)
        let metGoal = engine.isGoalMetToday(for: habit, asOf: asOf)

        XCTAssertEqual(completions, 2)
        XCTAssertTrue(metGoal)
    }

    func testEmptyBuildHabit_hasZeroCurrentAndBestStreak() {
        let createdAt = makeDate(2026, 4, 1)
        let asOf = makeDate(2026, 4, 5)

        let habit = makeBuildHabit(
            createdAt: createdAt,
            frequencyGoal: 1,
            period: .daily,
            logs: []
        )

        XCTAssertEqual(engine.currentStreak(for: habit, asOf: asOf), 0)
        XCTAssertEqual(engine.bestStreak(for: habit, asOf: asOf), 0)
    }
}
