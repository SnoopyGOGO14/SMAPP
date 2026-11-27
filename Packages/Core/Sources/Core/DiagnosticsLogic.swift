// DiagnosticsLogic — the Gate A checklist's rules and report text
// (12-NEXT-WITHOUT-CLOUD Part 1): every check's PASS / FAIL / UNKNOWN
// verdict and the plain-text report the phone copies out. Pure Core —
// tested; the debug Diagnostics screen and the extension-drawn report
// both feed it.

import Foundation

public enum DiagnosticsLogic {

    public enum Status: String, Equatable {
        case pass = "PASS"
        case fail = "FAIL"
        case unknown = "UNKNOWN"
    }

    /// What the host knows. Extension-drawn values are read off the
    /// screen by the person and appear in the report as blanks.
    public struct HostFacts: Equatable {
        public var accessApproved: Bool?
        public var accessDenied: Bool
        public var chosenApps: Int
        public var enabledApps: Int
        public var perAppTargets: Int
        public var selectionDecoded: Bool
        public var appGroupEcho: Bool
        public var monitoringActivities: Int
        public var monitoringError: String?
        public var lastCheckpoint: String?
        public var notificationsAuthorized: Bool?
        public var notificationsDenied: Bool
        public var appVersion: String
        public var commit: String

        public init(
            accessApproved: Bool?,
            accessDenied: Bool,
            chosenApps: Int,
            enabledApps: Int,
            perAppTargets: Int,
            selectionDecoded: Bool,
            appGroupEcho: Bool,
            monitoringActivities: Int,
            monitoringError: String?,
            lastCheckpoint: String?,
            notificationsAuthorized: Bool?,
            notificationsDenied: Bool,
            appVersion: String,
            commit: String
        ) {
            self.accessApproved = accessApproved
            self.accessDenied = accessDenied
            self.chosenApps = chosenApps
            self.enabledApps = enabledApps
            self.perAppTargets = perAppTargets
            self.selectionDecoded = selectionDecoded
            self.appGroupEcho = appGroupEcho
            self.monitoringActivities = monitoringActivities
            self.monitoringError = monitoringError
            self.lastCheckpoint = lastCheckpoint
            self.notificationsAuthorized = notificationsAuthorized
            self.notificationsDenied = notificationsDenied
            self.appVersion = appVersion
            self.commit = commit
        }
    }

    // MARK: - Verdict rules

    public static func accessStatus(approved: Bool?, denied: Bool) -> Status {
        if approved == true { return .pass }
        if denied { return .fail }
        return .unknown
    }

    public static func selectionStatus(chosen: Int, decoded: Bool) -> Status {
        guard decoded else { return .fail }
        return chosen > 0 ? .pass : .fail
    }

    public static func appGroupStatus(echo: Bool) -> Status {
        return echo ? .pass : .fail
    }

    public static func monitoringStatus(activities: Int, error: String?) -> Status {
        if let error { return .fail }
        return activities > 0 ? .pass : .unknown
    }

    public static func notificationStatus(authorized: Bool?, denied: Bool) -> Status {
        if authorized == true { return .pass }
        if denied { return .fail }
        return .unknown
    }

    /// The extension side's read-back of the App Group, judged by the
    /// person from what the report draws: PASS when the timestamp the
    /// report shows matches the one the host wrote.
    public static func extensionEchoStatus(timestampMatches: Bool?) -> Status {
        switch timestampMatches {
        case .some(true): return .pass
        case .some(false): return .fail
        case .none: return .unknown
        }
    }

    // MARK: - Report

    /// One plain-text block of everything the host knows, with blanks
    /// for the values the sealed report draws (the person fills them
    /// in from the screen).
    public static func report(facts: HostFacts, hostTimestamp: String) -> String {
        var lines: [String] = []
        lines.append("SMAPP diagnostics — \(facts.appVersion) (\(facts.commit))")
        lines.append("checked: \(hostTimestamp)")
        lines.append("")
        lines.append("[\(accessStatus(approved: facts.accessApproved, denied: facts.accessDenied).rawValue)] Screen Time access")
        lines.append("[\(selectionStatus(chosen: facts.chosenApps, decoded: facts.selectionDecoded).rawValue)] Selection: \(facts.chosenApps) chosen, \(facts.enabledApps) enabled, \(facts.perAppTargets) per-app targets")
        lines.append("[\(appGroupStatus(echo: facts.appGroupEcho).rawValue)] App Group host echo")
        lines.append("[____] App Group extension echo — timestamp shown in report: ____ (host wrote \(hostTimestamp))")
        lines.append("[____] Extension target read: ____ minutes (host target: see Settings)")
        lines.append("[____] Today total in report: ____ (host cannot see it)")
        lines.append("[____] Apps in report: ____ ; day segments (35-day ask): ____")
        lines.append("[____] Taps in report: counter rose? Y/N")
        lines.append("[\(monitoringStatus(activities: facts.monitoringActivities, error: facts.monitoringError).rawValue)] Monitoring: \(facts.monitoringActivities) activities\(facts.monitoringError.map { ", error: \($0)" } ?? "")")
        lines.append("[\(notificationStatus(authorized: facts.notificationsAuthorized, denied: facts.notificationsDenied).rawValue)] Notifications")
        if let last = facts.lastCheckpoint {
            lines.append("last checkpoint: \(last)")
        }
        return lines.joined(separator: "\n")
    }
}
