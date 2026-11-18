// BarGeometry — fill and marker fractions for the design's bars.
// Overall bar scale: 4/3 × the overall target (marker at 75%).
// App bar scale: 1.5 × the app's target (marker at 2/3); an app with no
// target is scaled against 1.5 × the largest app that day and shows no
// marker (mock reference: 14 of 58 → fill ≈ 0.16).

import Foundation

public struct BarGeometry: Equatable {
    /// 0…1, clamped.
    public let fill: Double
    /// 0…1 position of the target line; nil when there is no target.
    public let marker: Double?

    /// The Home card's overall bar.
    public static func overall(usedMinutes: Double, targetMinutes: Int) -> BarGeometry {
        let scale = Double(targetMinutes) * 4.0 / 3.0
        return BarGeometry(
            fill: clamp(usedMinutes / scale),
            marker: clamp(Double(targetMinutes) / scale)
        )
    }

    /// A Home row's or App detail's per-app bar. Pass the largest app's
    /// usage that day so apps without a target still get a meaningful fill.
    public static func perApp(
        usedMinutes: Double,
        targetMinutes: Int?,
        largestAppMinutes: Double
    ) -> BarGeometry {
        if let target = targetMinutes {
            let scale = Double(target) * 1.5
            return BarGeometry(
                fill: clamp(usedMinutes / scale),
                marker: clamp(Double(target) / scale)
            )
        }
        let scale = max(1, largestAppMinutes) * 1.5
        return BarGeometry(fill: clamp(usedMinutes / scale), marker: nil)
    }

    private static func clamp(_ value: Double) -> Double {
        return min(max(value, 0), 1)
    }
}
