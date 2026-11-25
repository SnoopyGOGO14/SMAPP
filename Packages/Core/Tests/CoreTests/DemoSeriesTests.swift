// DemoSeriesTests — W4/X1/X5: one coherent demo data set. The Summary's
// daily total must equal Home's hero total, TikTok's weekly figure must
// equal the App detail weekly total (the design's series plus 40 s on
// today, W8), a chosen day's figures must differ from today's (X1), and
// every period must rank the apps in the daily order (X5).

import XCTest
@testable import Core

final class DemoSeriesTests: XCTestCase {

    func testDailyTotalMatchesHomeHero() {
        // Home's hero: 58 + 52 + 31 + 14 + 11 = 166 minutes (2h 46m).
        XCTAssertEqual(Core.DemoSeries.dailyTotal, 166, accuracy: 0.001)
    }

    func testDailyMinutesAreHomeFiveInPaletteOrder() {
        XCTAssertEqual(Core.DemoSeries.dailyMinutes, [58, 52, 31, 14, 11])
    }

    func testTikTokWeekIsTheApprovedMockWithFortySeconds() {
        // The design's App detail week: 44, 61, 38, 82, 49, 41, 58 —
        // with 40 s on today (W8).
        XCTAssertEqual(Core.DemoSeries.tikTokWeek.dropLast(), [44, 61, 38, 82, 49, 41])
        XCTAssertEqual(Core.DemoSeries.tikTokWeek.last ?? 0, 58 + 40.0 / 60, accuracy: 0.001)
    }

    func testWeekTotalCarriesSeconds() {
        // 373 minutes 40 seconds — the App detail period line reads
        // "0d 6h 13m 40s".
        XCTAssertEqual(Core.DemoSeries.weekTotal(index: 0) * 60, 373 * 60 + 40, accuracy: 0.01)
    }

    func testMonthTodayMatchesTheHeroFigure() {
        // W9: the month series ends on today's figure, so the hero is
        // identical across periods.
        let month = Core.DemoSeries.month(index: 0)
        XCTAssertEqual(month.last ?? 0, Core.DemoSeries.dailyMinutes[0] + 40.0 / 60, accuracy: 0.001)
    }

    func testMonthHasThirtyDays() {
        XCTAssertEqual(Core.DemoSeries.month(index: 0).count, 30)
        XCTAssertEqual(Core.DemoSeries.week(index: 0).count, 7)
    }

    // MARK: - X1: per-day figures

    func testTodayFiguresAreHomeFivePlusTikToksFortySeconds() {
        let today = Core.DemoSeries.dailyFigures(dayIndex: 6)
        XCTAssertEqual(today, [58 + 40.0 / 60, 52, 31, 14, 11])
    }

    func testChosenDayDiffersFromToday() {
        // X1: the data set for a non-today day must differ, so the
        // capture differs in content as well as in the pill.
        let day2 = Core.DemoSeries.dailyFigures(dayIndex: 2)
        let today = Core.DemoSeries.dailyFigures(dayIndex: 6)
        XCTAssertNotEqual(day2, today)
        XCTAssertEqual(day2, (0..<5).map { app in Core.DemoSeries.week(index: app)[2] })
    }

    // MARK: - X5: every period ranks the apps in the daily order

    func testWeeklyTotalsPreserveTheDailyOrder() {
        let daily = Core.DemoSeries.dailyMinutes
        for app in 0..<(daily.count - 1) {
            XCTAssertGreaterThan(
                Core.DemoSeries.weekTotal(index: app),
                Core.DemoSeries.weekTotal(index: app + 1),
                "weekly order broke between palette slots \(app) and \(app + 1)"
            )
        }
    }

    func testMonthlyTotalsPreserveTheDailyOrder() {
        let daily = Core.DemoSeries.dailyMinutes
        for app in 0..<(daily.count - 1) {
            XCTAssertGreaterThan(
                Core.DemoSeries.monthTotal(index: app),
                Core.DemoSeries.monthTotal(index: app + 1),
                "monthly order broke between palette slots \(app) and \(app + 1)"
            )
        }
    }
}
