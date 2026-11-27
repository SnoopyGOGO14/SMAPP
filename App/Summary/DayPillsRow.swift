// DayPillsRow — the Mon–Sun pill row on Summary's Daily view (08 plan
// §3, W1): today reads as selected (inverted) by default, the picked
// day once one is chosen, future days disabled. Tap selects that day.
// Split out of SummaryScreen to keep both files under 250 lines.

import SwiftUI
import Core

struct DayPillsRow: View {

    @Binding var period: Core.SummaryPeriod
    let weekStartsOn: Int
    let calendar: Calendar

    var body: some View {
        let todayIndex = Core.SummaryPeriod.daily(day: nil)
            .todayPillIndex(weekStartsOn: weekStartsOn, calendar: calendar) ?? 0
        let future = Core.SummaryPeriod.daily(day: nil)
            .futurePillIndexes(weekStartsOn: weekStartsOn, calendar: calendar)

        return HStack(spacing: 6) {
            ForEach(0..<7, id: \.self) { index in
                let isToday = index == todayIndex
                let isFuture = future.contains(index)
                let pillDate = Core.SummaryPeriod.pillDate(index: index, weekStartsOn: weekStartsOn, calendar: calendar)
                // W1: without the selected style, picking a day changed
                // nothing visible — the day2 capture was a pixel-duplicate
                // of the daily one. Failure class 8: the test lives in a
                // helper, never a deferred `let` inside a ViewBuilder.
                let isSelected = Self.isSelectedPill(
                    index: index,
                    todayIndex: todayIndex,
                    period: period,
                    pillDate: pillDate,
                    calendar: calendar
                )
                Button {
                    period = .daily(day: pillDate)
                } label: {
                    Text(pillTitle(index))
                        .font(.caption2.weight(isToday ? .bold : (isSelected ? .semibold : .medium)))
                        .frame(maxWidth: .infinity)
                        .frame(height: 28)
                        .background(
                            isSelected ? AnyShapeStyle(Color("PrimaryText")) : AnyShapeStyle(Color("Card")),
                            in: RoundedRectangle(cornerRadius: 8)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isSelected ? Color.clear : Color("Divider"), lineWidth: 1)
                        )
                        .foregroundStyle(isSelected ? Color("Ground") : Color("MutedText"))
                }
                .buttonStyle(.plain)
                .disabled(isFuture)
                .opacity(isFuture ? 0.4 : 1)
                .accessibilityAddTraits(isSelected ? [.isSelected] : [])
            }
        }
    }

    /// W1: which pill reads as selected — the picked day, or today when
    /// none is picked (Daily view only).
    private static func isSelectedPill(
        index: Int,
        todayIndex: Int,
        period: Core.SummaryPeriod,
        pillDate: Date,
        calendar: Calendar
    ) -> Bool {
        switch period {
        case .daily(let day):
            if let day {
                return calendar.isDate(day, inSameDayAs: pillDate)
            }
            return index == todayIndex
        case .weekly, .monthly:
            return false
        }
    }

    private func pillTitle(_ index: Int) -> String {
        let date = Core.SummaryPeriod.pillDate(index: index, weekStartsOn: weekStartsOn, calendar: calendar)
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        let short = formatter.string(from: date)
        return String(short.prefix(3))
    }
}
