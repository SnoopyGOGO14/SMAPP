// DemoTile — the demo app tile (W14, Y1): filled with the app's
// row-order colour — the same one its Summary dot uses — so each of
// the five apps keeps one distinct colour everywhere in demo captures
// (X2: colour follows position, never rank). Real builds show the real
// icon via Label(token). Debug builds only.

#if DEBUG
import SwiftUI
import Core

struct DemoTile: View {

    /// The app's position in the user's row order — its colour index.
    let position: Int
    let initials: String
    var size: CGFloat = 36

    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.28)
            .fill(RankColors.color(position: position))
            .frame(width: size, height: size)
            .overlay(
                Text(initials)
                    .font(.system(size: size * 0.34, weight: .bold))
                    .foregroundStyle(Color("Ground"))
                    .minimumScaleFactor(0.6)
            )
            .accessibilityHidden(true)
    }
}
#endif
