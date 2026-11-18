// Ranking — Summary's ordering rule (08 plan §8): apps sorted by time,
// largest first; ties keep orderedTokens order; zero-time apps drop
// out; the rank index assigns the rank-colour (wraps at 8); share of
// total to one decimal. Tokens are opaque, so colour goes by rank,
// never by app identity.

import Foundation

public struct RankedApp: Equatable {
    /// Position in orderedTokens (identity for ties and tests).
    public let position: Int
    public let seconds: Double
    /// 0-based: the largest app is rank 0.
    public let rank: Int
    /// Share of total, percent, one decimal (e.g. 37.2).
    public let sharePercent: Double

    public init(position: Int, seconds: Double, rank: Int, sharePercent: Double) {
        self.position = position
        self.seconds = seconds
        self.rank = rank
        self.sharePercent = sharePercent
    }
}

public enum Ranking {

    public static func rank(apps: [(position: Int, seconds: Double)]) -> [RankedApp] {
        let withTime = apps.filter { $0.seconds > 0 }
        let total = withTime.reduce(0.0) { $0 + $1.seconds }
        guard total > 0 else { return [] }

        // Largest first; ties keep the original order (stable sort on
        // descending seconds).
        let sorted = withTime.enumerated().sorted { lhs, rhs in
            if lhs.element.seconds != rhs.element.seconds {
                return lhs.element.seconds > rhs.element.seconds
            }
            // enumerated index preserves input order for equal values
            return lhs.offset < rhs.offset
        }

        return sorted.map { _, entry in
            RankedApp(
                position: entry.position,
                seconds: entry.seconds,
                rank: 0, // filled below
                sharePercent: (entry.seconds / total * 1000).rounded() / 10
            )
        }
        .enumerated()
        .map { index, app in
            RankedApp(
                position: app.position,
                seconds: app.seconds,
                rank: index,
                sharePercent: app.sharePercent
            )
        }
    }
}
