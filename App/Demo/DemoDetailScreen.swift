// DemoDetailScreen — the App detail screen fed from DemoData, for
// screenshot capture. Honours -period and -sheet target (Part 2).
// Debug builds only.

#if DEBUG
import SwiftUI
import Core

struct DemoDetailScreen: View {

    @State private var period: DemoMode.DemoPeriod
    @State private var showTargetSheet = false
    private let demoFocus: Int?

    init() {
        _period = State(initialValue: DemoMode.period ?? .week)
        _showTargetSheet = State(initialValue: DemoMode.sheet == "target")
        demoFocus = DemoMode.focus
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                periodSwitch

                AppDetailCardView(configuration: DemoData.appDetail(period: period), initialFocus: demoFocus)

                Button {
                    showTargetSheet = true
                } label: {
                    Text("Target 1h a day · Change")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color("PrimaryText"))
                        .frame(maxWidth: .infinity, minHeight: 52)
                }
                .buttonStyle(.plain)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color("Divider"), lineWidth: 1))
            }
            .padding(.horizontal, 20)
        }
        .background(Color("Ground"))
        // X7: tabs 12 pt below the navigation bar.
        .contentMargins(.top, 12, for: .scrollContent)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 10) {
                    // W14: the demo tile in the Summary's rank colour.
                    DemoTile(rank: 0, initials: "Ti", size: 32)
                    Text("TikTok")
                        .font(.headline)
                        .foregroundStyle(Color("PrimaryText"))
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color("PrimaryText"))
                }
                .accessibilityLabel("Back")
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Toggle("Monitor", isOn: .constant(true))
                    .toggleStyle(.switch)
                    .tint(.green)
                    .labelsHidden()
            }
        }
        .onAppear { DemoMarker.mark("detail") }
        .sheet(isPresented: $showTargetSheet) {
            DemoTargetSheet()
                .presentationDetents([.medium])
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
                        weekStartsOn: SharedSettings().weekStartsOn,
                        calendar: uk
                    )
                ),
                PeriodTabsControl.Tab(
                    title: "Monthly",
                    elapsed: Core.PeriodProgress.monthFraction(calendar: uk)
                )
            ],
            selected: titleForDataSet(period.dataSet)
        ) { selected in
            if let period = periodForTitle(selected) {
                self.period = period
            }
        }
    }

    private func titleForDataSet(_ dataSet: DemoMode.DemoPeriod.DataSet) -> String {
        switch dataSet {
        case .today: return "Daily"
        case .week: return "Weekly"
        case .month: return "Monthly"
        }
    }

    private func periodForTitle(_ title: String) -> DemoMode.DemoPeriod? {
        switch title {
        case "Daily": return .today
        case "Weekly": return .week
        case "Monthly": return .month
        default: return nil
        }
    }
}

/// The per-app target sheet over demo detail (read-only sample).
private struct DemoTargetSheet: View {
    @State private var minutes = 60

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Daily target")
                .font(.headline)
                .foregroundStyle(Color("PrimaryText"))

            HStack(spacing: 8) {
                ForEach(Array([30, 45, 60, 90].enumerated()), id: \.offset) { index, preset in
                    Button(["30m", "45m", "1h", "1h 30m"][index]) {
                        minutes = preset
                    }
                    .buttonStyle(.preset(minutes == preset))
                }
            }

            Stepper(DurationFormat.short(minutes: minutes), value: $minutes, in: 15...480, step: 15)
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color("PrimaryText"))

            Text("Remove target")
                .font(.subheadline)
                .foregroundStyle(Color.red)
        }
        .padding(24)
    }
}
#endif
