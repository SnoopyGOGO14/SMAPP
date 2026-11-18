// ReportContexts — the report contexts. Compiled into the app and
// UsageReport only. DeviceActivityReport is a SwiftUI overlay type, so
// SwiftUI must be imported alongside DeviceActivity.

import SwiftUI
import DeviceActivity

extension DeviceActivityReport.Context {
    /// Home card: today's hero total, bar and status line.
    public static let homeTotal = Self("homeTotal")
    /// One Home row: time and thin bar for a single app.
    public static let appRow = Self("appRow")
    /// App detail: today card plus the chosen period card and stats.
    public static let appDetail = Self("appDetail")
    /// Summary: ranked donut, centre text and app cards in one report.
    public static let summary = Self("summary")
}
