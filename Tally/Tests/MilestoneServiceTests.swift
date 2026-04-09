//
//  MilestoneServiceTests.swift
//  Tally
//
//  Created by David Castaneda on 3/29/26.
//

import Foundation

import XCTest
@testable import Tally

final class MilestoneServiceTests: XCTestCase {

    private let milestoneService = MilestoneService()
    private let streakEngine = StreakEngine()
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
            emoji: "🔥",
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

    private func makeBuildLog(date: Date, count: Int = 1) -> HabitLog {
        HabitLog(
            date: date,
            completionCount: count,
            didSlip: false
        )
    }

    // MARK: - checkMilestone(streak:)

    func testCheckMilestone_zeroReturnsNil() {
        let milestone = milestoneService.checkMilestone(streak: 0)
        XCTAssertNil(milestone)
    }

    func testCheckMilestone_oneReturnsNil() {
        let milestone = milestoneService.checkMilestone(streak: 1)
        XCTAssertNil(milestone)
    }

    func testCheckMilestone_threeReturnsSpark() {
        let milestone = milestoneService.checkMilestone(streak: 3)

        XCTAssertNotNil(milestone)
        XCTAssertEqual(milestone?.name, "Spark")
        XCTAssertEqual(milestone?.threshold, 3)
        XCTAssertEqual(milestone?.animationType, .particleBurst)
    }

    func testCheckMilestone_sevenReturnsFire() {
        let milestone = milestoneService.checkMilestone(streak: 7)

        XCTAssertNotNil(milestone)
        XCTAssertEqual(milestone?.name, "Fire")
        XCTAssertEqual(milestone?.threshold, 7)
        XCTAssertEqual(milestone?.animationType, .flame)
    }

    func testCheckMilestone_fourteenReturnsLightning() {
        let milestone = milestoneService.checkMilestone(streak: 14)

        XCTAssertNotNil(milestone)
        XCTAssertEqual(milestone?.name, "Lightning")
        XCTAssertEqual(milestone?.threshold, 14)
        XCTAssertEqual(milestone?.animationType, .lightning)
    }

    func testCheckMilestone_thirtyReturnsSupernova() {
        let milestone = milestoneService.checkMilestone(streak: 30)

        XCTAssertNotNil(milestone)
        XCTAssertEqual(milestone?.name, "Supernova")
        XCTAssertEqual(milestone?.threshold, 30)
        XCTAssertEqual(milestone?.animationType, .supernova)
    }

    func testCheckMilestone_oneHundredReturnsLegend() {
        let milestone = milestoneService.checkMilestone(streak: 100)

        XCTAssertNotNil(milestone)
        XCTAssertEqual(milestone?.name, "Legend")
        XCTAssertEqual(milestone?.threshold, 100)
        XCTAssertEqual(milestone?.animationType, .legendBadge)
    }

    func testCheckMilestone_betweenThresholdsReturnsHighestReachedMilestone() {
        let milestone = milestoneService.checkMilestone(streak: 5)

        XCTAssertNotNil(milestone)
        XCTAssertEqual(milestone?.name, "Spark")
        XCTAssertEqual(milestone?.threshold, 3)
    }

    // MARK: - checkMilestone(previousBestStreak:newStreak:)

    func testCheckMilestone_newlyReachedThreeReturnsSpark() {
        let milestone = milestoneService.checkMilestone(previousBestStreak: 2, newStreak: 3)

        XCTAssertNotNil(milestone)
        XCTAssertEqual(milestone?.name, "Spark")
        XCTAssertEqual(milestone?.threshold, 3)
    }

    func testCheckMilestone_newlyReachedSevenReturnsFireNotSparkAgain() {
        let milestone = milestoneService.checkMilestone(previousBestStreak: 6, newStreak: 7)

        XCTAssertNotNil(milestone)
        XCTAssertEqual(milestone?.name, "Fire")
        XCTAssertEqual(milestone?.threshold, 7)
    }

    func testCheckMilestone_newlyReachedFourteenReturnsLightning() {
        let milestone = milestoneService.checkMilestone(previousBestStreak: 13, newStreak: 14)

        XCTAssertNotNil(milestone)
        XCTAssertEqual(milestone?.name, "Lightning")
        XCTAssertEqual(milestone?.threshold, 14)
    }

    func testCheckMilestone_newlyReachedThirtyReturnsSupernova() {
        let milestone = milestoneService.checkMilestone(previousBestStreak: 29, newStreak: 30)

        XCTAssertNotNil(milestone)
        XCTAssertEqual(milestone?.name, "Supernova")
        XCTAssertEqual(milestone?.threshold, 30)
    }

