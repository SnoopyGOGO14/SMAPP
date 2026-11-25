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
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                periodTabs
                if showsDayPills {
                    dayPills
                }
                report
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .background(Color("Ground"))
        .navigationBarHidden(true)
        #if DEBUG
        .onAppear { DemoMarker.mark("summary") }
        .onAppear {
            if let raw = DemoMode.period {
                period = Core.SummaryPeriod.from(rawValue: raw.rawValue)
            }
        }
        #endif
        .onAppear {
            period = appState.settings.summaryPeriod
        }
    }

    // MARK: - Period tabs

    private var periods: [Core.SummaryPeriod] {
        // B7: Yearly is one switch — hidden until a device proves a
        // year of history (08 plan §11).
        var list: [Core.SummaryPeriod] = [.daily(day: nil), .weekly, .monthly]
        if SummaryDefaults.showYearly {
            list.append(.yearly)
        }
        return list
    }

    private var periodTabs: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(periods, id: \.rawValueString) { candidate in
                    periodTab(candidate)
                }
            }
            Rectangle()
                .fill(Color("Divider"))
                .frame(height: 1)
        }
    }

    private func periodTab(_ candidate: Core.SummaryPeriod) -> some View {
        let isActive = period.rawValueString == candidate.rawValueString
        return VStack(spacing: 4) {
            Button {
                period = candidate
                appState.settings.summaryPeriod = candidate
            } label: {
                Text(title(candidate))
                    .font(.caption.weight(isActive ? .bold : .semibold))
                    .tracking(0.6)
                    .textCase(.uppercase)
                    .foregroundStyle(isActive ? Color("PrimaryText") : Color("MutedText"))
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(isActive ? [.isSelected] : [])

            // The filled part shows how much of the period has elapsed.
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Rectangle().fill(Color("BarTrack"))
                    if isActive {
                        Rectangle()
                            .fill(Color("Rank1"))
                            .frame(width: proxy.size.width * elapsedFraction)
                    }
                }
            }
            .frame(height: 2)
            .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity)
    }

    private func title(_ period: Core.SummaryPeriod) -> String {
        switch period {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }

    private var elapsedFraction: Double {
        switch period {
        case .daily:
            return Core.PeriodProgress.dayFraction(calendar: ukCalendar)
        case .weekly:
            return Core.PeriodProgress.weekFraction(weekStartsOn: appState.settings.weekStartsOn, calendar: ukCalendar)
        case .monthly:
            return Core.PeriodProgress.monthFraction(calendar: ukCalendar)
        case .yearly:
            return Core.PeriodProgress.monthFraction(calendar: ukCalendar)
        }
    }

    // MARK: - Day pills (Daily only)

    private var showsDayPills: Bool {
        if case .daily = period { return true }
        return false
    }

    private var dayPills: some View {
        let weekStartsOn = appState.settings.weekStartsOn
        let todayIndex = Core.SummaryPeriod.daily(day: nil)
            .todayPillIndex(weekStartsOn: weekStartsOn, calendar: ukCalendar) ?? 0
        let future = Core.SummaryPeriod.daily(day: nil)
            .futurePillIndexes(weekStartsOn: weekStartsOn, calendar: ukCalendar)

        return HStack(spacing: 6) {
            ForEach(0..<7, id: \.self) { index in
                let isToday = index == todayIndex
                let isFuture = future.contains(index)
                Button {
                    period = .daily(day: Core.SummaryPeriod.pillDate(index: index, weekStartsOn: weekStartsOn, calendar: ukCalendar))
                } label: {
                    Text(pillTitle(index, weekStartsOn: weekStartsOn))
                        .font(.caption2.weight(isToday ? .bold : .medium))
                        .frame(maxWidth: .infinity)
                        .frame(height: 28)
                        .background(
                            isToday ? AnyShapeStyle(Color("PrimaryText")) : AnyShapeStyle(Color("Card")),
                            in: RoundedRectangle(cornerRadius: 8)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isToday ? Color.clear : Color("Divider"), lineWidth: 1)
                        )
                        .foregroundStyle(isToday ? Color("Ground") : Color("MutedText"))
                }
                .buttonStyle(.plain)
                .disabled(isFuture)
                .opacity(isFuture ? 0.4 : 1)
                .accessibilityAddTraits(isToday ? [.isSelected] : [])
            }
        }
    }

    private func pillTitle(_ index: Int, weekStartsOn: Int) -> String {
        let date = Core.SummaryPeriod.pillDate(index: index, weekStartsOn: weekStartsOn, calendar: ukCalendar)
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        let short = formatter.string(from: date)
        return String(short.prefix(3))
    }

    // MARK: - Report

    @ViewBuilder
    private var report: some View {
        #if DEBUG
        if DemoMode.isEnabled {
            let config = DemoData.summary(period: DemoMode.period ?? .weekly)
            SummaryView(configuration: config, initialFocus: demoFocus)
                .frame(minHeight: summaryHeight(appCount: config.items.count))
        } else {
            liveReport
        }
        #else
        liveReport
        #endif
    }

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
