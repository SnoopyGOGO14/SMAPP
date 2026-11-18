// SharedSettings — the single reader/writer of App Group keys for all
// three targets (README rule 7). Compiled into the app, UsageReport and
// UsageMonitor. Foundation + FamilyControls only, no SwiftUI.
//
// The report extension READS only (writes are blocked by the sandbox);
// UsageMonitor writes lastCheckpoint only; the main app writes everything
// else. Decode failures fall back to safe defaults (no force unwraps).

import Foundation
import FamilyControls
import Core

public enum AppGroupConfig {
    /// Replace YOURORG here and in the three .entitlements files + project.yml.
    public static let groupID = "group.com.YOURORG.socialtimemonitor"
}

public final class SharedSettings {

    private let defaults: UserDefaults

    public init(suiteName: String = AppGroupConfig.groupID) {
        if let defaults = UserDefaults(suiteName: suiteName) {
            self.defaults = defaults
        } else {
            self.defaults = .standard
        }
    }

    // MARK: - Tokens

    /// Every app the user picked, in row order (also the donut colour index).
    public var orderedTokens: [ApplicationToken] {
        get {
            guard let data = defaults.data(forKey: SettingsKeys.orderedTokens) else { return [] }
            return (try? PropertyListDecoder().decode([ApplicationToken].self, from: data)) ?? []
        }
        set {
            let data = (try? PropertyListEncoder().encode(newValue)) ?? Data()
            defaults.set(data, forKey: SettingsKeys.orderedTokens)
        }
    }

    /// Apps whose switch is on. Order follows orderedTokens.
    public var enabledTokens: [ApplicationToken] {
        get {
            guard let data = defaults.data(forKey: SettingsKeys.enabledTokens) else { return orderedTokens }
            let set = (try? PropertyListDecoder().decode(Set<ApplicationToken>.self, from: data)) ?? []
            return orderedTokens.filter { set.contains($0) }
        }
        set {
            let data = (try? PropertyListEncoder().encode(Set(newValue))) ?? Data()
            defaults.set(data, forKey: SettingsKeys.enabledTokens)
        }
    }

    /// The whole picker selection. Decoded selections lose
    /// includeEntireCategory, so it is set again here.
    public var selection: FamilyActivitySelection? {
        get {
            guard let data = defaults.data(forKey: SettingsKeys.selection) else { return nil }
            var decoded = try? PropertyListDecoder().decode(FamilyActivitySelection.self, from: data)
            if decoded != nil {
                decoded = FamilyActivitySelection(includeEntireCategory: true)
                    .union(decoded ?? FamilyActivitySelection())
            }
            return decoded
        }
        set {
            guard let newValue = newValue else { return }
            let data = (try? PropertyListEncoder().encode(newValue)) ?? Data()
            defaults.set(data, forKey: SettingsKeys.selection)
        }
    }

    /// The app whose detail screen is open (drives the appDetail scene).
    public var detailToken: ApplicationToken? {
        get {
            guard let data = defaults.data(forKey: SettingsKeys.detailToken) else { return nil }
            return try? PropertyListDecoder().decode(ApplicationToken.self, from: data)
        }
        set {
            guard let newValue = newValue else { return }
            let data = (try? PropertyListEncoder().encode(newValue)) ?? Data()
            defaults.set(data, forKey: SettingsKeys.detailToken)
        }
    }

    // MARK: - Per-app targets

    public struct AppTarget: Equatable {
        public let token: ApplicationToken
        public let minutes: Int
        public init(token: ApplicationToken, minutes: Int) {
            self.token = token
            self.minutes = minutes
        }
    }

    public var appTargets: [AppTarget] {
        get {
            guard let data = defaults.data(forKey: SettingsKeys.appTargets) else { return [] }
            return (try? PropertyListDecoder().decode([AppTarget].self, from: data)) ?? []
        }
        set {
            let data = (try? PropertyListEncoder().encode(newValue)) ?? Data()
            defaults.set(data, forKey: SettingsKeys.appTargets)
        }
    }

    public func target(for token: ApplicationToken) -> Int? {
        return appTargets.first { $0.token == token }?.minutes
    }

    /// Position in orderedTokens → palette slot (wraps at 8).
    public func paletteIndex(for token: ApplicationToken) -> Int {
        let order = orderedTokens
        let position = order.firstIndex(of: token) ?? 0
        return Core.Palette.index(for: position)
    }

    // MARK: - Overall target

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

    public var recapsEnabled: Bool {
        get { defaults.bool(forKey: SettingsKeys.recapsEnabled) }
        set { defaults.set(newValue, forKey: SettingsKeys.recapsEnabled) }
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
}
