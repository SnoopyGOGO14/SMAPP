// HomeScreen — "Today" + date, the homeTotal report card, and a card of
// app rows. Nothing else (DESIGN-NOTES.md § Home).

import SwiftUI
import DeviceActivity
import FamilyControls
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
                    if appState.targetMinutes == nil {
                        Button("Set a target") {
                            NotificationCenter.default.post(name: AppState.openTargetTab, object: nil)
                        }
                        .font(.subheadline.weight(.semibold))
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    pausedCard
                }

                if appState.orderedTokens.isEmpty {
                    emptyAppsCard
                } else {
                    appsCard
                }
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

    private var homeCard: some View {
        #if DEBUG
        if DemoMode.isEnabled {
            HeroCardView(configuration: DemoData.homeTotal)
                .frame(height: 168)
                .accessibilityLabel("Today's total")
                .padding(0)
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
                .font(.subheadline.weight(.semibold))
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
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
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("BarTrack"))
                .frame(width: 36, height: 36)
                .overlay(Text(app.initials).font(.footnote.weight(.bold)).foregroundStyle(Color("SecondaryText")))
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
