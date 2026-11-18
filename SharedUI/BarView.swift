// BarView — the design's bar: rounded track, solid fill, optional 3 pt
// marker across the full height. Bars grow from zero on first
// appearance (08 plan §6), once, unless Reduce Motion is on.

import SwiftUI
import UIKit
import Core

public struct BarView: View {

    let geometry: Core.BarGeometry
    let fill: Color
    let height: CGFloat

    @State private var growth: CGFloat = 0

    public init(geometry: Core.BarGeometry, fill: Color, height: CGFloat) {
        self.geometry = geometry
        self.fill = fill
        self.height = height
    }

    public var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let fraction = min(max(geometry.fill, 0), 1) * Double(growth)
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color("BarTrack"))
                    .frame(height: height)
                Capsule()
                    .fill(fill)
                    .frame(width: max(0, width * fraction), height: height)
                if let marker = geometry.marker {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color("PrimaryText"))
                        .frame(width: 3, height: proxy.size.height)
                        .position(x: width * marker, y: proxy.size.height / 2)
                }
            }
        }
        .frame(height: height)
        .onAppear {
            let reduce = UIAccessibility.isReduceMotionEnabled
            withAnimation(.easeOut(duration: reduce ? 0.01 : 0.4)) {
                growth = 1
            }
        }
        .accessibilityHidden(true) // the parent card carries the label
    }
}
