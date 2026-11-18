import SwiftUI

/// Challenge: for now only the header; the content comes in a later block.
struct ChallengeDashboardView: View {
    var body: some View {
        ScreenHeader(title: "Challenge")
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(AppColor.background)
    }
}

#Preview(traits: .landscapeLeft) {
    AppFont.registerFonts()
    return ChallengeDashboardView()
        .environment(AppRouter())
}
