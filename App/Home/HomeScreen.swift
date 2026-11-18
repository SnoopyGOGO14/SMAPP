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
                    #if DEBUG
                    // V1/Part 2: demo states drive the branches — notarget
                    // shows the button; paused/noapps are handled below.
                    let showSetTarget: Bool
                    if DemoMode.isEnabled {
                        showSetTarget = DemoMode.state == .notarget
                    } else {
                        showSetTarget = appState.targetMinutes == nil
                    }
                    if showSetTarget {
                        Button("Set a target") {
                            NotificationCenter.default.post(name: AppState.openTargetTab, object: nil)
                        }
                        .buttonStyle(.primaryAction)
                        .padding(.horizontal, 20)
                    }
                    #else
                    if appState.targetMinutes == nil {
                        Button("Set a target") {
                            NotificationCenter.default.post(name: AppState.openTargetTab, object: nil)
                        }
                        .buttonStyle(.primaryAction)
                        .padding(.horizontal, 20)
                    }
                    #endif
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
        HStack(spacing: 14) {
            // V9: the original tile set, palette-matched to the donut.
            Image("DemoIcon0\(app.paletteIndex + 1)Solid")
                .resizable()
                .frame(width: 36, height: 36)
            Text(app.name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color("PrimaryText"))
            Spacer()
            AppRowReportView(configuration: DemoData.appRow(app))
                .frame(width: 150)
        }
        .padding(.horizontal, 16)
        .frame(height: 64)
    }
    #endif

    static var dateLine: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE d MMM"
        return formatter.string(from: Date())
    }
}
