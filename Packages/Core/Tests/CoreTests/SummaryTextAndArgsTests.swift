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

    func testPillIndexOfIsTheInverseOfPillDate() {
        // X1: the demo's chosen day maps back to its data set.
        for index in 0...6 {
            let pill = Core.SummaryPeriod.pillDate(index: index, weekStartsOn: 2, now: date("2026-11-25"), calendar: uk)
            XCTAssertEqual(
                Core.SummaryPeriod.pillIndexOf(date: pill, weekStartsOn: 2, now: date("2026-11-25"), calendar: uk),
                index
            )
        }
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

final class HourlyStatsTests: XCTestCase {

    func testBusiestHourAndSessions() {
        // Z3: TikTok's demo day — 21:00 peaks at 17 min; two hour
        // buckets reach 15 min (21 and 22).
        var hours = Array(repeating: 0.0, count: 24)
        hours[9] = 2
        hours[12] = 6
        hours[17] = 4
        hours[19] = 5
        hours[20] = 7
        hours[21] = 17
        hours[22] = 15
        hours[23] = 9 + 40.0 / 60
        let summary = Core.HourlyStats.summarize(hours: hours)
        XCTAssertEqual(summary.busiestHour, 21)
        XCTAssertEqual(summary.sessionsOver15, 2)
    }

    func testEmptyDay() {
        let summary = Core.HourlyStats.summarize(hours: Array(repeating: 0.0, count: 24))
        XCTAssertNil(summary.busiestHour)
        XCTAssertEqual(summary.sessionsOver15, 0)
    }

    func testHourLabels() {
        XCTAssertEqual(Core.HourlyStats.hourLabel(21), "9pm")
        XCTAssertEqual(Core.HourlyStats.hourLabel(0), "12am")
        XCTAssertEqual(Core.HourlyStats.hourLabel(12), "12pm")
        XCTAssertEqual(Core.HourlyStats.hourLabel(9), "9am")
        XCTAssertEqual(Core.HourlyStats.hourLabel(nil), "—")
    }

    func testDemoHourlyDayCoheres() {
        // Z3: the hourly demo day totals today's figure and peaks at 21.
        let day = Core.DemoSeries.hourlyDay
        XCTAssertEqual(day.count, 24)
        XCTAssertEqual(day.reduce(0, +), Core.DemoSeries.dailyMinutes[0] + 40.0 / 60, accuracy: 0.001)
        let stats = Core.HourlyStats.summarize(hours: day)
        XCTAssertEqual(stats.busiestHour, 21)
        XCTAssertEqual(stats.sessionsOver15, 2)
    }
}
