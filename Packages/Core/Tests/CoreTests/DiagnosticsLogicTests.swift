// DiagnosticsLogicTests — Part 1.4: the verdict rules and the copy
// report as pure functions.

import XCTest
@testable import Core

final class DiagnosticsLogicTests: XCTestCase {

    func testAccessRule() {
        XCTAssertEqual(Core.DiagnosticsLogic.accessStatus(approved: true, denied: false), .pass)
        XCTAssertEqual(Core.DiagnosticsLogic.accessStatus(approved: false, denied: true), .fail)
        XCTAssertEqual(Core.DiagnosticsLogic.accessStatus(approved: nil, denied: false), .unknown)
    }

    func testSelectionRule() {
        XCTAssertEqual(Core.DiagnosticsLogic.selectionStatus(chosen: 5, decoded: true), .pass)
        XCTAssertEqual(Core.DiagnosticsLogic.selectionStatus(chosen: 0, decoded: true), .fail)
        XCTAssertEqual(Core.DiagnosticsLogic.selectionStatus(chosen: 5, decoded: false), .fail)
    }

    func testAppGroupAndMonitoringRules() {
        XCTAssertEqual(Core.DiagnosticsLogic.appGroupStatus(echo: true), .pass)
        XCTAssertEqual(Core.DiagnosticsLogic.appGroupStatus(echo: false), .fail)
        XCTAssertEqual(Core.DiagnosticsLogic.monitoringStatus(activities: 2, error: nil), .pass)
        XCTAssertEqual(Core.DiagnosticsLogic.monitoringStatus(activities: 0, error: nil), .unknown)
        XCTAssertEqual(Core.DiagnosticsLogic.monitoringStatus(activities: 2, error: "boom"), .fail)
    }

    func testNotificationAndEchoRules() {
        XCTAssertEqual(Core.DiagnosticsLogic.notificationStatus(authorized: true, denied: false), .pass)
        XCTAssertEqual(Core.DiagnosticsLogic.notificationStatus(authorized: false, denied: true), .fail)
        XCTAssertEqual(Core.DiagnosticsLogic.notificationStatus(authorized: nil, denied: false), .unknown)
        XCTAssertEqual(Core.DiagnosticsLogic.extensionEchoStatus(timestampMatches: true), .pass)
        XCTAssertEqual(Core.DiagnosticsLogic.extensionEchoStatus(timestampMatches: false), .fail)
        XCTAssertEqual(Core.DiagnosticsLogic.extensionEchoStatus(timestampMatches: nil), .unknown)
    }

    func testReportListsHostFactsAndExtensionBlanks() {
        let facts = Core.DiagnosticsLogic.HostFacts(
            accessApproved: true,
            accessDenied: false,
            chosenApps: 5,
            enabledApps: 5,
            perAppTargets: 4,
            selectionDecoded: true,
            appGroupEcho: true,
            monitoringActivities: 1,
            monitoringError: nil,
            lastCheckpoint: "2026-11-27 09:00 pct.75",
            notificationsAuthorized: true,
            notificationsDenied: false,
            appVersion: "1.0",
            commit: "dev"
        )
        let report = Core.DiagnosticsLogic.report(facts: facts, hostTimestamp: "12:00:00")
        XCTAssertTrue(report.contains("[PASS] Screen Time access"))
        XCTAssertTrue(report.contains("5 chosen, 5 enabled, 4 per-app targets"))
        XCTAssertTrue(report.contains("host wrote 12:00:00"))
        XCTAssertTrue(report.contains("[____] Taps in report: counter rose? Y/N"))
        XCTAssertTrue(report.contains("last checkpoint: 2026-11-27 09:00 pct.75"))
        XCTAssertTrue(report.contains("1.0 (dev)"))
    }
}
