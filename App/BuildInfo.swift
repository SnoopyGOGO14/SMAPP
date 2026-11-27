// BuildInfo — version and commit for the Diagnostics report. The
// commit is a placeholder in local builds; CI can overwrite it (the
// string lives in exactly one place for that reason).

import Foundation

enum BuildInfo {
    static var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
    }
    /// Overwritten by CI in real builds; "dev" locally.
    static var commit: String = "dev"
}
