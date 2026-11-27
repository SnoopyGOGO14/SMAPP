// SharedSettings — the single reader/writer of App Group keys for all
// three targets (README rule 7). This base file is Foundation + Core
// only, so it is safe to compile into UsageMonitor (which must stay
// tiny and imports no FamilyControls/SwiftUI). Token-related keys live
// in SharedSettings+Tokens.swift (app and UsageReport only).
//
// The report extension READS only (writes are blocked by the sandbox);
// UsageMonitor writes lastCheckpoint only; the main app writes everything
// else. Decode failures fall back to safe defaults (no force unwraps).

import Foundation
import Core

public enum AppGroupConfig {
    /// Replace YOURORG here and in the three .entitlements files + project.yml.
    public static let groupID = "group.com.YOURORG.socialtimemonitor"
}

public final class SharedSettings {

    let defaults: UserDefaults

    public init(suiteName: String = AppGroupConfig.groupID) {
        if let defaults = UserDefaults(suiteName: suiteName) {
            self.defaults = defaults
        } else {
            self.defaults = .standard
        }
    }

    // MARK: - Overall target and monitoring

    public var monitoringEnabled: Bool {
        get { defaults.object(forKey: SettingsKeys.monitoringEnabled) as? Bool ?? true }
        set { defaults.set(newValue, forKey: SettingsKeys.monitoringEnabled) }
    }

    public var targetMode: Core.TargetMode {
        get {
            guard let raw = defaults.string(forKey: SettingsKeys.targetMode),
                  let mode = Core.TargetMode(rawValue: raw) else { return .daily }
            return mode
        }
        set { defaults.set(newValue.rawValue, forKey: SettingsKeys.targetMode) }
    }

    /// Target in the current mode's minutes (daily minutes or weekly minutes).
    public var targetMinutes: Int? {
        get {
            guard let value = defaults.object(forKey: SettingsKeys.targetMinutes) as? Int, value > 0 else { return nil }
            return value
        }
        set {
            if let value = newValue {
                defaults.set(value, forKey: SettingsKeys.targetMinutes)
            } else {
                defaults.removeObject(forKey: SettingsKeys.targetMinutes)
            }
        }
    }

    public var amberFraction: Double {
        get {
            guard let value = defaults.object(forKey: SettingsKeys.amberFraction) as? Double else { return 0.75 }
            return min(max(value, 0.5), 0.95)
        }
        set { defaults.set(newValue, forKey: SettingsKeys.amberFraction) }
    }

    // MARK: - Notifications and period

    public var alertsEnabled: Bool {
        get { defaults.bool(forKey: SettingsKeys.alertsEnabled) }
        set { defaults.set(newValue, forKey: SettingsKeys.alertsEnabled) }
    }


    public var weekStartsOn: Int {
        get {
            guard let value = defaults.object(forKey: SettingsKeys.weekStartsOn) as? Int else { return 2 }
            return min(max(value, 1), 7)
        }
        set { defaults.set(newValue, forKey: SettingsKeys.weekStartsOn) }
    }

    public var statsPeriod: Core.Period {
        get {
            guard let raw = defaults.string(forKey: SettingsKeys.statsPeriod) else { return .day }
            switch raw {
            case "today": return .day
            case "week": return .week
            case "month": return .month
            default: return .day
            }
        }
        set {
            let raw: String
            switch newValue {
            case .day: raw = "today"
            case .week: raw = "week"
            case .month: raw = "month"
            case .hour: raw = "today"
            }
            defaults.set(raw, forKey: SettingsKeys.statsPeriod)
        }
    }

    // MARK: - Summary period (08 plan)

    public var summaryPeriod: Core.SummaryPeriod {
        get {
            let raw = defaults.string(forKey: SettingsKeys.summaryPeriod) ?? "weekly"
            return Core.SummaryPeriod.from(rawValue: raw)
        }
        set {
            defaults.set(newValue.rawValueString, forKey: SettingsKeys.summaryPeriod)
        }
    }

    public var summaryDay: Date? {
        get {
            guard let days = defaults.object(forKey: SettingsKeys.summaryDay) as? Double else { return nil }
            return Date(timeIntervalSince1970: days * 86_400)
        }
        set {
            guard let newValue else {
                defaults.removeObject(forKey: SettingsKeys.summaryDay)
                return
            }
            let days = newValue.timeIntervalSince1970 / 86_400
            defaults.set(days, forKey: SettingsKeys.summaryDay)
        }
    }

    // MARK: - Onboarding and checkpoint

    public var onboardingCompleted: Bool {
        get { defaults.bool(forKey: "onboardingCompleted") }
        set { defaults.set(newValue, forKey: "onboardingCompleted") }
    }

    public var lastCheckpoint: Core.Checkpoint? {
        get {
            guard let data = defaults.data(forKey: SettingsKeys.lastCheckpoint) else { return nil }
            return try? PropertyListDecoder().decode(Core.Checkpoint.self, from: data)
        }
        set {
            guard let newValue = newValue else { return }
            let data = (try? PropertyListEncoder().encode(newValue)) ?? Data()
            defaults.set(data, forKey: SettingsKeys.lastCheckpoint)
        }
    }

    // MARK: - Monitoring health and alert ledger (F4/F6)

    /// Diagnostics (Part 1): the host writes a timestamp, the report
    /// reads it back — the App Group echo check.
    public var diagnosticsTimestamp: String? {
        get { defaults.string(forKey: SettingsKeys.diagnosticsTimestamp) }
        set {
            if let newValue {
                defaults.set(newValue, forKey: SettingsKeys.diagnosticsTimestamp)
            } else {
                defaults.removeObject(forKey: SettingsKeys.diagnosticsTimestamp)
            }
        }
    }

    /// Diagnostics (Part 2): day segments the extension reported for
    /// the 35-day ask; 0 = unknown. Gates the Monthly tab.
    public var historyDays: Int {
        get { defaults.object(forKey: SettingsKeys.historyDays) as? Int ?? 0 }
        set { defaults.set(newValue, forKey: SettingsKeys.historyDays) }
    }

    public var lastMonitoringError: String? {
        get { defaults.string(forKey: SettingsKeys.lastMonitoringError) }
        set {
            if let newValue {
                defaults.set(newValue, forKey: SettingsKeys.lastMonitoringError)
            } else {
                defaults.removeObject(forKey: SettingsKeys.lastMonitoringError)
            }
        }
    }

    public var lastAlert: Core.AlertRecord? {
        get {
            guard let data = defaults.data(forKey: SettingsKeys.lastAlert) else { return nil }
            return try? PropertyListDecoder().decode(Core.AlertRecord.self, from: data)
        }
        set {
            guard let newValue = newValue else { return }
            let data = (try? PropertyListEncoder().encode(newValue)) ?? Data()
            defaults.set(data, forKey: SettingsKeys.lastAlert)
        }
    }
}
