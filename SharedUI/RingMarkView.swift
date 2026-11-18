// RingMarkView — the app's ring mark drawn in code (V8): track with
// green, amber and red arcs and a marker dot, matching the icon.

import SwiftUI

struct RingMarkView: View {

    var size: CGFloat = 96

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("BarTrack"), lineWidth: size * 0.16)
            Circle()
                .trim(from: 0, to: 0.18)
                .stroke(Color(.systemGreen), style: StrokeStyle(lineWidth: size * 0.16, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Circle()
                .trim(from: 0.20, to: 0.28)
                .stroke(Color(.systemOrange), style: StrokeStyle(lineWidth: size * 0.16, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Circle()
                .trim(from: 0.30, to: 0.36)
                .stroke(Color(.systemRed), style: StrokeStyle(lineWidth: size * 0.16, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Circle()
                .fill(Color("PrimaryText"))
                .frame(width: size * 0.09, height: size * 0.09)
                .offset(x: -size * 0.29, y: 0)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}