    func testCheckMilestone_newlyReachedOneHundredReturnsLegend() {
        let milestone = milestoneService.checkMilestone(previousBestStreak: 99, newStreak: 100)

        XCTAssertNotNil(milestone)
        XCTAssertEqual(milestone?.name, "Legend")
        XCTAssertEqual(milestone?.threshold, 100)
    }

    func testCheckMilestone_betweenThresholdsReturnsNilForNoNewMilestone() {
        let milestone = milestoneService.checkMilestone(previousBestStreak: 3, newStreak: 5)
        XCTAssertNil(milestone)
    }

    func testCheckMilestone_sameStreakTwiceDoesNotDuplicateTrigger() {
        let firstCall = milestoneService.checkMilestone(previousBestStreak: 2, newStreak: 3)
        let secondCall = milestoneService.checkMilestone(previousBestStreak: 3, newStreak: 3)

        XCTAssertEqual(firstCall?.name, "Spark")
        XCTAssertNil(secondCall)
    }

    func testCheckMilestone_lowerOrEqualNewStreakReturnsNil() {
        XCTAssertNil(milestoneService.checkMilestone(previousBestStreak: 7, newStreak: 7))
        XCTAssertNil(milestoneService.checkMilestone(previousBestStreak: 8, newStreak: 7))
    }

    func testCheckMilestone_largeJumpReturnsHighestNewlyReachedMilestone() {
        let milestone = milestoneService.checkMilestone(previousBestStreak: 2, newStreak: 15)

        XCTAssertNotNil(milestone)
        XCTAssertEqual(milestone?.name, "Lightning")
        XCTAssertEqual(milestone?.threshold, 14)
    }

    // MARK: - earnedMilestones(for:)

    func testEarnedMilestones_emptyHabitReturnsEmptyList() {
        let habit = makeBuildHabit(
            createdAt: makeDate(2026, 4, 1),
            logs: []
        )

        let milestones = milestoneService.earnedMilestones(for: habit, asOf: makeDate(2026, 4, 5))
        XCTAssertEqual(milestones, [])
    }

    func testEarnedMilestones_streakOfThreeReturnsSparkOnly() {
        let habit = makeBuildHabit(
            createdAt: makeDate(2026, 4, 1),
            logs: [
                makeBuildLog(date: makeDate(2026, 4, 1)),
                makeBuildLog(date: makeDate(2026, 4, 2)),
                makeBuildLog(date: makeDate(2026, 4, 3))
            ]
        )

        let milestones = milestoneService.earnedMilestones(for: habit, asOf: makeDate(2026, 4, 3))

        XCTAssertEqual(milestones.map(\.name), ["Spark"])
    }

    func testEarnedMilestones_streakOfFifteenReturnsSparkFireLightning() {
        let createdAt = makeDate(2026, 4, 1)
        let asOf = makeDate(2026, 4, 15)

        let logs = (1...15).map { day in
            makeBuildLog(date: makeDate(2026, 4, day))
        }

        let habit = makeBuildHabit(
            createdAt: createdAt,
            logs: logs
        )

        let milestones = milestoneService.earnedMilestones(for: habit, asOf: asOf)

        XCTAssertEqual(milestones.map(\.name), ["Spark", "Fire", "Lightning"])
        XCTAssertEqual(milestones.map(\.threshold), [3, 7, 14])
    }

    func testEarnedMilestones_usesBestStreakNotJustCurrentStreak() {
        let createdAt = makeDate(2026, 4, 1)
        let asOf = makeDate(2026, 4, 10)

        let logs = [
            makeBuildLog(date: makeDate(2026, 4, 1)),
            makeBuildLog(date: makeDate(2026, 4, 2)),
            makeBuildLog(date: makeDate(2026, 4, 3)),
            makeBuildLog(date: makeDate(2026, 4, 4)),
            makeBuildLog(date: makeDate(2026, 4, 5)),
            makeBuildLog(date: makeDate(2026, 4, 6)),
            makeBuildLog(date: makeDate(2026, 4, 7)),
            // gap on 4/8 breaks current streak
            makeBuildLog(date: makeDate(2026, 4, 9)),
            makeBuildLog(date: makeDate(2026, 4, 10))
        ]

        let habit = makeBuildHabit(
            createdAt: createdAt,
            logs: logs
        )

        let current = streakEngine.currentStreak(for: habit, asOf: asOf)
        let best = streakEngine.bestStreak(for: habit, asOf: asOf)
        let milestones = milestoneService.earnedMilestones(for: habit, asOf: asOf)

        XCTAssertEqual(current, 2)
        XCTAssertEqual(best, 7)
        XCTAssertEqual(milestones.map(\.name), ["Spark", "Fire"])
    }
}