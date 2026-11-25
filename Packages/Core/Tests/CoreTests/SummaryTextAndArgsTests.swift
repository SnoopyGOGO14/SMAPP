// SummaryTextAndArgsTests — B3: the Summary centre lines (focus on
// and off, every period label), the demo-argument parser (valid,
// invalid, silent-fallthrough protection), and Summary intervals at
// UK week/month edges across both clock changes.

import XCTest
@testable import Core

final class SummaryTextTests: XCTestCase {

    func testUnfocusedCentrePerPeriod() {
        // (label, total minutes) for daily, weekly, monthly — the
        // third line is the top app in every case.
        for (label, minutes) in [("daily", 166.0), ("weekly", 99.5 * 60), ("monthly", 148.0 * 60)] {
            let lines = Core.SummaryText.centre(
                periodLabel: label,
                totalMinutes: minutes,
                top: (name: "TikTok", minutes: 2220),
                focused: nil
            )
            XCTAssertEqual(lines.label, label)
            XCTAssertEqual(lines.value, Core.HoursFormat.total(minutes: minutes))
            XCTAssertTrue(lines.third.hasPrefix("TIKTOK "), "\(label): \(lines.third)")
        }
    }

    func testFocusedCentre() {
        let lines = Core.SummaryText.centre(
            periodLabel: "weekly",
            totalMinutes: 5960,
            top: (name: "TikTok", minutes: 2220),
            focused: (name: "WhatsApp", minutes: 1740, sharePercent: 29.15)
        )
        XCTAssertEqual(lines.label, "WhatsApp")
        // HoursFormat: 10 h and over → whole hours.
        XCTAssertEqual(lines.value, "29 hrs")
        XCTAssertEqual(lines.third, "29.1% OF TOTAL")
    }

    func testFocusedOverTenHoursDecimal() {
        let lines = Core.SummaryText.centre(
            periodLabel: "monthly",
            totalMinutes: 500,
            top: nil,
            focused: (name: "X", minutes: 620, sharePercent: 8.2)
        )
        // W5: whole hours drop the decimal.
        XCTAssertEqual(lines.value, "10.3 hrs")
        XCTAssertEqual(lines.third, "8.2% OF TOTAL")
    }

    func testEmptyRing() {
        let lines = Core.SummaryText.centre(
            periodLabel: "weekly",
            totalMinutes: 0,
            top: nil,
            focused: nil
        )
        XCTAssertEqual(lines.third, "")
    }
}

final class DemoArgumentsTests: XCTestCase {

    func testFullArgumentList() {
        let parsed = Core.DemoArguments.parse([
            "-demo", "-screen", "summary", "-period", "weekly",
            "-focus", "1", "-state", "over", "-sheet", "target", "-card", "2"
        ])
        XCTAssertTrue(parsed.isEnabled)
        XCTAssertEqual(parsed.screen, "summary")
        XCTAssertEqual(parsed.period, "weekly")
        XCTAssertEqual(parsed.focus, 1)
        XCTAssertEqual(parsed.state, "over")
        XCTAssertEqual(parsed.sheet, "target")
        XCTAssertEqual(parsed.card, 2)
        XCTAssertTrue(parsed.invalid.isEmpty)
    }

    func testInvalidStateIsReportedNotSwallowed() {
        let parsed = Core.DemoArguments.parse(["-demo", "-screen", "home", "-state", "overr"])
        XCTAssertEqual(parsed.state, nil)
        XCTAssertEqual(parsed.invalid, ["state=overr"])
    }

    func testInvalidPeriodAndFocusAndCard() {
        let parsed = Core.DemoArguments.parse([
            "-demo", "-period", "yearly", "-focus", "0", "-card", "9"
        ])
        XCTAssertEqual(parsed.period, nil)
        XCTAssertEqual(parsed.focus, nil)
        XCTAssertEqual(parsed.card, nil)
        XCTAssertEqual(parsed.invalid, ["period=yearly", "focus=0", "card=9"])
    }

    func testUnknownFlagsIgnoredAndMissingValuesSafe() {
        let parsed = Core.DemoArguments.parse(["-demo", "-screen", "home", "-other", "x", "-state"])
        XCTAssertEqual(parsed.screen, "home")
        XCTAssertEqual(parsed.state, nil)
        XCTAssertTrue(parsed.invalid.isEmpty)
    }

