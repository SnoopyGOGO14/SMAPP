// FeatureSwitches — Part 2: one fallback per Gate A outcome, each a
// one-line flip. Defaults keep today's behaviour; docs/gate-a-outcomes.md
// maps each Diagnostics FAIL to the switch that fixes it. Compiled into
// every target (the monitor needs the alerts kill switch; no imports —
// this file must stay Foundation-free for the monitor's sources list).

public enum FeatureSwitches {

    public enum HomeRowsMode: String {
        case perRow
        case single
    }

    public enum SummaryFocusMode: String {
        case inReport
        case hostDriven
    }

    /// Home rows: one embedded report per row (default), or a single
    /// report drawing all rows with host-side transparent tap areas.
    public static var homeRowsMode: HomeRowsMode = .perRow

    /// Summary focus: taps inside the report (default), or a
    /// host-driven legend strip passing focus by context name
    /// (summary.f0 … summary.f7).
    public static var summaryFocusMode: SummaryFocusMode = .inReport

    /// App Group fallback: the host encodes target/amber into the
    /// report context name (Core.ContextCodec).
    public static var appGroupContextFallback = false

    /// Monthly needs ≥ 28 days of history (historyDays from
    /// Diagnostics); below that the tab hides or captions the span.
    public static var monthlyRequiresHistory = false

    /// Alerts off entirely while the thresholds are under test.
    public static var alertsKillSwitch = false
}
