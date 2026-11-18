// StatusLine — the single line under a bar: zone word, then the figure.
//   green  "Comfortable · 29m left"
//   amber  "Getting close · 14m left"
//   red    "Over target · by 7m"
// Exactly on target is amber with "0m left". Neutral (no target) is empty.

import Foundation

public func statusLine(
    usedMinutes: Double,
    targetMinutes: Int?,
    amberFraction: Double
) -> String {
    guard let target = targetMinutes, target > 0 else { return "" }
    let zone = Core.zone(
        usedMinutes: usedMinutes,
        allowanceMinutes: Double(target),
        amberFraction: amberFraction
    )
    switch zone {
    case .green:
        return "Comfortable · \(DurationFormat.left(minutes: Int((Double(target) - usedMinutes).rounded())))"
    case .amber:
        return "Getting close · \(DurationFormat.left(minutes: Int((Double(target) - usedMinutes).rounded())))"
    case .red:
        return "Over target · by \(DurationFormat.short(minutes: Int((usedMinutes - Double(target)).rounded())))"
    }
}
