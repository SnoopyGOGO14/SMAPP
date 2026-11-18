// TokenCleanup — pure bookkeeping when apps leave the selection (Block I6).
// Generic so Core stays Foundation-only; unit tested with Int stand-ins.

import Foundation

public enum TokenCleanup {

    public struct Result<T: Hashable>: Equatable {
        public let ordered: [T]
        public let enabled: [T]
        public let targets: [(token: T, minutes: Int)]
    }

    /// Removes every token not present in `available` from the ordered
    /// list, the enabled list and the per-app targets, preserving order.
    public static func cleanup<T: Hashable>(
        ordered: [T],
        enabled: [T],
        targets: [(token: T, minutes: Int)],
        available: [T]
    ) -> Result<T> {
        let availableSet = Set(available)
        return Result(
            ordered: ordered.filter { availableSet.contains($0) },
            enabled: enabled.filter { availableSet.contains($0) },
            targets: targets.filter { availableSet.contains($0.token) }
        )
    }
}
