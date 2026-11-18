// DemoMode — debug builds only. `-demo` replaces every embedded report
// with the matching SharedUI view fed from DemoData (Screen Time data
// never appears in a simulator); `-screen <name>` opens one screen
// directly for screenshot capture. Release builds contain none of this.

import Foundation

enum DemoMode {
    static var isEnabled: Bool {
        #if DEBUG
        return CommandLine.arguments.contains("-demo")
        #else
        return false
        #endif
    }

    /// "home", "allapps", "detail", "target", "onboarding", or nil.
    static var screen: String? {
        #if DEBUG
        guard let index = CommandLine.arguments.firstIndex(of: "-screen"),
              index + 1 < CommandLine.arguments.count else { return nil }
        return CommandLine.arguments[index + 1]
        #else
        return nil
        #endif
    }
}
