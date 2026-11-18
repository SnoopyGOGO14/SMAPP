// AlertLedgerTests — F4 rules: repeat suppressed; new interval sends;
// 100 after 75 sends; 75 after 100 in the same interval suppressed.

import XCTest
@testable import Core

final class AlertLedgerTests: XCTestCase {

    private let day = Date(timeIntervalSince1970: 1_760_000_000)

    func testFirstAlertSends() {
        XCTAssertTrue(Core.AlertLedger.shouldSend(last: nil, interval: day, percent: 75))
    }

    func testRepeatSuppressed() {
        let last = Core.AlertRecord(intervalStart: day, percent: 75)
        XCTAssertFalse(Core.AlertLedger.shouldSend(last: last, interval: day, percent: 75))
    }

    func testNextIntervalSendsAgain() {
        let nextDay = day.addingTimeInterval(86_400)
        let last = Core.AlertRecord(intervalStart: day, percent: 100)
        XCTAssertTrue(Core.AlertLedger.shouldSend(last: last, interval: nextDay, percent: 75))
    }

    func testHigherPercentSends() {
        let last = Core.AlertRecord(intervalStart: day, percent: 75)
        XCTAssertTrue(Core.AlertLedger.shouldSend(last: last, interval: day, percent: 100))
    }

    func testLowerPercentAfterHigherSuppressed() {
        let last = Core.AlertRecord(intervalStart: day, percent: 100)
        XCTAssertFalse(Core.AlertLedger.shouldSend(last: last, interval: day, percent: 75))
    }
}
