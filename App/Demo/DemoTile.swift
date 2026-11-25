// DemoTile — the demo app tile (W14): filled with the rank colour the
// Summary uses, so TikTok is the same colour on Home, Summary and
// detail in demo captures. Real builds show the real icon via
// Label(token). Debug builds only.

#if DEBUG
import SwiftUI
import Core

struct DemoTile: View {

    let rank: Int
    let initials: String
    var size: CGFloat = 36

    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.28)
            .fill(RankColors.color(rank))
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
