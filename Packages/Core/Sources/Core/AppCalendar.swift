// AppCalendar — the app's reference calendar: UK time (Europe/London),
// so "today" and the day pills follow the UK day boundary even if the
// device travels. DST changes (GMT ↔ BST) are handled by the system
// time-zone database automatically. Foundation only — no third-party
// date library needed (Luxon et al. are JavaScript; SwiftDate & co.
// would violate the Apple-frameworks-only rule for no gain).

import Foundation

public enum AppCalendar {

    /// The app's calendar: gregorian, Europe/London, British locale.
    /// Falls back to the device calendar if the zone is somehow missing.
    public static func uk() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/London") ?? .current
        calendar.locale = Locale(identifier: "en_GB")
        return calendar
    }

    /// Whether the UK calendar is genuinely available (test support).
    public static var londonZoneAvailable: Bool {
        return TimeZone(identifier: "Europe/London") != nil
    }
}
