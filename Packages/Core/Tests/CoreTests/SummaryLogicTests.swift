// Tests for the Summary page's Core logic (08 plan §8): Ranking,
// HoursFormat, PeriodProgress, SummaryPeriod, FocusState, and the
// DonutMath minimum-sweep extension.

import XCTest
@testable import Core

final class RankingTests: XCTestCase {

    private let six: [(position: Int, seconds: Double)] = [
        (0, 37.2 * 3600), (1, 29.1 * 3600), (2, 19.1 * 3600),
        (3, 8.0 * 3600), (4, 6.0 * 3600), (5, 0.5 * 3600)
    ]

    func testLargestFirstWithRanksAndShares() {
        let ranked = Core.Ranking.rank(apps: six)
        XCTAssertEqual(ranked.map(\.rank), [0, 1, 2, 3, 4, 5])
        XCTAssertEqual(ranked.first?.sharePercent ?? 0, 37.2, accuracy: 0.05)
        XCTAssertEqual(ranked.last?.sharePercent ?? 0, 0.5, accuracy: 0.05)
        let sum = ranked.map(\.sharePercent).reduce(0, +)
        XCTAssertEqual(sum, 100.0, accuracy: 0.15)
    }

    func testTieKeepsInputOrder() {
        let ranked = Core.Ranking.rank(apps: [(0, 100), (1, 100), (2, 300)])
        XCTAssertEqual(ranked.map(\.position), [2, 0, 1])
        XCTAssertEqual(ranked.map(\.rank), [0, 1, 2])
    }

    func testZeroTimeDropsOut() {
        let ranked = Core.Ranking.rank(apps: [(0, 0), (1, 50), (2, 0)])
        XCTAssertEqual(ranked.count, 1)
        XCTAssertEqual(ranked.first?.position, 1)
        XCTAssertEqual(ranked.first?.sharePercent ?? 0, 100, accuracy: 0.05)
    }

    func testEmpty() {
        XCTAssertTrue(Core.Ranking.rank(apps: []).isEmpty)
        XCTAssertTrue(Core.Ranking.rank(apps: [(0, 0)]).isEmpty)
    }
}

final class HoursFormatTests: XCTestCase {

    func testRules() {
        XCTAssertEqual(Core.HoursFormat.hours(minutes: 0), "0 min")
        XCTAssertEqual(Core.HoursFormat.hours(minutes: 5), "5 min")
        XCTAssertEqual(Core.HoursFormat.hours(minutes: 30), "0.5 hrs")
        XCTAssertEqual(Core.HoursFormat.hours(minutes: 318), "5.3 hrs")
        XCTAssertEqual(Core.HoursFormat.hours(minutes: 2220), "37 hrs")
    }

    func testWholeHoursDropTheDecimal() {
        // W5: "8 hrs", "6 hrs", exactly one is "1 hr"; "5.3 hrs" keeps
        // its decimal.
        XCTAssertEqual(Core.HoursFormat.hours(minutes: 480), "8 hrs")
        XCTAssertEqual(Core.HoursFormat.hours(minutes: 360), "6 hrs")
        XCTAssertEqual(Core.HoursFormat.hours(minutes: 60), "1 hr")
        XCTAssertEqual(Core.HoursFormat.hours(minutes: 421), "7 hrs")
    }

    func testTotalsFollowTheSameRule() {
        XCTAssertEqual(Core.HoursFormat.total(minutes: 5970), "99.5 hrs")
        // W5: whole totals drop the ".0".
        XCTAssertEqual(Core.HoursFormat.total(minutes: 2220), "37 hrs")
        XCTAssertEqual(Core.HoursFormat.total(minutes: 60), "1 hr")
    }
}

final class PeriodProgressTests: XCTestCase {

    private var utc: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    private func date(_ string: String) -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.date(from: string)!
    }

    func testMiddayIsHalf() {
        XCTAssertEqual(Core.PeriodProgress.dayFraction(now: date("2026-11-18 12:00"), calendar: utc), 0.5, accuracy: 0.001)
    }

    func testThursdayMiddayHalfwayThroughMondayWeek() {
        // Monday-start week: Thursday 12:00 is halfway.
        XCTAssertEqual(
            Core.PeriodProgress.weekFraction(weekStartsOn: 2, now: date("2026-11-19 12:00"), calendar: utc),
            0.5,
            accuracy: 0.01
        )
    }

    func testFirstAndLastInstant() {
        XCTAssertEqual(Core.PeriodProgress.dayFraction(now: date("2026-11-18 00:00"), calendar: utc), 0, accuracy: 0.0001)
        XCTAssertEqual(Core.PeriodProgress.dayFraction(now: date("2026-11-18 23:59"), calendar: utc), 0.999, accuracy: 0.001)
    }
}

