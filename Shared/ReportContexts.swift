// ReportContexts — the five report contexts. Compiled into the app and
// UsageReport only. DeviceActivityReport is a SwiftUI overlay type, so
// SwiftUI must be imported alongside DeviceActivity.

import SwiftUI
import DeviceActivity

extension DeviceActivityReport.Context {
    /// Home card: today's hero total, bar and status line.
    public static let homeTotal = Self("homeTotal")
    /// One Home row: time and thin bar for a single app.
    public static let appRow = Self("appRow")
    /// One All-apps row: time only.
    public static let appTime = Self("appTime")
    /// App detail: today card plus the chosen period card and stats.
    public static let appDetail = Self("appDetail")
    /// All apps: donut of time per platform with the centre total.
    public static let allApps = Self("allApps")
}
