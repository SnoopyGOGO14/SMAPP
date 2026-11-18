// DonutMath — segments for the All apps donut. One segment per app with
// time, in orderedTokens order; zero-time apps are omitted. Angles are
// degrees, starting at -90 (12 o'clock), running clockwise. The palette
// index comes from the app's position in orderedTokens (wraps at 8).

import Foundation

public struct DonutSegment: Equatable {
    /// Fraction of the total, 0 < fraction ≤ 1.
    public let fraction: Double
    /// Degrees; -90 = 12 o'clock.
    public let startAngle: Double
    public let endAngle: Double
    /// Palette index for this app (position mod 8).
    public let paletteIndex: Int
}

/// `apps` pairs each app's position in `orderedTokens` with its seconds,
/// in order. Empty result when the total is zero.
public func donutSegments(apps: [(position: Int, seconds: Double)]) -> [DonutSegment] {
    let withTime = apps.filter { $0.seconds > 0 }
    let total = withTime.reduce(0.0) { $0 + $1.seconds }
    guard total > 0 else { return [] }

    var segments: [DonutSegment] = []
    var cursor = -90.0
    for app in withTime {
        let fraction = app.seconds / total
        let start = cursor
        let end = cursor + fraction * 360.0
        segments.append(
            DonutSegment(
                fraction: fraction,
                startAngle: start,
                endAngle: end,
                paletteIndex: Palette.index(for: app.position)
            )
        )
        cursor = end
    }
    return segments
}