final class SummaryPeriodTests: XCTestCase {

    private var utc: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    private func date(_ string: String) -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.date(from: string)!
    }

    func testDailyIntervalIsThatDay() {
        let interval = Core.SummaryPeriod.daily(day: date("2026-11-16 15:00"))
            .interval(calendar: utc, now: date("2026-11-18 12:00"))
        XCTAssertEqual(interval.start, date("2026-11-16 00:00"))
        XCTAssertEqual(interval.duration, 86_400, accuracy: 1)
    }

    func testWeeklySpansWeekToDate() {
        let interval = Core.SummaryPeriod.weekly
            .interval(calendar: utc, weekStartsOn: 2, now: date("2026-11-19 12:00"))
        // Monday-start week: Monday 16 Nov → Thursday 19 Nov.
        XCTAssertEqual(interval.start, date("2026-11-16 00:00"))
        XCTAssertEqual(interval.end, date("2026-11-19 12:00"))
    }

    func testMonthlyIsTheWholeCalendarMonth() {
        // Monthly filters the full month; days after `now` simply return
        // no data. (Weekly is week-to-date by contrast.)
        let interval = Core.SummaryPeriod.monthly
            .interval(calendar: utc, now: date("2026-11-19 12:00"))
        XCTAssertEqual(interval.start, date("2026-11-01 00:00"))
        XCTAssertEqual(interval.end, date("2026-12-01 00:00"))
    }

    func testTodayPillIndexAndFuturePills() {
        // Thursday 19 Nov, Monday start: today is pill 3; pills 4, 5, 6 are future.
        let daily = Core.SummaryPeriod.daily(day: nil)
        XCTAssertEqual(daily.todayPillIndex(weekStartsOn: 2, now: date("2026-11-19 12:00"), calendar: utc), 3)
        XCTAssertEqual(
            daily.futurePillIndexes(weekStartsOn: 2, now: date("2026-11-19 12:00"), calendar: utc),
            [4, 5, 6]
        )
    }

    func testPillDate() {
        let pill = Core.SummaryPeriod.pillDate(index: 2, weekStartsOn: 2, now: date("2026-11-19 12:00"), calendar: utc)
        XCTAssertEqual(pill, date("2026-11-18 00:00"))
    }

    func testRoundTrip() {
        XCTAssertEqual(Core.SummaryPeriod.from(rawValue: "monthly"), .monthly)
    }
}

final class FocusStateTests: XCTestCase {

    func testTapSetsFocus() {
        XCTAssertEqual(Core.FocusState.next(current: nil, tapped: 0), 0)
        XCTAssertEqual(Core.FocusState.next(current: 0, tapped: 1), 1)
    }

    func testTapSameClears() {
        XCTAssertNil(Core.FocusState.next(current: 2, tapped: 2))
    }

    func testTapOutsideClears() {
        XCTAssertNil(Core.FocusState.next(current: 2, tapped: nil))
    }

    func testPeriodChangeKeepsOnlyIfPresent() {
        XCTAssertEqual(Core.FocusState.afterPeriodChange(current: 1, present: [0, 1, 2]), 1)
        XCTAssertNil(Core.FocusState.afterPeriodChange(current: 3, present: [0, 1, 2]))
        XCTAssertNil(Core.FocusState.afterPeriodChange(current: nil, present: [0, 1]))
    }
}

final class DonutMinSweepTests: XCTestCase {

    func testTinyShareStillVisible() {
        // A 0.1% share (0.36°) is lifted to the 1.5° floor, then the
        // whole ring is renormalised, which shrinks it a hair below
        // exactly 1.5° — still clearly visible.
        let apps: [(position: Int, seconds: Double)] = [(0, 999.0), (1, 1.0)]
        let segments = Core.donutSegments(apps: apps)
        let sweep = segments.last!.endAngle - segments.last!.startAngle
        XCTAssertGreaterThanOrEqual(sweep, 1.4)
        XCTAssertLessThanOrEqual(sweep, 1.6)
    }

    func testTotalStays360() {
        let apps: [(position: Int, seconds: Double)] = [
            (0, 37.2), (1, 29.1), (2, 19.1), (3, 8.0), (4, 6.0), (5, 0.5)
        ]
        let segments = Core.donutSegments(apps: apps)
        let sweep = segments.map { $0.endAngle - $0.startAngle }.reduce(0, +)
        XCTAssertEqual(sweep, 360.0, accuracy: 0.001)
        let fractions = segments.map(\.fraction).reduce(0, +)
        XCTAssertEqual(fractions, 1.0, accuracy: 0.0001)
    }
}