    func testWithoutDemoFlagNothingIsEnabled() {
        // The parser still reads the flags, but isEnabled gates use in
        // DemoMode — without -demo none of this takes effect.
        let parsed = Core.DemoArguments.parse(["-screen", "home"])
        XCTAssertFalse(parsed.isEnabled)
        XCTAssertEqual(parsed.screen, "home")
    }
}

final class SummaryIntervalEdgeTests: XCTestCase {

    /// Europe/London: 29 March 2026, 01:00 GMT → 02:00 BST (clock
    /// forward); 25 October 2026, 02:00 BST → 01:00 GMT (clock back).
    let uk = Core.AppCalendar.uk()

    private func date(_ iso: String, hour: Int = 12, minute: Int = 0) -> Date {
        // "2026-03-29" style; interpreted in the UK zone.
        let parts = iso.split(separator: "-").map { Int($0)! }
        var comps = DateComponents()
        comps.year = parts[0]; comps.month = parts[1]; comps.day = parts[2]
        comps.hour = hour; comps.minute = minute
        return uk.date(from: comps)!
    }

    func testWeeklyIntervalStartsMondayLondonAcrossMarchChange() {
        // Friday 27 March 12:00 GMT → week started Monday 23 March 00:00 GMT.
        let interval = Core.SummaryPeriod.weekly
            .interval(calendar: uk, weekStartsOn: 2, now: date("2026-03-27"))
        XCTAssertEqual(interval.start, date("2026-03-23", hour: 0, minute: 0))
        // Wednesday 1 April 12:00 BST → week started Monday 30 March 00:00 BST
        // (the day *after* the change).
        let after = Core.SummaryPeriod.weekly
            .interval(calendar: uk, weekStartsOn: 2, now: date("2026-04-01"))
        XCTAssertEqual(after.start, date("2026-03-30", hour: 0, minute: 0))
        // Sunday 29 March 12:00 (BST, the change day itself) still
        // belongs to the week that began Monday 23 March.
        let changeDay = Core.SummaryPeriod.weekly
            .interval(calendar: uk, weekStartsOn: 2, now: date("2026-03-29"))
        XCTAssertEqual(changeDay.start, date("2026-03-23", hour: 0, minute: 0))
    }

    func testMonthlyMarchLosesAnHour() {
        // March 2026: 31 days minus the spring-forward hour.
        let interval = Core.SummaryPeriod.monthly
            .interval(calendar: uk, now: date("2026-03-15"))
        XCTAssertEqual(interval.start, date("2026-03-01", hour: 0, minute: 0))
        XCTAssertEqual(interval.end, date("2026-04-01", hour: 0, minute: 0))
        XCTAssertEqual(interval.duration, 31 * 86_400 - 3_600, accuracy: 1)
    }

    func testMonthlyOctoberGainsAnHour() {
        // October 2026: 31 days plus the fall-back hour.
        let interval = Core.SummaryPeriod.monthly
            .interval(calendar: uk, now: date("2026-10-15"))
        XCTAssertEqual(interval.start, date("2026-10-01", hour: 0, minute: 0))
        XCTAssertEqual(interval.end, date("2026-11-01", hour: 0, minute: 0))
        XCTAssertEqual(interval.duration, 31 * 86_400 + 3_600, accuracy: 1)
    }

    func testWeeklyOctoberChangeDayStillStartsMonday() {
        // Sunday 25 October 12:00 (after the 02:00→01:00 change) is in
        // the week that began Monday 19 October.
        let interval = Core.SummaryPeriod.weekly
            .interval(calendar: uk, weekStartsOn: 2, now: date("2026-10-25"))
        XCTAssertEqual(interval.start, date("2026-10-19", hour: 0, minute: 0))
    }

    func testMonthlyFebruaryNonLeap() {
        let interval = Core.SummaryPeriod.monthly
            .interval(calendar: uk, now: date("2027-02-10"))
        XCTAssertEqual(interval.start, date("2027-02-01", hour: 0, minute: 0))
        XCTAssertEqual(interval.end, date("2027-03-01", hour: 0, minute: 0))
        XCTAssertEqual(interval.duration, 28 * 86_400, accuracy: 1)
    }
}
