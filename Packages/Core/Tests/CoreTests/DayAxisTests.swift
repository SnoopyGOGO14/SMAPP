// DayAxisTests — F3: ids unique for 7 and 31 days; labels may repeat;
// month label positions are days 1, 8, 15, 22, 29.

import XCTest
@testable import Core

final class DayAxisTests: XCTestCase {

    func testWeekIdsUnique() {
        let ids = Core.DayAxis.ids(count: 7)
        XCTAssertEqual(ids.count, 7)
        XCTAssertEqual(Set(ids).count, 7)
    }

    func testMonthIdsUnique() {
        let ids = Core.DayAxis.ids(count: 31)
        XCTAssertEqual(ids.count, 31)
        XCTAssertEqual(Set(ids).count, 31)
    }

    func testEmpty() {
        XCTAssertTrue(Core.DayAxis.ids(count: 0).isEmpty)
        XCTAssertTrue(Core.DayAxis.labelIndexes(count: 0).isEmpty)
    }

    func testWeekLabelsAllPositions() {
        XCTAssertEqual(Core.DayAxis.labelIndexes(count: 7), Set(0...6))
    }

    func testMonthLabelPositions() {
        // W9: three labels only (1, 15, 29) — five truncated at 30 slots.
        XCTAssertEqual(Core.DayAxis.labelIndexes(count: 31), [0, 14, 28])
        XCTAssertEqual(Core.DayAxis.labelIndexes(count: 28), [0, 14])
        XCTAssertEqual(Core.DayAxis.labelIndexes(count: 30), [0, 14, 28])
    }

    func testLabelsMayRepeat() {
        let initials = ["S", "M", "T", "W", "T", "F", "S"]
        XCTAssertEqual(Core.DayAxis.label(for: 0, inWeek: true, weekdayInitials: initials, weekdayIndex: 0), "S")
        XCTAssertEqual(Core.DayAxis.label(for: 3, inWeek: true, weekdayInitials: initials, weekdayIndex: 3), "W")
        // Tuesday and Thursday share "T" — labels repeat, ids do not.
        XCTAssertEqual(Core.DayAxis.label(for: 1, inWeek: true, weekdayInitials: initials, weekdayIndex: 2), "T")
        XCTAssertEqual(Core.DayAxis.label(for: 1, inWeek: true, weekdayInitials: initials, weekdayIndex: 4), "T")
    }

    func testMonthLabelIsDayNumber() {
        XCTAssertEqual(Core.DayAxis.label(for: 0, inWeek: false, weekdayInitials: [], weekdayIndex: 0), "1")
        XCTAssertEqual(Core.DayAxis.label(for: 14, inWeek: false, weekdayInitials: [], weekdayIndex: 0), "15")
        XCTAssertEqual(Core.DayAxis.label(for: 28, inWeek: false, weekdayInitials: [], weekdayIndex: 0), "29")
        XCTAssertEqual(Core.DayAxis.label(for: 3, inWeek: false, weekdayInitials: [], weekdayIndex: 0), "")
    }
}
