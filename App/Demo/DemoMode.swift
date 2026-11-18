// DemoMode — debug builds only. `-demo` replaces every embedded report
// with the matching SharedUI view fed from DemoData (Screen Time data
// never appears in a simulator); `-screen <name>` opens one screen
// directly for screenshot capture; `-card 1…4` picks the onboarding
// card. DemoMarker lets the capture workflow verify the screen it
// photographed. Release builds contain none of this.

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
        return value(after: "-screen")
        #else
        return nil
        #endif
    }

    /// 1…4 for onboarding cards; nil otherwise.
    static var card: Int? {
        #if DEBUG
        return value(after: "-card").flatMap(Int.init)
        #else
        return nil
        #endif
    }

    private static func value(after flag: String) -> String? {
        let arguments = CommandLine.arguments
        guard let index = arguments.firstIndex(of: flag),
              index + 1 < arguments.count else { return nil }
        return arguments[index + 1]
    }
}

#if DEBUG
/// Writes the active screen's name into the app container so the
/// screenshot workflow can prove which screen it captured (F1/F2).
enum DemoMarker {
    static func mark(_ screen: String) {
        guard DemoMode.isEnabled else { return }
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("demo-screen.txt")
        try? screen.write(to: url, atomically: true, encoding: .utf8)
    }
}
#endif
