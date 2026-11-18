// DesignTests — Block C additions, covering the minimum list in
// 04-OVERNIGHT-TASKS.md. Expected values cross-checked against the
// approved mock-ups (design/reference/*.dc.html).

import XCTest
@testable import Core

final class DurationPartsTests: XCTestCase {

    func testZero() {
        let parts = DurationParts(seconds: 0)
        XCTAssertEqual(parts.line, "0d 0h 0m 0s")
        XCTAssertEqual(parts, DurationParts(days: 0, hours: 0, minutes: 0, seconds: 0))
    }

    func testUnderAMinute() {
        XCTAssertEqual(DurationParts(seconds: 59).line, "0d 0h 0m 59s")
    }

    func testMockValue() {
        XCTAssertEqual(DurationParts(seconds: 22_420).line, "0d 6h 13m 40s")
    }

    func testOverADay() {
        XCTAssertEqual(DurationParts(seconds: 93_784).line, "1d 2h 3m 4s")
    }
}

extension DurationParts {
    init(days: Int, hours: Int, minutes: Int, seconds: Int) {
        self.init(seconds: days * 86_400 + hours * 3_600 + minutes * 60 + seconds)
    }
}

final class BarGeometryTests: XCTestCase {

    func testOverallMockValues() {
        // 166 of 180: scale 240, fill 0.692, marker at 0.75.
        let bar = BarGeometry.overall(usedMinutes: 166, targetMinutes: 180)
        XCTAssertEqual(bar.fill, 0.692, accuracy: 0.001)
        XCTAssertEqual(bar.marker!, 0.75, accuracy: 0.001)
    }

    func testPerAppMockValues() {
        // 58 of 60: scale 90, fill 0.644, marker at 2/3.
        let bar = BarGeometry.perApp(usedMinutes: 58, targetMinutes: 60, largestAppMinutes: 58)
        XCTAssertEqual(bar.fill, 0.644, accuracy: 0.001)
        XCTAssertEqual(bar.marker!, 0.667, accuracy: 0.001)
    }

    func testOverScaleClamps() {
        let bar = BarGeometry.perApp(usedMinutes: 120, targetMinutes: 60, largestAppMinutes: 120)
        XCTAssertEqual(bar.fill, 1.0, accuracy: 0.0001)
        let overall = BarGeometry.overall(usedMinutes: 300, targetMinutes: 180)
        XCTAssertEqual(overall.fill, 1.0, accuracy: 0.0001)
    }

    func testNoTargetScalesAgainstLargestApp() {
        // Facebook in the mock: 14 min, no target, largest app 58 → ≈0.16, no marker.
        let bar = BarGeometry.perApp(usedMinutes: 14, targetMinutes: nil, largestAppMinutes: 58)
        XCTAssertEqual(bar.fill, 0.161, accuracy: 0.001)
        XCTAssertNil(bar.marker)
    }

    func testEmptyDayWithNoTarget() {
        let bar = BarGeometry.perApp(usedMinutes: 0, targetMinutes: nil, largestAppMinutes: 0)
        XCTAssertEqual(bar.fill, 0)
        XCTAssertNil(bar.marker)
    }
}

final class AppZoneTests: XCTestCase {

    func testZonesAgainstOwnTarget() {
        XCTAssertEqual(Core.appZone(usedMinutes: 58, targetMinutes: 60, amberFraction: 0.75), .amber)
        XCTAssertEqual(Core.appZone(usedMinutes: 52, targetMinutes: 45, amberFraction: 0.75), .red)
        XCTAssertEqual(Core.appZone(usedMinutes: 31, targetMinutes: 60, amberFraction: 0.75), .green)
        XCTAssertEqual(Core.appZone(usedMinutes: 14, targetMinutes: nil, amberFraction: 0.75), .neutral)
    }

    func testExactlyOnTargetIsAmber() {
        XCTAssertEqual(Core.appZone(usedMinutes: 60, targetMinutes: 60, amberFraction: 0.75), .amber)
    }
}

final class StatusLineTests: XCTestCase {

