// Session 0 placeholder — empty scene so the report extension compiles.
// Session 2 replaces ScaffoldScene with TodaySummaryScene and the real contexts.
//
// Shape verified against Apple documentation (rule 8, README):
//   DeviceActivityReportExtension is a protocol whose `body` is a
//   DeviceActivityReportScene, one per supported context.
//   https://developer.apple.com/documentation/deviceactivity/deviceactivityreportextension.md

import DeviceActivity
import SwiftUI

extension DeviceActivityReport.Context {
    static let scaffold = Self("scaffold")
}

struct ScaffoldConfiguration: Codable {
    var title = "Scaffold"
}

struct ScaffoldScene: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .scaffold
    let content: (ScaffoldConfiguration) -> ScaffoldView

    func makeConfiguration(
        representing data: DeviceActivityResults<DeviceActivityData>
    ) async -> ScaffoldConfiguration {
        ScaffoldConfiguration()
    }
}

struct ScaffoldView: View {
    let configuration: ScaffoldConfiguration

    var body: some View {
        Text(configuration.title)
    }
}

@main
struct UsageReportExtension: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        ScaffoldScene { configuration in
            ScaffoldView(configuration: configuration)
        }
    }
}
