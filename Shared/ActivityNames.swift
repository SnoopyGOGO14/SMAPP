// ActivityNames — the two DeviceActivity schedule names, shared by the
// app (scheduler) and UsageMonitor (event handling). DeviceActivity only,
// so it is safe to compile into the monitor.

import Foundation
import DeviceActivity

extension DeviceActivityName {
    static let daily = Self("daily")
    static let weekly = Self("weekly")
}
