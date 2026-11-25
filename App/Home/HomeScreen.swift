// HomeScreen — "Today" + date, the homeTotal report card, and a card of
// app rows. Nothing else (DESIGN-NOTES.md § Home).

import SwiftUI
import DeviceActivity
import FamilyControls
import ManagedSettings
import Core

struct HomeScreen: View {

    @Environment(AppState.self) private var appState
    @State private var showPicker = false

    var body: some View {
        @Bindable var state = appState

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header

                if appState.monitoringEnabled {
                    homeCard
                    // Failure class 8: no deferred `let` inside a
                    // ViewBuilder — the test lives in a helper.
                    if showsSetTargetButton {
                        Button("Set a target") {
                            NotificationCenter.default.post(name: AppState.openTargetTab, object: nil)
                        }
                        .buttonStyle(.primaryAction)
                        .padding(.horizontal, 20)
                    }
                } else {
                    pausedCard
                }

                #if DEBUG
                // V1/Part 2: demo mode always shows the five sample rows
                // except in the noapps state.
                if DemoMode.isEnabled {
                    if DemoMode.state == .noapps {
                        emptyAppsCard
                    } else {
                        appsCard
                    }
                } else if !appState.orderedTokens.isEmpty {
                    appsCard
                } else {
                    emptyAppsCard
                }
                #else
                if !appState.orderedTokens.isEmpty {
                    appsCard
                } else {
                    emptyAppsCard
                }
                #endif
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
        }
        .background(Color("Ground"))
        .navigationTitle("")
        .navigationBarHidden(true)
        .navigationDestination(for: ApplicationToken.self) { token in
            AppDetailScreen(token: token)
        }
        .familyActivityPicker(isPresented: $showPicker, selection: $state.selection)
        .onReceive(NotificationCenter.default.publisher(for: AppState.openAppPicker)) { _ in
            showPicker = true
        }
        #if DEBUG
        .onAppear { DemoMarker.mark("home") }
        #endif
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Today")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(Color("PrimaryText"))
            Spacer()
            Text(Self.dateLine)
                .font(.footnote)
                .foregroundStyle(Color("SecondaryText"))
        }
    }

    @ViewBuilder
    /// V1/Part 2: demo states drive the branch — `notarget` shows the
    /// button; live mode shows it when no target is set.
    private var showsSetTargetButton: Bool {
        #if DEBUG
        if DemoMode.isEnabled {
            return DemoMode.state == .notarget
        }
        #endif
        return appState.targetMinutes == nil
    }

    // @ViewBuilder, not an if-expression: the DEBUG branches return
    // different view types (run 26's "branches have mismatching types").
    @ViewBuilder
    private var homeCard: some View {
        #if DEBUG
        if DemoMode.isEnabled {
            if DemoMode.state == .paused {
                pausedCard
            } else {
                HeroCardView(configuration: DemoData.homeTotal)
                    .accessibilityLabel("Today's total")
            }
        } else {
            reportHomeCard
        }
        #else
        reportHomeCard
        #endif
    }

    private var reportHomeCard: some View {
        DeviceActivityReport(
            .homeTotal,
            filter: Filters.homeTotal(enabled: appState.enabledTokens, mode: appState.targetMode)
        )
        .frame(height: 168)
        .accessibilityLabel("Today's total")
    }

    private var pausedCard: some View {
        Text("Paused")
            .font(.system(.largeTitle, design: .default).weight(.bold))
            .foregroundStyle(Color("SecondaryText"))
            .frame(maxWidth: .infinity, minHeight: 120, alignment: .center)
            .padding(22)
            .background(Color("Card"), in: RoundedRectangle(cornerRadius: 24))
    }

    private var emptyAppsCard: some View {
        VStack(spacing: 10) {
            Text("No apps chosen")
                .font(.subheadline)
                .foregroundStyle(Color("SecondaryText"))
            Button("Choose apps") { showPicker = true }
                .buttonStyle(.primaryActionCompact)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color("Card"), in: RoundedRectangle(cornerRadius: 24))
    }

    private var appsCard: some View {
        VStack(spacing: 0) {
            #if DEBUG
            if DemoMode.isEnabled {
                ForEach(Array(DemoData.apps.enumerated()), id: \.offset) { _, app in
                    demoRow(app)
                }
            } else {
                tokensRows
            }
            #else
            tokensRows
            #endif
        }
        .background(Color("Card"), in: RoundedRectangle(cornerRadius: 24))
        .onChange(of: appState.selection) { _, _ in
            appState.syncFromSelection()
        }
    }

    private var tokensRows: some View {
        ForEach(Array(appState.orderedTokens.enumerated()), id: \.element) { _, token in
            AppUsageRow(token: token, dimmed: !appState.isEnabled(token) || !appState.monitoringEnabled)
        }
    }

    #if DEBUG
    private func demoRow(_ app: DemoData.DemoApp) -> some View {
        // W13/W14: the report (time + bar) spans the full row width;
        // the tile+name label sits over its first line. Demo rows are
        // in descending usage order, so the row index is the rank —
        // the tile colour matches the Summary's rank colours.
        AppRowShell {
            HStack(spacing: 10) {
                DemoTile(rank: demoRowIndex(of: app), initials: app.initials)
                Text(app.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("PrimaryText"))
            }
        } report: {
            AppRowReportView(configuration: DemoData.appRow(app))
        }
    }

    private func demoRowIndex(of app: DemoData.DemoApp) -> Int {
        return DemoData.apps.firstIndex(where: { $0.name == app.name }) ?? 0
    }
    #endif

    static var dateLine: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE d MMM"
        return formatter.string(from: Date())
    }
}