    func testMockLines() {
        XCTAssertEqual(Core.statusLine(usedMinutes: 166, targetMinutes: 180, amberFraction: 0.75), "Getting close · 14m left")
        XCTAssertEqual(Core.statusLine(usedMinutes: 58, targetMinutes: 60, amberFraction: 0.75), "Getting close · 2m left")
        XCTAssertEqual(Core.statusLine(usedMinutes: 31, targetMinutes: 60, amberFraction: 0.75), "Comfortable · 29m left")
        XCTAssertEqual(Core.statusLine(usedMinutes: 67, targetMinutes: 60, amberFraction: 0.75), "Over target · by 7m")
    }

    func testExactlyOnTarget() {
        XCTAssertEqual(Core.statusLine(usedMinutes: 60, targetMinutes: 60, amberFraction: 0.75), "Getting close · 0m left")
    }

    func testNeutralIsEmpty() {
        XCTAssertEqual(Core.statusLine(usedMinutes: 14, targetMinutes: nil, amberFraction: 0.75), "")
    }
}

final class DonutMathTests: XCTestCase {

    private let apps: [(position: Int, seconds: Double)] = [
        (0, 58 * 60), (1, 52 * 60), (2, 31 * 60), (3, 14 * 60), (4, 11 * 60)
    ]

    func testFractionsSumToOne() {
        let segments = Core.donutSegments(apps: apps)
        XCTAssertEqual(segments.count, 5)
        let sum = segments.map(\.fraction).reduce(0, +)
        XCTAssertEqual(sum, 1.0, accuracy: 0.0001)
    }

    func testOrderAndPalettePreserved() {
        let segments = Core.donutSegments(apps: apps)
        XCTAssertEqual(segments.map(\.paletteIndex), [0, 1, 2, 3, 4])
        // Largest first in input order: TikTok fraction 58/166.
        XCTAssertEqual(segments.first!.fraction, 58.0 / 166.0, accuracy: 0.0001)
    }

    func testAnglesStartAtNoonAndAreContiguous() {
        let segments = Core.donutSegments(apps: apps)
        XCTAssertEqual(segments.first!.startAngle, -90, accuracy: 0.0001)
        for (a, b) in zip(segments, segments.dropFirst()) {
            XCTAssertEqual(a.endAngle, b.startAngle, accuracy: 0.0001)
        }
        XCTAssertEqual(segments.last!.endAngle, 270, accuracy: 0.0001)
    }

    func testZeroTimeOmitted() {
        let segments = Core.donutSegments(apps: [(position: 0, seconds: 3480.0), (position: 2, seconds: 0.0), (position: 1, seconds: 3120.0)])
        XCTAssertEqual(segments.map(\.paletteIndex), [0, 1])
    }

    func testTotalZeroIsEmpty() {
        XCTAssertTrue(Core.donutSegments(apps: [(0, 0), (1, 0)]).isEmpty)
        XCTAssertTrue(Core.donutSegments(apps: []).isEmpty)
    }
}

final class PeriodStatsTests: XCTestCase {

    func testMockWeek() {
        let stats = Core.periodStats(dailyMinutes: [44, 61, 38, 82, 49, 41, 58], targetMinutes: 60)
        XCTAssertEqual(stats.dailyAverageMinutes, 53)
        XCTAssertEqual(stats.daysWithinTarget, 5)
        XCTAssertEqual(stats.daysCounted, 7)
        XCTAssertEqual(stats.longestDayMinutes, 82)
    }

    func testEmpty() {
        let stats = Core.periodStats(dailyMinutes: [], targetMinutes: 60)
        XCTAssertEqual(stats, PeriodStatsSummary(
            dailyAverageMinutes: 0, daysWithinTarget: 0, daysCounted: 0, longestDayMinutes: 0
        ))
    }
}

final class PaletteTests: XCTestCase {

    func testIndexWrapsAtEight() {
        XCTAssertEqual(Palette.index(for: 0), 0)
        XCTAssertEqual(Palette.index(for: 7), 7)
        XCTAssertEqual(Palette.index(for: 8), 0)
        XCTAssertEqual(Palette.index(for: 15), 7)
        XCTAssertEqual(Palette.index(for: -1), 7)
    }

    func testEightNames() {
        XCTAssertEqual(Palette.names.count, 8)
        XCTAssertEqual(Palette.count, 8)
    }
}
