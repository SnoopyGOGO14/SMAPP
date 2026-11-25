// SummaryConfiguration — the plain data the Summary views render. The
// report scene builds it from real activity; demo mode builds it from
// sample figures. Names: tokens render through Label(token) in the
// extension; demo names are plain strings.

import Foundation
import FamilyControls
import ManagedSettings
import Core

public struct SummaryItem: Identifiable, Equatable {
    public let id: Int
    /// Rank colour index (0 = largest). Also the focus identity.
    public let rank: Int
    /// Position in the user's row order (B7: the colour-by-order
    /// alternative); defaults to the rank.
    public let position: Int
    /// Minutes over the chosen period.
    public let minutes: Double
    /// Share of total, percent, one decimal (e.g. 37.2).
    public let sharePercent: Double
    /// Real token when rendered by the extension; nil in demo mode.
    public let token: ApplicationToken?
    /// Demo name; used only when token is nil.
    public let demoName: String

    public init(
        id: Int,
        rank: Int,
        minutes: Double,
        sharePercent: Double,
        token: ApplicationToken? = nil,
        demoName: String = "",
        position: Int? = nil
    ) {
        self.id = id
        self.rank = rank
        self.position = position ?? rank
        self.minutes = minutes
        self.sharePercent = sharePercent
        self.token = token
        self.demoName = demoName
    }
}

public struct SummaryConfiguration: Equatable {
    /// Small-caps centre label, e.g. "Weekly usage".
    public let periodLabel: String
    /// Total minutes over the period.
    public let totalMinutes: Double
    public let items: [SummaryItem]

    public init(periodLabel: String, totalMinutes: Double, items: [SummaryItem]) {
        self.periodLabel = periodLabel
        self.totalMinutes = totalMinutes
        self.items = items
    }

    public var topItem: SummaryItem? {
        return items.first
    }
}
