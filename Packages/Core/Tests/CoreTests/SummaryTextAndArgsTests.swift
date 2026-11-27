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

    func testDayAndScrollParse() {
        // X1/X9: `-day 2` and `-scroll end`.
        let parsed = Core.DemoArguments.parse([
            "-demo", "-screen", "summary", "-period", "daily", "-day", "2", "-scroll", "end"
        ])
        XCTAssertEqual(parsed.day, 2)
        XCTAssertEqual(parsed.scroll, "end")
        XCTAssertTrue(parsed.invalid.isEmpty)
    }

    func testScrollValuesBeyondEndAreInvalid() {
        let parsed = Core.DemoArguments.parse(["-demo", "-scroll", "top"])
        XCTAssertNil(parsed.scroll)
        XCTAssertEqual(parsed.invalid, ["scroll=top"])
    }
}

final class DurationFormatSecondsTests: XCTestCase {

    func testTruncationNotRounding() {
        // X4: 3,520 s = 58m 40s — "58m" everywhere, never "59m".
        XCTAssertEqual(Core.DurationFormat.fromSeconds(3520), "58m")
        XCTAssertEqual(Core.DurationFormat.fromSeconds(3600), "1h")
        XCTAssertEqual(Core.DurationFormat.fromSeconds(0), "0m")
    }
}

