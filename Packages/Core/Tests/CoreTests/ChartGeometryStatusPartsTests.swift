// ChartGeometryTests + StatusPartsTests — V3 and V4.

import XCTest
@testable import Core

final class ChartGeometryTests: XCTestCase {

    private let week = [44.0, 61.0, 38.0, 82.0, 49.0, 41.0, 58.0]

    func testMaximumUsesLargerOfTargetScaleAndTallestDay() {
        XCTAssertEqual(Core.ChartGeometry.maximum(targetMinutes: 60, tallestMinutes: 82), 90, accuracy: 0.001)
        XCTAssertEqual(Core.ChartGeometry.maximum(targetMinutes: 30, tallestMinutes: 82), 82, accuracy: 0.001)
    }

    func testOnlyOverTargetDaysExceedTheRule() {
        let maximum = Core.ChartGeometry.maximum(targetMinutes: 60, tallestMinutes: week.max() ?? 0)
        let rule = Core.ChartGeometry.ruleFraction(targetMinutes: 60, maximum: maximum)!
        let over = week.filter { Core.ChartGeometry.heightFraction(minutes: $0, maximum: maximum) > rule }
        XCTAssertEqual(over, [61.0, 82.0])
    }

    func testRuleAtTwoThirdsWhenWeekInsideTarget() {
        let maximum = Core.ChartGeometry.maximum(targetMinutes: 60, tallestMinutes: 58)
        XCTAssertEqual(Core.ChartGeometry.ruleFraction(targetMinutes: 60, maximum: maximum)!, 0.667, accuracy: 0.001)
    }

    func testNoTargetHidesRule() {
        XCTAssertNil(Core.ChartGeometry.ruleFraction(targetMinutes: nil, maximum: 100))
    }
}

final class StatusPartsTests: XCTestCase {

    func testZones() {
        XCTAssertEqual(Core.statusParts(usedMinutes: 31, targetMinutes: 60, amberFraction: 0.75),
                       StatusParts(word: "Comfortable", remainder: "29m left"))
        XCTAssertEqual(Core.statusParts(usedMinutes: 166, targetMinutes: 180, amberFraction: 0.75),
                       StatusParts(word: "Getting close", remainder: "14m left"))
        XCTAssertEqual(Core.statusParts(usedMinutes: 67, targetMinutes: 60, amberFraction: 0.75),
                       StatusParts(word: "Over target", remainder: "by 7m"))
    }

    func testNeutralIsEmpty() {
        let parts = Core.statusParts(usedMinutes: 14, targetMinutes: nil, amberFraction: 0.75)
        XCTAssertTrue(parts.isEmpty)
        XCTAssertEqual(parts, StatusParts(word: "", remainder: ""))
    }

    func testStatusLineJoinsWithOneSeparator() {
        XCTAssertEqual(Core.statusLine(usedMinutes: 166, targetMinutes: 180, amberFraction: 0.75),
                       "Getting close · 14m left")
    }
}
