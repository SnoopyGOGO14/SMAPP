// HomeTotalScene — the Home card. Sums whatever interval the app filtered
// (today in daily mode, the week so far in weekly mode) and colours it
// against the allowance from the spec's table.

import DeviceActivity
import SwiftUI
import FamilyControls
import Core

struct HomeTotalScene: DeviceActivityReportScene {

    let context: DeviceActivityReport.Context = .homeTotal
    let content: (HomeTotalConfiguration) -> HeroCardView

    func makeConfiguration(
        representing data: DeviceActivityResults<DeviceActivityData>
    ) async -> HomeTotalConfiguration {
        let settings = SharedSettings()
        let seconds = await Aggregator.totalSeconds(data)
        let allowance: Int?
        if let target = settings.targetMinutes {
            allowance = TargetMath.allowanceMinutes(
                view: .todayRing,
                mode: settings.targetMode,
                targetMinutes: target
            )
        } else {
            allowance = nil
        }
        return HomeTotalConfiguration(
            usedMinutes: seconds / 60,
            allowanceMinutes: allowance
        )
    }
}
