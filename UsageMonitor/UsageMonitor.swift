// Session 0 placeholder — empty monitor so the extension compiles.
// Session 6 fills in eventDidReachThreshold (sanity guard, checkpoint,
// notifications). Classic app extension: no @main, the principal class is
// named in UsageMonitor-Info.plist. Keep imports minimal (≈6 MB memory
// ceiling): no SwiftUI, no Charts, ever.

import DeviceActivity

final class UsageMonitor: DeviceActivityMonitor {
}
