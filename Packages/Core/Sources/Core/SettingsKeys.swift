// SettingsKeys — App Group UserDefaults keys, exactly as named in the spec's
// data model table. Written by the main app only, except lastCheckpoint,
// which is written by UsageMonitor.
// These strings are the on-disk contract; never rename them once shipped.

import Foundation

public enum SettingsKeys {
    /// Data — encoded FamilyActivitySelection (every app the user picked).
    public static let selection = "selection"
    /// Data — encoded Set<ApplicationToken> (apps whose switch is on).
    public static let enabledTokens = "enabledTokens"
    /// Bool — master switch.
    public static let monitoringEnabled = "monitoringEnabled"
    /// String — TargetMode raw value, "daily" or "weekly".
    public static let targetMode = "targetMode"
    /// Int — target in minutes for the chosen mode.
    public static let targetMinutes = "targetMinutes"
    /// Double — where amber begins, default 0.75.
    public static let amberFraction = "amberFraction"
    /// Bool — zone notifications on or off.
    public static let alertsEnabled = "alertsEnabled"
    /// Int — week start day, 1 (Sunday) … 7 (Saturday). Follows device locale.
    public static let weekStartsOn = "weekStartsOn"
    /// Bool — evening and Sunday recap notifications.
    public static let recapsEnabled = "recapsEnabled"
    /// Data — encoded Checkpoint. Written by UsageMonitor only; approximate
    /// reading for recap messages and the future widget.
    public static let lastCheckpoint = "lastCheckpoint"
}
