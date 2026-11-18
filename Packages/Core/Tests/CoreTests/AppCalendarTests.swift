// AppCalendarTests — the UK day tracker (Foundation, Europe/London).

import XCTest
@testable import Core

final class AppCalendarTests: XCTestCase {

    func testLondonZoneAvailable() {
        XCTAssertTrue(Core.AppCalendar.londonZoneAvailable)
    }

    func testUkCalendarIsLondonAndGregorian() {
        let calendar = Core.AppCalendar.uk()
        XCTAssertEqual(calendar.timeZone.identifier, "Europe/London")
        XCTAssertEqual(calendar.identifier, .gregorian)
    }

    func testTodayPillFollowsUkDayNotDeviceDay() {
        // 2026-11-18 21:30 London is 2026-11-19 03:30 in Sydney — the UK
        // calendar must call it Wednesday (the 18th), not Thursday.
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Europe/London")
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let eveningInLondon = formatter.date(from: "2026-11-18 21:30")!

        let uk = Core.AppCalendar.uk()
        let sydney = Calendar(identifier: .gregorian)
        sydney.timeZone = TimeZone(identifier: "Australia/Sydney")!

        XCTAssertEqual(uk.component(.day, from: eveningInLondon), 18)
        XCTAssertEqual(uk.component(.weekday, from: eveningInLondon), 4) // Wednesday
        XCTAssertEqual(sydney.component(.day, from: eveningInLondon), 19)
    }

    func testSummaryPillsUseUkCalendar() {
        let uk = Core.AppCalendar.uk()
        // Wednesday 18 Nov 2026, Monday-start week → pill index 2.
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Europe/London")
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let wednesday = formatter.date(from: "2026-11-18 12:00")!

        let daily = Core.SummaryPeriod.daily(day: nil)
        XCTAssertEqual(daily.todayPillIndex(weekStartsOn: 2, now: wednesday, calendar: uk), 2)
        XCTAssertEqual(
            daily.futurePillIndexes(weekStartsOn: 2, now: wednesday, calendar: uk),
            [3, 4, 5, 6]
        )
    }
}
