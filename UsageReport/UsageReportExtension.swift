// UsageReportExtension — the report extension entry point. One scene per
// context; all computation happens in makeConfiguration via Aggregator +
// Core + SharedSettings, and the views only render configurations.

import DeviceActivity
import SwiftUI

@main
struct UsageReportExtension: DeviceActivityReportExtension {

    var body: some DeviceActivityReportScene {
        HomeTotalScene { configuration in
            HeroCardView(configuration: configuration)
        }
        AppRowScene { configuration in
            AppRowReportView(configuration: configuration)
        }
        AppDetailScene { configuration in
            AppDetailCardView(configuration: configuration)
        }
        SummaryScene { configuration in
            SummaryView(configuration: configuration)
        }
        #if DEBUG
        // Diagnostics is debug-only: excluded from release builds.
        DiagnosticsScene { configuration in
            DiagnosticsReportView(configuration: configuration)
        }
        #endif
    }
}
