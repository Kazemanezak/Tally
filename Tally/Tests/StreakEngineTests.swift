func testCurrentDailyBuildStreak_breaksAcrossMultiDayGapWhenAppWasNotOpened() {
    let createdAt = makeDate(2026, 4, 1)
    let asOf = makeDate(2026, 4, 5)

    let logs = [
        makeBuildLog(date: makeDate(2026, 4, 1), count: 1),
        makeBuildLog(date: makeDate(2026, 4, 2), count: 1),
        // 4/3 and 4/4 missing
        makeBuildLog(date: makeDate(2026, 4, 5), count: 1)
    ]

    let habit = makeBuildHabit(
        createdAt: createdAt,
        frequencyGoal: 1,
        period: .daily,
        logs: logs
    )

    let current = engine.currentStreak(for: habit, asOf: asOf)
    let best = engine.bestStreak(for: habit, asOf: asOf)

    XCTAssertEqual(current, 1)
    XCTAssertEqual(best, 2)
}

func testCurrentBreakStreak_countsAcrossMultiDayGapWithoutAppOpen() {
    let createdAt = makeDate(2026, 4, 1)
    let asOf = makeDate(2026, 4, 8)

    let habit = makeBreakHabit(createdAt: createdAt, logs: [])

    let current = engine.currentStreak(for: habit, asOf: asOf)
    XCTAssertEqual(current, 7)
}

func testCurrentBreakStreak_countsFromLastSlipAcrossGap() {
    let createdAt = makeDate(2026, 4, 1)
    let asOf = makeDate(2026, 4, 10)

    let logs = [
        makeSlipLog(date: makeDate(2026, 4, 6))
    ]

    let habit = makeBreakHabit(createdAt: createdAt, logs: logs)

    let current = engine.currentStreak(for: habit, asOf: asOf)
    XCTAssertEqual(current, 4)
}

func testMultipleLogsSameCalendarDayWithDifferentTimesAreGroupedTogether() {
    let createdAt = makeDate(2026, 4, 1)
    let asOf = makeDate(2026, 4, 2)

    let morning = calendar.date(bySettingHour: 1, minute: 15, second: 0, of: asOf)!
    let night = calendar.date(bySettingHour: 23, minute: 45, second: 0, of: asOf)!

    let logs = [
        makeBuildLog(date: morning, count: 1),
        makeBuildLog(date: night, count: 1)
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

func testCurrentWeeklyBuildStreak_breaksWhenEntireMissedWeekOccurs() {
    let createdAt = makeDate(2026, 3, 23)
    let asOf = makeDate(2026, 4, 13)

    let logs = [
        // Week of Mar 23 success
        makeBuildLog(date: makeDate(2026, 3, 24), count: 2),

        // Week of Mar 30 missed entirely

        // Week of Apr 6 success
        makeBuildLog(date: makeDate(2026, 4, 7), count: 2),

        // Week of Apr 13 success
        makeBuildLog(date: makeDate(2026, 4, 13), count: 2)
    ]

    let habit = makeBuildHabit(
        createdAt: createdAt,
        frequencyGoal: 2,
        period: .weekly,
        logs: logs
    )

    let current = engine.currentStreak(for: habit, asOf: asOf)
    let best = engine.bestStreak(for: habit, asOf: asOf)

    XCTAssertEqual(current, 2)
    XCTAssertEqual(best, 2)
}

func testDateHelpersUsesCalendarDayNotAbsoluteTimestamp() {
    let base = makeDate(2026, 4, 5)
    let early = calendar.date(bySettingHour: 0, minute: 5, second: 0, of: base)!
    let late = calendar.date(bySettingHour: 23, minute: 55, second: 0, of: base)!

    XCTAssertTrue(DateHelpers.isSameDay(early, late))
    XCTAssertEqual(DateHelpers.startOfDay(early), DateHelpers.startOfDay(late))
}