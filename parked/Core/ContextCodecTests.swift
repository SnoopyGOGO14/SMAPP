// ContextCodecTests — Part 2.2: the App Group fallback channel and the
// summary focus context family.

import XCTest
@testable import Core

final class ContextCodecTests: XCTestCase {

    func testEncodeDecodeRoundTrip() {
        let name = Core.ContextCodec.encode(targetMinutes: 180, amberPercent: 75)
        XCTAssertEqual(name, "homeTotal.t180.a75")
        let decoded = Core.ContextCodec.decode(name ?? "")
        XCTAssertEqual(decoded?.targetMinutes, 180)
        XCTAssertEqual(decoded?.amberPercent, 75)
    }

    func testOffGridValuesRejected() {
        XCTAssertNil(Core.ContextCodec.encode(targetMinutes: 10, amberPercent: 75))
        XCTAssertNil(Core.ContextCodec.encode(targetMinutes: 181, amberPercent: 75))
        XCTAssertNil(Core.ContextCodec.encode(targetMinutes: 8 * 60 + 15, amberPercent: 75))
        XCTAssertNil(Core.ContextCodec.encode(targetMinutes: 180, amberPercent: 76))
        XCTAssertNil(Core.ContextCodec.decode("homeTotal.t181.a75"))
        XCTAssertNil(Core.ContextCodec.decode("homeTotal.t180.a76"))
        XCTAssertNil(Core.ContextCodec.decode("summary.f3"))
        XCTAssertNil(Core.ContextCodec.decode("homeTotal"))
    }

    func testTargetStepsCover15MinutesTo8Hours() {
        let steps = Core.ContextCodec.targetSteps
        XCTAssertEqual(steps.first, 15)
        XCTAssertEqual(steps.last, 480)
        XCTAssertEqual(steps.count, 32)
        XCTAssertEqual(steps, steps.sorted())
    }

    func testEveryFallbackNameDecodes() {
        for name in Core.ContextCodec.fallbackContextNames {
            let decoded = Core.ContextCodec.decode(name)
            XCTAssertEqual(decoded?.amberPercent, 75, name)
        }
        XCTAssertEqual(Core.ContextCodec.fallbackContextNames.count, 32)
    }

    func testSummaryFocusContexts() {
        XCTAssertEqual(Core.ContextCodec.summaryFocusContext(focus: 3), "summary.f3")
        XCTAssertNil(Core.ContextCodec.summaryFocusContext(focus: 8))
        XCTAssertEqual(Core.ContextCodec.summaryFocus(from: "summary.f7"), 7)
        XCTAssertNil(Core.ContextCodec.summaryFocus(from: "summary.f8"))
        XCTAssertNil(Core.ContextCodec.summaryFocus(from: "summary.weekly"))
    }
}
