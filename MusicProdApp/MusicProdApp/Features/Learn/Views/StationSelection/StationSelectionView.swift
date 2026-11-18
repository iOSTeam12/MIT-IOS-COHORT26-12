import SwiftUI

/// Learn: Station Selection (Figma 1364:20822). For now only the header;
/// the stations come in a later block.
struct StationSelectionView: View {
    var body: some View {
        ScreenHeader(title: "Learn")
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(AppColor.background)
    }
}

#Preview(traits: .landscapeLeft) {
    AppFont.registerFonts()
    return StationSelectionView()
        .environment(AppRouter())
}
