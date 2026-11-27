// EdgeCaseTests — Part 5.1: the calendar and scale edges — leap day,
// year end, a week spanning two months, the clock-change days for
// every period, zero usage, one app, palette wrap, a 23-hour day, and
// the target extremes.

import XCTest
@testable import Core

final class CalendarEdgeTests: XCTestCase {

    let uk = Core.AppCalendar.uk()

    private func date(_ iso: String, hour: Int = 12) -> Date {
        let parts = iso.split(separator: "-").map { Int($0)! }
        var comps = DateComponents()
        comps.year = parts[0]; comps.month = parts[1]; comps.day = parts[2]
        comps.hour = hour
        return uk.date(from: comps)!
    }

    func testLeapDayIsAWholeDay() {
        let interval = Core.SummaryPeriod.daily(day: date("2028-02-29"))
            .interval(calendar: uk, now: date("2028-02-29"))
        XCTAssertEqual(interval.duration, 86_400, accuracy: 1)
        XCTAssertEqual(interval.start, date("2028-02-29", hour: 0))
    }

    func testYearEndMonthlySpansDecember() {
        let interval = Core.SummaryPeriod.monthly
            .interval(calendar: uk, now: date("2026-12-15"))
        XCTAssertEqual(interval.start, date("2026-12-01", hour: 0))
        XCTAssertEqual(interval.end, date("2027-01-01", hour: 0))
    }

    func testWeekSpanningTwoMonths() {
        // Monday 30 March 2026 to Sunday 5 April — one week, two months.
        let interval = Core.SummaryPeriod.weekly
            .interval(calendar: uk, weekStartsOn: 2, now: date("2026-04-02"))
        XCTAssertEqual(interval.start, date("2026-03-30", hour: 0))
        XCTAssertEqual(interval.end, date("2026-04-02"))
    }

    func testClockChangeDaysForEveryPeriod() {
        // 29 March 2026 (GMT→BST) and 25 October 2026 (BST→GMT).
        for now in [date("2026-03-29"), date("2026-10-25")] {
            let day = Core.SummaryPeriod.daily(day: nil).interval(calendar: uk, now: now)
            XCTAssertEqual(day.duration, 86_400, accuracy: 3_600 * 2)
            _ = Core.SummaryPeriod.weekly.interval(calendar: uk, weekStartsOn: 2, now: now)
            _ = Core.SummaryPeriod.monthly.interval(calendar: uk, now: now)
            // Fractions always stay in range on the odd-length days.
            let dayFraction = Core.PeriodProgress.dayFraction(now: now, calendar: uk)
            XCTAssertGreaterThanOrEqual(dayFraction, 0)
            XCTAssertLessThanOrEqual(dayFraction, 1)
        }
    }

    func testTwentyThreeHourDayFractionStaysInRange() {
        // The spring-forward day is 23 hours; the fraction must still
        // land in [0, 1] at every hour.
        for hour in stride(from: 0, through: 23, by: 3) {
            let fraction = Core.PeriodProgress.dayFraction(now: date("2026-03-29", hour: hour), calendar: uk)
            XCTAssertGreaterThanOrEqual(fraction, 0)
            XCTAssertLessThanOrEqual(fraction, 1)
        }
    }
}

final class ScaleEdgeTests: XCTestCase {

    func testZeroUsageRanksEmptyAndDonutEmpty() {
        XCTAssertTrue(Core.Ranking.rank(apps: [(0, 0), (1, 0)]).isEmpty)
        XCTAssertTrue(Core.donutSegments(apps: [(0, 0)]).isEmpty)
        let stats = Core.periodStats(dailyMinutes: [0, 0, 0], targetMinutes: 60)
        XCTAssertEqual(stats.dailyAverageMinutes, 0)
    }

    func testOneAppTakesTheWholeRing() {
        let segments = Core.donutSegments(apps: [(0, 600)])
        XCTAssertEqual(segments.count, 1)
        XCTAssertEqual(segments[0].endAngle - segments[0].startAngle, 360, accuracy: 0.01)
    }

    func testTwelveAppsWrapThePalette() {
        // Palette wraps at 8: position 12 maps to slot 4.
        XCTAssertEqual(Core.Palette.index(for: 12), 4)
        XCTAssertEqual(Core.Palette.index(for: 7), 7)
        XCTAssertEqual(Core.Palette.index(for: 8), 0)
        // Twelve apps still rank and share 100%.
        let apps = (0..<12).map { (position: $0, seconds: Double(12 - $0)) }
        let ranked = Core.Ranking.rank(apps: apps)
        XCTAssertEqual(ranked.count, 12)
        XCTAssertEqual(ranked.reduce(0) { $0 + $1.sharePercent }, 100, accuracy: 0.5)
    }

    func testTargetExtremes15MinutesAnd8Hours() {
        // Checkpoint thresholds at the smallest and largest targets.
        XCTAssertEqual(Core.Checkpoint.thresholdMinutes(percent: 25, targetMinutes: 15), 4)
        XCTAssertEqual(Core.Checkpoint.thresholdMinutes(percent: 100, targetMinutes: 15), 15)
        XCTAssertEqual(Core.Checkpoint.thresholdMinutes(percent: 150, targetMinutes: 480), 720)
        // 15-minute and 8-hour targets stay legal on the context grid.
        XCTAssertEqual(Core.ContextCodec.encode(targetMinutes: 15, amberPercent: 75), "homeTotal.t015.a75")
        XCTAssertEqual(Core.ContextCodec.encode(targetMinutes: 480, amberPercent: 75), "homeTotal.t480.a75")
    }
}
