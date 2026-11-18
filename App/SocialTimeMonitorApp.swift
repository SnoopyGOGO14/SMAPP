// SocialTimeMonitorApp — entry point. Routes between onboarding and the
// tabs, overlays the access banner, re-checks authorisation on every
// return to the foreground, and rebuilds filters at midnight rollover.

import SwiftUI
import FamilyControls
import Core

@main
struct SocialTimeMonitorApp: App {

    @State private var appState = AppState()
    @Environment(\.scenePhase) private var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            content
        }
    }

    @ViewBuilder
    private var content: some View {
        #if DEBUG
        if DemoMode.isEnabled {
            demoContent
        } else {
            mainContent
        }
        #else
        mainContent
        #endif
    }

    // MARK: - Demo routing (F1): screens open directly, no onboarding,
    // no access banner, and every branch gets the environment.

    #if DEBUG
    @ViewBuilder
    private var demoContent: some View {
        switch DemoMode.screen {
        case "onboarding":
            OnboardingFlow(startingCard: (DemoMode.card ?? 1) - 1)
                .environment(appState)
        case "detail":
            NavigationStack {
                DemoDetailScreen()
            }
            .environment(appState)
        case "settings":
            NavigationStack {
                SettingsScreen()
            }
            .environment(appState)
        default:
            demoRoot
        }
    }

    /// Home/All apps/Target in demo mode, with the access banner only in
    /// the noaccess state (Part 2).
    private var demoRoot: some View {
        ZStack(alignment: .top) {
            RootTabs(initialTab: tabForScreen(DemoMode.screen))
            if DemoMode.state == .noaccess {
                AccessBanner(
                    message: "Screen Time access is off",
                    actionTitle: "Allow",
                    action: {}
                )
                .padding(.horizontal, 20)
            }
        }
        .environment(appState)
        .background(Color("Ground").ignoresSafeArea())
    }

    private func tabForScreen(_ screen: String?) -> Int {
        switch screen {
        case "allapps": return 1
        case "target": return 2
        default: return 0
        }
    }
    #endif

    private var mainContent: some View {
        ZStack(alignment: .top) {
            if appState.showOnboarding {
                OnboardingFlow()
            } else {
                RootTabs()
            }
            #if DEBUG
            if !DemoMode.isEnabled && appState.showAccessBanner {
                AccessBanner(
                    message: appState.bannerMessage,
                    actionTitle: appState.bannerActionTitle,
                    action: { appState.runBannerAction() }
                )
                .padding(.horizontal, 20)
            }
            #else
            if appState.showAccessBanner {
                AccessBanner(
                    message: appState.bannerMessage,
                    actionTitle: appState.bannerActionTitle,
                    action: { appState.runBannerAction() }
                )
                .padding(.horizontal, 20)
            }
            #endif
        }
        .environment(appState)
        .background(Color("Ground").ignoresSafeArea())
        .preferredColorScheme(nil)
        .task {
            appState.refreshAuthorizationStatus()
            appState.startDayRolloverWatch()
            // F4: no unconditional monitoring restart on launch; only
            // top up a missing activity.
            MonitoringScheduler.shared.topUpIfMissing()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                appState.refreshAuthorizationStatus()
            }
        }
    }
}
