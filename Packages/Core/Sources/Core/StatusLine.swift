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
    let parts = statusParts(
        usedMinutes: usedMinutes,
        targetMinutes: targetMinutes,
        amberFraction: amberFraction
    )
    if parts.remainder.isEmpty {
        return parts.word
    }
    return "\(parts.word) · \(parts.remainder)"
}
