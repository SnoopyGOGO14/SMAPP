// AppState — the app's observable model. Loads from and saves through
// SharedSettings; owns authorisation state, the selection, targets and
// the chosen period.

import Foundation
import SwiftUI
import FamilyControls
import DeviceActivity
import Core
import SharedUI

@Observable
final class AppState {

    var authorizationStatus: AuthorizationStatus = .notDetermined
    var selection = FamilyActivitySelection(includeEntireCategory: true)
    var orderedTokens: [ApplicationToken] = []
    var enabledTokens: [ApplicationToken] = []
    var appTargets: [SharedSettings.AppTarget] = []
    var monitoringEnabled = true
    var targetMode: Core.TargetMode = .daily
    var targetMinutes: Int? = 180
    var statsPeriod: Core.Period = .day
    var showOnboarding: Bool

    let settings = SharedSettings()

    init() {
        showOnboarding = !settings.onboardingCompleted
        load()
    }

    // MARK: - Loading

    func load() {
        orderedTokens = settings.orderedTokens
        enabledTokens = settings.enabledTokens
        appTargets = settings.appTargets
        monitoringEnabled = settings.monitoringEnabled
        targetMode = settings.targetMode
        targetMinutes = settings.targetMinutes
        statsPeriod = settings.statsPeriod
        if let saved = settings.selection {
            selection = saved
        }
    }

    // MARK: - Authorisation

    func refreshAuthorizationStatus() {
        authorizationStatus = AuthorizationCenter.shared.authorizationStatus
    }

    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
        } catch {
            // Denied or failed; the banner explains and offers a retry.
        }
        refreshAuthorizationStatus()
    }

    var hasAccess: Bool {
        return authorizationStatus == .approved
    }

    // MARK: - Selection

    /// Called after the picker closes: keeps existing row order, appends
    /// new apps, drops removed ones from order, switches and targets.
    func syncFromSelection() {
        let available = Array(selection.applicationTokens)
        let cleaned = Core.TokenCleanup.cleanup(
            ordered: orderedTokens,
            enabled: enabledTokens.isEmpty && orderedTokens.isEmpty ? available : enabledTokens,
            targets: appTargets.map { ($0.token, $0.minutes) },
            available: available
        )
        orderedTokens = cleaned.ordered + available.filter { !cleaned.ordered.contains($0) }
        enabledTokens = cleaned.enabled.isEmpty && enabledTokens.isEmpty
            ? orderedTokens
            : cleaned.enabled
        appTargets = cleaned.targets.map { SharedSettings.AppTarget(token: $0.token, minutes: $0.minutes) }
        settings.orderedTokens = orderedTokens
        settings.enabledTokens = enabledTokens
        settings.appTargets = appTargets
        settings.selection = selection
    }

    // MARK: - Per-app

    func isEnabled(_ token: ApplicationToken) -> Bool {
        return enabledTokens.contains(token)
    }

    func setEnabled(_ token: ApplicationToken, _ on: Bool) {
        if on {
            if !enabledTokens.contains(token) { enabledTokens.append(token) }
        } else {
            enabledTokens.removeAll { $0 == token }
        }
        settings.enabledTokens = enabledTokens
    }

    func target(for token: ApplicationToken) -> Int? {
        return appTargets.first { $0.token == token }?.minutes
    }

    func setTarget(_ token: ApplicationToken, minutes: Int?) {
        appTargets.removeAll { $0.token == token }
        if let minutes, minutes > 0 {
            appTargets.append(SharedSettings.AppTarget(token: token, minutes: minutes))
        }
        settings.appTargets = appTargets
    }

    // MARK: - Overall target

    func setTargetMode(_ mode: Core.TargetMode) {
        if let current = targetMinutes, mode != targetMode {
            switch mode {
            case .weekly:
                targetMinutes = Core.TargetMath.toWeekly(fromDailyMinutes: current)
            case .daily:
                targetMinutes = Core.TargetMath.toDaily(fromWeeklyMinutes: current)
            }
        }
        targetMode = mode
        settings.targetMode = mode
        settings.targetMinutes = targetMinutes
    }

    func setTargetMinutes(_ minutes: Int?) {
        targetMinutes = minutes
        settings.targetMinutes = minutes
    }

    // MARK: - Period

    func setStatsPeriod(_ period: Core.Period) {
        statsPeriod = period
        settings.statsPeriod = period
    }

    // MARK: - Onboarding

    func completeOnboarding() {
        settings.onboardingCompleted = true
        showOnboarding = false
        syncFromSelection()
    }

    // MARK: - Access banner (Block I2)

    static let openAppPicker = Notification.Name("openAppPicker")

    var showAccessBanner: Bool {
        if showOnboarding { return false }
        return !hasAccess || orderedTokens.isEmpty
    }

    var bannerMessage: String {
        if !hasAccess { return "Screen Time access is off" }
        return "No apps chosen"
    }

    var bannerActionTitle: String {
        if !hasAccess { return "Allow" }
        return "Choose apps"
    }

    func runBannerAction() {
        if hasAccess {
            NotificationCenter.default.post(name: Self.openAppPicker, object: nil)
        } else {
            Task { await requestAuthorization() }
        }
    }

    // MARK: - Day rollover (Block I8)

    private(set) var dayStamp: String = ""

    @MainActor
    func startDayRolloverWatch() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        dayStamp = formatter.string(from: Date())
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                let today = formatter.string(from: Date())
                if today != self.dayStamp {
                    self.dayStamp = today
                }
            }
        }
    }
}
