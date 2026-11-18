// ChartGeometry — the vertical maths for the daily bar chart (V3):
// one shared baseline, heights as fractions of a scale maximum, the
// dashed target rule as a fraction of the same maximum. Bars rise from
// the baseline; a bar crosses the line only when its day is over target.

import Foundation

public enum ChartGeometry {

    /// The scale maximum: the larger of 1.5 × the target and the tallest
    /// day, so the chart never clips a bar and the rule sits at 2/3 when
    /// the week is inside target.
    public static func maximum(targetMinutes: Int?, tallestMinutes: Double) -> Double {
        let targetScale = Double(targetMinutes ?? 0) * 1.5
        return max(targetScale, tallestMinutes, 1)
    }

    /// A bar's height as a fraction of the chart, from the baseline up.
    public static func heightFraction(minutes: Double, maximum: Double) -> Double {
        guard maximum > 0 else { return 0 }
        return min(max(minutes / maximum, 0), 1)
    }

    /// The target rule's height as a fraction of the chart; nil hides it.
    public static func ruleFraction(targetMinutes: Int?, maximum: Double) -> Double? {
        guard let target = targetMinutes, maximum > 0 else { return nil }
        return min(max(Double(target) / maximum, 0), 1)
    }
}
