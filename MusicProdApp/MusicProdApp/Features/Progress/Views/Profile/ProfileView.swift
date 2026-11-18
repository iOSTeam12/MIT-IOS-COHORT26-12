import SwiftUI

/// Profile (Figma 1364:37665): for now only the header, as in Figma.
struct ProfileView: View {
    var body: some View {
        ScreenHeader(title: "Profile")
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(AppColor.background)
    }
}

#Preview(traits: .landscapeLeft) {
    AppFont.registerFonts()
    return ProfileView()
        .environment(AppRouter())
}
