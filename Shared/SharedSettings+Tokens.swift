// SharedSettings+Tokens — keys that carry FamilyControls opaque tokens.
// Compiled into the app and UsageReport only; UsageMonitor must not
// import FamilyControls.

import Foundation
import FamilyControls
import ManagedSettings
import Core

extension SharedSettings {

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

    /// The whole picker selection, as saved. Note: the saved copy loses
    /// includeEntireCategory; the app re-establishes the flag when it
    /// presents the picker (AppState holds the live selection).
    public var selection: FamilyActivitySelection? {
        get {
            guard let data = defaults.data(forKey: SettingsKeys.selection) else { return nil }
            return try? PropertyListDecoder().decode(FamilyActivitySelection.self, from: data)
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

    public struct AppTarget: Codable, Equatable {
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
        let position = orderedTokens.firstIndex(of: token) ?? 0
        return Core.Palette.index(for: position)
    }
}
