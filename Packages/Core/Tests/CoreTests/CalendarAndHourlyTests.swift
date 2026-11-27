// CalendarAndHourlyTests — the Summary interval edges (UK clock
// changes, leap day, year end, cross-month weeks) and the hourly
// statistics, split from SummaryTextAndArgsTests to keep both under
// 250 lines.

import XCTest
@testable import Core

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
