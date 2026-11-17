// Placeholder test so `swift test` has something to run from Session 0.
// Session 1 replaces this with the real Core test suite.

import XCTest
@testable import Core

final class CoreTests: XCTestCase {
    func testVersionPlaceholder() {
        XCTAssertFalse(CoreVersion.current.isEmpty)
    }
}
