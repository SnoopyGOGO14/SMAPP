// DemoDetailScreen — the App detail screen fed from DemoData, for
// screenshot capture. Debug builds only.

#if DEBUG
import SwiftUI
import Core

struct DemoDetailScreen: View {

    @State private var period = 1

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Spacer()
                    Toggle("Monitor", isOn: .constant(true))
                        .toggleStyle(.switch)
                        .labelsHidden()
                }
                .padding(.trailing, 4)

                Picker("Period", selection: $period) {
                    Text("Today").tag(0)
                    Text("7 days").tag(1)
                    Text("Month").tag(2)
                }
                .pickerStyle(.segmented)
                .frame(height: 40)

                AppDetailCardView(configuration: DemoData.appDetail)

                Button {
                } label: {
                    Text("Target 1h a day · Change")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color("PrimaryText"))
                        .frame(maxWidth: .infinity, minHeight: 52)
                }
                .buttonStyle(.plain)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color("Divider"), lineWidth: 1))
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .background(Color("Ground"))
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("BarTrack"))
                        .frame(width: 32, height: 32)
                        .overlay(Text("Ti").font(.footnote.weight(.bold)).foregroundStyle(Color("SecondaryText")))
                    Text("TikTok")
                        .font(.headline)
                        .foregroundStyle(Color("PrimaryText"))
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color("PrimaryText"))
                }
                .accessibilityLabel("Back")
            }
        }
        #if DEBUG
        .onAppear { DemoMarker.mark("detail") }
        #endif
    }
}
#endif
