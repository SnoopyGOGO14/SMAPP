// BarView — the design's bar: full-width rounded track, solid zone-coloured
// fill, optional white 3pt target marker across the full height.

import SwiftUI
import Core

public struct BarView: View {
    let geometry: Core.BarGeometry
    let fill: Color
    let height: CGFloat

    public init(geometry: Core.BarGeometry, fill: Color, height: CGFloat) {
        self.geometry = geometry
        self.fill = fill
        self.height = height
    }

    public var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color("BarTrack"))
                    .frame(height: height)
                Capsule()
                    .fill(fill)
                    .frame(width: max(0, width * geometry.fill), height: height)
                if let marker = geometry.marker {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color("PrimaryText"))
                        .frame(width: 3, height: proxy.size.height)
                        .position(x: width * marker, y: proxy.size.height / 2)
                }
            }
        }
        .frame(height: height)
        .accessibilityHidden(true) // the parent card carries the label
    }
}
