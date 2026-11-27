// FeatureSwitches — the two switches a first on-phone run needs
// (Part 1.4: the rest are parked; docs/gate-a-outcomes.md says when
// each returns). Foundation-free for the monitor's sources list.

public enum FeatureSwitches {

    /// Monthly needs ≥ 28 days of history (historyDays from
    /// Diagnostics); below that the tab hides or captions the span.
    public static var monthlyRequiresHistory = false

    /// Alerts off entirely while the thresholds are under test.
    public static var alertsKillSwitch = false
}
