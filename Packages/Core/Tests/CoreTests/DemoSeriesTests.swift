// DemoSeriesTests — W4: one coherent demo data set. The Summary's
// daily total must equal Home's hero total (2h 46m), and TikTok's
// weekly figure must equal the App detail weekly total (the design's
// series plus 40 s on today, W8).

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
}
