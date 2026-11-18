// DonutMath — segments for the ranked donut. One segment per app with
// time; zero-time apps are omitted. Angles are degrees, starting at
// -90 (12 o'clock), running clockwise in the order given (Summary
// passes them largest-first). The Summary ring is continuous — no
// gaps — with a minimum visible sweep of 1.5° for tiny shares, lifted
// then renormalised so the ring still totals 360° (08 plan §8).

import Foundation

public struct DonutSegment: Equatable {
    /// Fraction of the ring, 0 < fraction ≤ 1; the segments sum to 1.
    public let fraction: Double
    /// Degrees; -90 = 12 o'clock.
    public let startAngle: Double
    public let endAngle: Double
    /// Palette index for this app (position mod 8).
    public let paletteIndex: Int
}

/// `apps` pairs each app's position in `orderedTokens` with its seconds.
/// Order is preserved: pass Summary's ranked order for a
/// largest-first ring. Empty result when the total is zero.
public func donutSegments(apps: [(position: Int, seconds: Double)]) -> [DonutSegment] {
    let withTime = apps.filter { $0.seconds > 0 }
    let total = withTime.reduce(0.0) { $0 + $1.seconds }
    guard total > 0 else { return [] }

    // Minimum visible sweep of 1.5° for tiny shares; renormalise so the
    // ring totals 360°.
    let minimum = 1.5 / 360.0
    let lifted = withTime.map { app -> (position: Int, fraction: Double) in
        (app.position, Swift.max(app.seconds / total, minimum))
    }
    let liftedTotal = lifted.reduce(0.0) { $0 + $1.fraction }
    let normalized = lifted.map { app in
        (position: app.position, fraction: app.fraction / liftedTotal)
    }

    var segments: [DonutSegment] = []
    var cursor = -90.0
    for app in normalized {
        let start = cursor
        let end = cursor + app.fraction * 360.0
        segments.append(
            DonutSegment(
                fraction: app.fraction,
                startAngle: start,
                endAngle: end,
                paletteIndex: Palette.index(for: app.position)
            )
        )
        cursor = end
    }
    return segments
}
