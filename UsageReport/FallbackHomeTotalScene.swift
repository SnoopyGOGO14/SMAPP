// FallbackHomeTotalScene — Part 2's App Group fallback: when the
// report cannot read shared settings, the host encodes the target and
// amber point into the context name (Core.ContextCodec, e.g.
// "homeTotal.t180.a75") and this scene decodes them. Registered for
// every 15-minute target step (15 m to 8 h) at the default amber point.

import DeviceActivity
import SwiftUI
import FamilyControls
import Core

struct FallbackHomeTotalScene: DeviceActivityReportScene {

    let context: DeviceActivityReport.Context
    let content: (HomeTotalConfiguration) -> HeroCardView

    func makeConfiguration(
        representing data: DeviceActivityResults<DeviceActivityData>
    ) async -> HomeTotalConfiguration {
        let seconds = await Aggregator.totalSeconds(data)
        let decoded = Core.ContextCodec.decode(context.rawValue)
        return HomeTotalConfiguration(
            usedMinutes: seconds / 60,
            allowanceMinutes: decoded?.targetMinutes
        )
    }
}
