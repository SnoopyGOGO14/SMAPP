// AppDetailScreen — back handled by the NavigationStack; icon and name,
// on/off switch, period switch, the appDetail report, target button.
// Writes detailToken and statsPeriod before the report appears.

import SwiftUI
import DeviceActivity
import FamilyControls
import ManagedSettings
import Core

struct AppDetailScreen: View {

    @Environment(AppState.self) private var appState
    let token: ApplicationToken
    @State private var showTargetSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                periodSwitch

                DeviceActivityReport(
                    .appDetail,
                    filter: Filters.appDetail(token: token, period: appState.statsPeriod)
                )
                .frame(minHeight: 420)

                targetButton
            }
            .padding(.horizontal, 20)
        }
        .background(Color("Ground"))
        // X7: the tabs sit 12 pt below the navigation bar — the
        // ScrollView's default top content margin left an ~80 pt band.
        .contentMargins(.top, 12, for: .scrollContent)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) { toolbarTitle }
            // V5: the on/off switch belongs on the title line, not in a
            // stranded band below the navigation bar.
            ToolbarItem(placement: .navigationBarTrailing) {
                Toggle("Monitor", isOn: Binding(
                    get: { appState.isEnabled(token) },
                    set: { appState.setEnabled(token, $0) }
                ))
                .toggleStyle(.switch)
                .tint(.green)
                .labelsHidden()
            }
        }
        .onAppear {
            appState.settings.detailToken = token
        }
        .sheet(isPresented: $showTargetSheet) {
            AppTargetSheet(token: token)
        }
    }

    private var toolbarTitle: some View {
        HStack(spacing: 10) {
            #if DEBUG
            if DemoMode.isEnabled {
                // W14: the demo tile in the Summary's rank colour.
                DemoTile(rank: 0, initials: "Ti", size: 32)
                Text("TikTok")
                    .font(.headline)
                    .foregroundStyle(Color("PrimaryText"))
            } else {
                Label(token)
                    .font(.headline)
                    .foregroundStyle(Color("PrimaryText"))
            }
            #else
            Label(token)
                .font(.headline)
                .foregroundStyle(Color("PrimaryText"))
            #endif
        }
    }

    private var periodSwitch: some View {
        // W12: the one period control — the Summary's tab style and
        // wording (Daily, Weekly, Monthly) with the elapsed underline.
        let uk = Core.AppCalendar.uk()
        return PeriodTabsControl(
            tabs: [
                PeriodTabsControl.Tab(
                    title: "Daily",
                    elapsed: Core.PeriodProgress.dayFraction(calendar: uk)
                ),
                PeriodTabsControl.Tab(
                    title: "Weekly",
                    elapsed: Core.PeriodProgress.weekFraction(
                        weekStartsOn: appState.settings.weekStartsOn,
                        calendar: uk
                    )
                ),
                PeriodTabsControl.Tab(
                    title: "Monthly",
                    elapsed: Core.PeriodProgress.monthFraction(calendar: uk)
                )
            ],
            selected: titleForPeriod(appState.statsPeriod)
        ) { selected in
            appState.setStatsPeriod(periodForTitle(selected))
        }
    }

    private func titleForPeriod(_ period: Core.Period) -> String {
        switch period {
        case .day, .hour: return "Daily"
        case .week: return "Weekly"
        case .month: return "Monthly"
        }
    }

    private func periodForTitle(_ title: String) -> Core.Period {
        switch title {
        case "Weekly": return .week
        case "Monthly": return .month
        default: return .day
        }
    }

    private var targetButton: some View {
        Button {
            showTargetSheet = true
        } label: {
            Text(targetButtonTitle)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: 52)
        }
        .buttonStyle(.plain)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color("Divider"), lineWidth: 1))
    }

    private var targetButtonTitle: String {
        if let minutes = appState.target(for: token) {
            let text = DurationFormat.short(minutes: minutes)
            return "Target \(text) a day · Change"
        }
        return "Set a target"
    }
}
