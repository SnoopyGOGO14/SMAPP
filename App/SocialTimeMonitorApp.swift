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
            ZStack(alignment: .top) {
                if appState.showOnboarding {
                    OnboardingFlow()
                } else {
                    RootTabs()
                }
                if appState.showAccessBanner {
                    AccessBanner(
                        message: appState.bannerMessage,
                        actionTitle: appState.bannerActionTitle,
                        action: { appState.runBannerAction() }
                    )
                    .padding(.horizontal, 20)
                }
            }
            .environment(appState)
            .background(Color("Ground").ignoresSafeArea())
            .preferredColorScheme(nil)
            .task {
                appState.refreshAuthorizationStatus()
                appState.startDayRolloverWatch()
                if !appState.showOnboarding {
                    MonitoringScheduler.shared.restartDebounced()
                }
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    appState.refreshAuthorizationStatus()
                }
            }
        }
    }
}
