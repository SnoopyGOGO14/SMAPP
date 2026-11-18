// AllAppsScreen — "All apps" + date, period switch, the donut report,
// and a card of time-only rows.

import SwiftUI
import DeviceActivity
import FamilyControls
import Core

struct AllAppsScreen: View {

    @Environment(AppState.self) private var appState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header

                periodSwitch

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
            .padding(.horizontal, 20)
            .padding(.top, 24)
        }
        .background(Color("Ground"))
        .navigationBarHidden(true)
        .navigationDestination(for: ApplicationToken.self) { token in
            AppDetailScreen(token: token)
        }
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
}
