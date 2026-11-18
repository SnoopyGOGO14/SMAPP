// Haptics — a light tap on switches and presets (Block J4). Respects
// nothing to disable: system switches provide their own feedback; this
// covers our custom preset buttons and target actions.

import UIKit

enum Haptics {
    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
