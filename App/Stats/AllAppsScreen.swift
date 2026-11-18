// AllAppsScreen — "All apps" + date, period switch, the donut report,
// and a card of time-only rows.

import SwiftUI
import DeviceActivity
import FamilyControls
import ManagedSettings
import Core

struct AllAppsScreen: View {

    @Environment(AppState.self) private var appState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header

                periodSwitch

                #if DEBUG
                if DemoMode.isEnabled {
                    DonutView(configuration: DemoData.allApps)
                        .frame(height: 250)
                        .frame(maxWidth: .infinity)
                    VStack(spacing: 0) {
                        ForEach(Array(DemoData.apps.enumerated()), id: \.offset) { _, app in
                            HStack(spacing: 14) {
                                Circle()
                                    .fill(PaletteColors.color(at: app.paletteIndex))
                                    .frame(width: 14, height: 14)
                                Text(app.name)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color("PrimaryText"))
                                Spacer()
                                AppTimeView(configuration: DemoData.appTime(app))
                                    .frame(width: 120)
                            }
                            .padding(.horizontal, 18)
                            .frame(height: 50)
                        }
                    }
                    .background(Color("Card"), in: RoundedRectangle(cornerRadius: 24))
                } else {
                    reportDonutAndRows
                }
                #else
                reportDonutAndRows
                #endif
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
        }
        .background(Color("Ground"))
        .navigationBarHidden(true)
        .navigationDestination(for: ApplicationToken.self) { token in
            AppDetailScreen(token: token)
        }
        #if DEBUG
        .onAppear { DemoMarker.mark("allapps") }
        #endif
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("All apps")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(Color("PrimaryText"))
            Spacer()
            Text(HomeScreen.dateLine)
                .font(.footnote)
                .foregroundStyle(Color("SecondaryText"))
        }
    }

    private var periodSwitch: some View {
        Picker("Period", selection: Binding(
            get: { appState.statsPeriod },
            set: { appState.setStatsPeriod($0) }
        )) {
            Text("Today").tag(Core.Period.day)
            Text("7 days").tag(Core.Period.week)
            Text("Month").tag(Core.Period.month)
        }
        .pickerStyle(.segmented)
        .frame(height: 40)
    }

    private var reportDonutAndRows: some View {
        VStack(spacing: 16) {
            DeviceActivityReport(
                .allApps,
                filter: Filters.allApps(enabled: appState.enabledTokens, period: appState.statsPeriod)
            )
            .frame(height: 250)
            .frame(maxWidth: .infinity)

            if appState.orderedTokens.isEmpty {
                Text("No apps chosen")
                    .font(.subheadline)
                    .foregroundStyle(Color("SecondaryText"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
            } else {
                VStack(spacing: 0) {
                    ForEach(appState.orderedTokens, id: \.self) { token in
                        AppUsageRow(token: token, style: .timeOnly)
                    }
                }
                .background(Color("Card"), in: RoundedRectangle(cornerRadius: 24))
            }
        }
    }
}
