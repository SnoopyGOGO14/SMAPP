// AppZone — the zone for a single app against its own optional daily
// target. An app with no target is neutral (slate bar, no marker).
// Boundaries reuse the overall zone rules: amber from `amberFraction`
// of the target, red over 100%.

import Foundation

public enum AppZone: String, Equatable, CaseIterable {
    case green
    case amber
    case red
    case neutral
}

public func appZone(
    usedMinutes: Double,
    targetMinutes: Int?,
    amberFraction: Double
) -> AppZone {
    guard let target = targetMinutes, target > 0 else { return .neutral }
    switch Core.zone(
        usedMinutes: usedMinutes,
        allowanceMinutes: Double(target),
        amberFraction: amberFraction
    ) {
    case .green: return .green
    case .amber: return .amber
    case .red: return .red
    }
}
