// Zone — the traffic-light state for a usage figure against an allowance.
// Spec: 01-BUILD-SPEC-v2.md § "Data model and zone logic".
// Green under 75% of allowance, amber 75–100%, red over 100%.

import Foundation

public enum Zone: String, CaseIterable, Codable {
    case green
    case amber
    case red
}

/// Exactly the calculator from the spec. Unit tested at the 75% and 100%
/// boundaries; used by both extensions via the Shared module.
public func zone(
    usedMinutes: Double,
    allowanceMinutes: Double,
    amberFraction: Double
) -> Zone {
    guard allowanceMinutes > 0 else { return .green }
    let ratio = usedMinutes / allowanceMinutes
    if ratio > 1.0 { return .red }
    if ratio >= amberFraction { return .amber }
    return .green
}
