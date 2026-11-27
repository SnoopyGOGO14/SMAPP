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
        // Part 2: Home rows in one report (fallback).
        AppRowsScene { configuration in
            AppRowsView(configuration: configuration)
        }
        // Part 2: the App Group fallback contexts (Core.ContextCodec,
        // every 15-minute target step at the default amber point).
        FallbackHomeTotalScene(context: .init("homeTotal.t015.a75")) { configuration in
            HeroCardView(configuration: configuration)
        }
        FallbackHomeTotalScene(context: .init("homeTotal.t030.a75")) { configuration in
            HeroCardView(configuration: configuration)
        }
        FallbackHomeTotalScene(context: .init("homeTotal.t045.a75")) { configuration in
            HeroCardView(configuration: configuration)
        }
        FallbackHomeTotalScene(context: .init("homeTotal.t060.a75")) { configuration in
            HeroCardView(configuration: configuration)
        }
        FallbackHomeTotalScene(context: .init("homeTotal.t075.a75")) { configuration in
            HeroCardView(configuration: configuration)
        }
        FallbackHomeTotalScene(context: .init("homeTotal.t090.a75")) { configuration in
            HeroCardView(configuration: configuration)
        }
        FallbackHomeTotalScene(context: .init("homeTotal.t105.a75")) { configuration in
            HeroCardView(configuration: configuration)
        }
        FallbackHomeTotalScene(context: .init("homeTotal.t120.a75")) { configuration in
            HeroCardView(configuration: configuration)
        }
        FallbackHomeTotalScene(context: .init("homeTotal.t135.a75")) { configuration in
            HeroCardView(configuration: configuration)
        }
        FallbackHomeTotalScene(context: .init("homeTotal.t150.a75")) { configuration in
            HeroCardView(configuration: configuration)
        }
        FallbackHomeTotalScene(context: .init("homeTotal.t165.a75")) { configuration in
            HeroCardView(configuration: configuration)
        }
        FallbackHomeTotalScene(context: .init("homeTotal.t180.a75")) { configuration in
            HeroCardView(configuration: configuration)
        }
        FallbackHomeTotalScene(context: .init("homeTotal.t195.a75")) { configuration in
            HeroCardView(configuration: configuration)
        }
        FallbackHomeTotalScene(context: .init("homeTotal.t210.a75")) { configuration in
            HeroCardView(configuration: configuration)
        }
        FallbackHomeTotalScene(context: .init("homeTotal.t225.a75")) { configuration in
            HeroCardView(configuration: configuration)
        }
        FallbackHomeTotalScene(context: .init("homeTotal.t240.a75")) { configuration in
            HeroCardView(configuration: configuration)
        }
        FallbackHomeTotalScene(context: .init("homeTotal.t255.a75")) { configuration in
            HeroCardView(configuration: configuration)
        }
        FallbackHomeTotalScene(context: .init("homeTotal.t270.a75")) { configuration in
            HeroCardView(configuration: configuration)
        }
        FallbackHomeTotalScene(context: .init("homeTotal.t285.a75")) { configuration in
            HeroCardView(configuration: configuration)
        }
        FallbackHomeTotalScene(context: .init("homeTotal.t300.a75")) { configuration in
            HeroCardView(configuration: configuration)
        }
        FallbackHomeTotalScene(context: .init("homeTotal.t315.a75")) { configuration in
            HeroCardView(configuration: configuration)
        }
        FallbackHomeTotalScene(context: .init("homeTotal.t330.a75")) { configuration in
            HeroCardView(configuration: configuration)
        }
        FallbackHomeTotalScene(context: .init("homeTotal.t345.a75")) { configuration in
            HeroCardView(configuration: configuration)
        }
        FallbackHomeTotalScene(context: .init("homeTotal.t360.a75")) { configuration in
            HeroCardView(configuration: configuration)
        }
        FallbackHomeTotalScene(context: .init("homeTotal.t375.a75")) { configuration in
            HeroCardView(configuration: configuration)
        }
        FallbackHomeTotalScene(context: .init("homeTotal.t390.a75")) { configuration in
            HeroCardView(configuration: configuration)
        }
        FallbackHomeTotalScene(context: .init("homeTotal.t405.a75")) { configuration in
            HeroCardView(configuration: configuration)
        }
        FallbackHomeTotalScene(context: .init("homeTotal.t420.a75")) { configuration in
            HeroCardView(configuration: configuration)
        }
        FallbackHomeTotalScene(context: .init("homeTotal.t435.a75")) { configuration in
            HeroCardView(configuration: configuration)
        }
        FallbackHomeTotalScene(context: .init("homeTotal.t450.a75")) { configuration in
            HeroCardView(configuration: configuration)
        }
        FallbackHomeTotalScene(context: .init("homeTotal.t465.a75")) { configuration in
            HeroCardView(configuration: configuration)
        }
        FallbackHomeTotalScene(context: .init("homeTotal.t480.a75")) { configuration in
            HeroCardView(configuration: configuration)
        }
        // Part 2: host-driven Summary focus (summary.f0 … f7).
        SummaryFocusScene(context: .init("summary.f0")) { configuration in
            SummaryView(configuration: configuration, initialFocus: configuration.initialFocus)
        }
        SummaryFocusScene(context: .init("summary.f1")) { configuration in
            SummaryView(configuration: configuration, initialFocus: configuration.initialFocus)
        }
        SummaryFocusScene(context: .init("summary.f2")) { configuration in
            SummaryView(configuration: configuration, initialFocus: configuration.initialFocus)
        }
        SummaryFocusScene(context: .init("summary.f3")) { configuration in
            SummaryView(configuration: configuration, initialFocus: configuration.initialFocus)
        }
        SummaryFocusScene(context: .init("summary.f4")) { configuration in
            SummaryView(configuration: configuration, initialFocus: configuration.initialFocus)
        }
        SummaryFocusScene(context: .init("summary.f5")) { configuration in
            SummaryView(configuration: configuration, initialFocus: configuration.initialFocus)
        }
        SummaryFocusScene(context: .init("summary.f6")) { configuration in
            SummaryView(configuration: configuration, initialFocus: configuration.initialFocus)
        }
        SummaryFocusScene(context: .init("summary.f7")) { configuration in
            SummaryView(configuration: configuration, initialFocus: configuration.initialFocus)
        }
        #if DEBUG
        // Diagnostics is debug-only: excluded from release builds.
        DiagnosticsScene { configuration in
            DiagnosticsReportView(configuration: configuration)
        }
        #endif
    }
}
