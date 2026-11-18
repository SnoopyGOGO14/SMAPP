// Aggregator — the single walker of DeviceActivityResults. All five
// scenes get their figures through it; nothing else touches the data
// structures. Verified against Apple's documentation pages for
// DeviceActivityResults, DeviceActivityData, ActivitySegment,
// CategoryActivity and ApplicationActivity.
//
// SwiftUI import is required: in explicit-module extension builds the
// DeviceActivity SwiftUI overlay types (DeviceActivityResults and
// friends) are only visible with both imports.

import Foundation
import SwiftUI
import DeviceActivity
import FamilyControls
import ManagedSettings
import os

enum Aggregator {

    private static let logger = Logger(subsystem: "com.YOURORG.socialtimemonitor", category: "UsageReport")

    struct DayTotal: Equatable {
        let dayStart: Date
        let seconds: TimeInterval
    }

    /// Total seconds per application token across the whole result set.
    static func secondsByToken(
        _ data: DeviceActivityResults<DeviceActivityData>
    ) async -> [ApplicationToken: TimeInterval] {
        var result: [ApplicationToken: TimeInterval] = [:]
        for await device in data {
            for await segment in device.activitySegments {
                for await category in segment.categories {
                    for await app in category.applications {
                        guard let token = app.application.token else { continue }
                        result[token, default: 0] += app.totalActivityDuration
                    }
                }
            }
        }
        return result
    }

    /// Seconds per token per day (keyed by the segment's day start).
    static func dailySecondsByToken(
        _ data: DeviceActivityResults<DeviceActivityData>
    ) async -> [ApplicationToken: [DayTotal]] {
        var result: [ApplicationToken: [DayTotal]] = [:]
        for await device in data {
            for await segment in device.activitySegments {
                let day = segment.dateInterval.start
                for await category in segment.categories {
                    for await app in category.applications {
                        guard let token = app.application.token else { continue }
                        result[token, default: []]
                            .append(DayTotal(dayStart: day, seconds: app.totalActivityDuration))
                    }
                }
            }
        }
        return result
    }

    /// Sum of every application's seconds (correct for single-token
    /// filters, and for the overall total on multi-token filters).
    static func totalSeconds(
        _ data: DeviceActivityResults<DeviceActivityData>
    ) async -> TimeInterval {
        var total: TimeInterval = 0
        for await device in data {
            for await segment in device.activitySegments {
                for await category in segment.categories {
                    for await app in category.applications {
                        total += app.totalActivityDuration
                    }
                }
            }
        }
        return total
    }
}
