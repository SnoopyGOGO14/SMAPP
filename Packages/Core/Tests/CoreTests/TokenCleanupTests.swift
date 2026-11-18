// TokenCleanupTests — Block I6's pure bookkeeping, with Int stand-ins
// for the opaque tokens.

import XCTest
@testable import Core

final class TokenCleanupTests: XCTestCase {

    func testRemovesMissingTokensFromAllThreeLists() {
        let result = Core.TokenCleanup.cleanup(
            ordered: [1, 2, 3, 4],
            enabled: [1, 3],
            targets: [(1, 30), (2, 45), (4, 60)],
            available: [1, 3]
        )
        XCTAssertEqual(result.ordered, [1, 3])
        XCTAssertEqual(result.enabled, [1, 3])
        XCTAssertEqual(result.targets.map(\.token), [1])
        XCTAssertEqual(result.targets.first?.minutes, 30)
    }

    func testKeepsOrder() {
        let result = Core.TokenCleanup.cleanup(
            ordered: [5, 2, 9],
            enabled: [9, 2],
            targets: [],
            available: [2, 5, 9, 100]
        )
        XCTAssertEqual(result.ordered, [5, 2, 9])
        XCTAssertEqual(result.enabled, [9, 2])
    }

    func testEmptyAvailableClearsEverything() {
        let result = Core.TokenCleanup.cleanup(
            ordered: [1, 2],
            enabled: [1],
            targets: [(2, 30)],
            available: []
        )
        XCTAssertTrue(result.ordered.isEmpty)
        XCTAssertTrue(result.enabled.isEmpty)
        XCTAssertTrue(result.targets.isEmpty)
    }

    func testNothingToRemoveIsUnchanged() {
        let result = Core.TokenCleanup.cleanup(
            ordered: [1, 2],
            enabled: [2],
            targets: [(1, 15)],
            available: [2, 1]
        )
        XCTAssertEqual(result.ordered, [1, 2])
        XCTAssertEqual(result.enabled, [2])
        XCTAssertEqual(result.targets.map(\.token), [1])
    }
}
