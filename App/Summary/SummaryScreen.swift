// SummaryScreen — the Stats tab, renamed Summary (08 plan §3): period
// tabs with an elapsed underline, day pills, and one embedded report
// drawing the ranked donut and app cards. Yearly is built but hidden
// until a device proves a year of history.

import SwiftUI
import DeviceActivity
import FamilyControls
import ManagedSettings
import Core

struct SummaryScreen: View {

    @Environment(AppState.self) private var appState
    @State private var period: Core.SummaryPeriod = .weekly

    /// The UK reference calendar (AppCalendar): day pills, "today" and
    /// elapsed fractions follow the UK day, not the device's zone.
    private let ukCalendar = Core.AppCalendar.uk()

    #if DEBUG
    private let demoFocus: Int? = DemoMode.focus
    #else
    private let demoFocus: Int? = nil
    #endif

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    titleRow
                    periodTabsControl
                    if showsDayPills {
                        dayPills
                    }
                    if showsHistoryCaption {
                        Text("Showing the last \(appState.settings.historyDays) days")
                            .font(.footnote)
                            .foregroundStyle(Color("SecondaryText"))
                    }
                    report
                    // X9: the anchor the `-scroll end` capture scrolls to.
                    Color.clear.frame(height: 0).id("summary-end")
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .background(Color("Ground"))
            .navigationBarHidden(true)
            // X9: the last card must clear the floating tab bar — inset
            // equal to the bar plus 16 pt.
            .contentMargins(.bottom, 112, for: .scrollContent)
            .onAppear {
                #if DEBUG
                DemoMarker.mark("summary")
                // W1: demo arguments win over stored settings — two separate
                // onAppears used to race, the stored period overwriting the
                // demo one, which is why the day pills never appeared.
                applyDemoArguments()
                if DemoMode.scroll == "end" {
                    proxy.scrollTo("summary-end", anchor: .bottom)
                }
                if DemoMode.isEnabled, DemoMode.period != nil || DemoMode.day != nil {
                    return
                }
                #endif
                period = appState.settings.summaryPeriod
            }
        }
    }

    /// The page title row, like the other tabs (W5).
    private var titleRow: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Summary")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(Color("PrimaryText"))
            Spacer()
            Text(HomeScreen.dateLine)
                .font(.footnote)
                .foregroundStyle(Color("SecondaryText"))
        }
    }

    // MARK: - Period tabs

    private var periods: [Core.SummaryPeriod] {
        // B7: Yearly is one switch — hidden until a device proves a
        // year of history (08 plan §11).
        var list: [Core.SummaryPeriod] = [.daily(day: nil), .weekly]
        // Part 2: Monthly hides when the diagnostics-reported history
        // is shorter than a month.
        if !FeatureSwitches.monthlyRequiresHistory || appState.settings.historyDays >= 28 {
            list.append(.monthly)
        }
        return list
    }

    /// W12: the one period control, shared with App detail.
    private var periodTabsControl: some View {
        PeriodTabsControl(
            tabs: periods.map { candidate in
                PeriodTabsControl.Tab(
                    title: title(candidate),
                    elapsed: elapsedFraction(for: candidate)
                )
            },
            selected: title(period)
        ) { selectedTitle in
            guard let candidate = periods.first(where: { title($0) == selectedTitle }) else { return }
            period = candidate
            appState.settings.summaryPeriod = candidate
        }
    }

    #if DEBUG
    /// W1: `-period` and `-day` (a pre-selected day pill) applied in one
    /// place, before the stored period is read.
    private func applyDemoArguments() {
        if let raw = DemoMode.period {
            period = Core.SummaryPeriod.from(rawValue: raw.rawValue)
        }
        if let day = DemoMode.day {
            period = .daily(
                day: Core.SummaryPeriod.pillDate(
                    index: day,
                    weekStartsOn: appState.settings.weekStartsOn,
                    calendar: ukCalendar
                )
            )
        }
    }
    #endif

    private func title(_ period: Core.SummaryPeriod) -> String {
        switch period {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        }
    }

    private func elapsedFraction(for candidate: Core.SummaryPeriod) -> Double {
        switch candidate {
        case .daily:
            return Core.PeriodProgress.dayFraction(calendar: ukCalendar)
        case .weekly:
            return Core.PeriodProgress.weekFraction(weekStartsOn: appState.settings.weekStartsOn, calendar: ukCalendar)
        case .monthly:
            return Core.PeriodProgress.monthFraction(calendar: ukCalendar)
        }
    }

    // MARK: - Day pills (Daily only)

    private var showsDayPills: Bool {
        if case .daily = period { return true }
        return false
    }

    private var dayPills: some View {
        DayPillsRow(
            period: $period,
            weekStartsOn: appState.settings.weekStartsOn,
            calendar: ukCalendar
        )
    }

    // MARK: - Report

    @ViewBuilder
    private var report: some View {
        #if DEBUG
        if DemoMode.isEnabled {
            // X1: the demo data follows the live period state — the
            // chosen day's figures, not just the launch argument.
            let config = demoConfiguration
            SummaryView(configuration: config, initialFocus: demoFocus)
                .frame(minHeight: summaryHeight(appCount: config.items.count))
        } else {
            liveReport
        }
        #else
        liveReport
        #endif
    }

    #if DEBUG
    /// The demo Summary for the current period state, including the
    /// selected day (X1).
    private var demoConfiguration: SummaryConfiguration {
        switch period {
        case .daily(let day):
            let dayIndex: Int?
            if let day {
                dayIndex = Core.SummaryPeriod.pillIndexOf(
                    date: day,
                    weekStartsOn: appState.settings.weekStartsOn,
                    calendar: ukCalendar
                )
            } else {
                dayIndex = nil
            }
            return DemoData.summary(period: .today, dayIndex: dayIndex)
        case .weekly:
            return DemoData.summary(period: .week)
        case .monthly:
            return DemoData.summary(period: .month)
        }
    }
    #endif

    private var liveReport: some View {
        let count = max(appState.orderedTokens.count, 1)
        return DeviceActivityReport(
            .summary,
            filter: Filters.summary(
                enabled: appState.enabledTokens,
                period: period,
                weekStartsOn: appState.settings.weekStartsOn
            )
        )
        .frame(minHeight: summaryHeight(appCount: count))
    }

    /// Donut block + 72 pt per enabled app (plan §7).
    private func summaryHeight(appCount: Int) -> CGFloat {
        return 300 + CGFloat(appCount) * 72 + 16
    }
}
