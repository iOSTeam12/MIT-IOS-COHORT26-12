import SwiftUI

/// Sandbox: for now only the header; the content comes in a later block.
struct SandboxHomeView: View {
    var body: some View {
        ScreenHeader(title: "Sandbox")
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(AppColor.background)
    }
}

#Preview(traits: .landscapeLeft) {
    AppFont.registerFonts()
    return SandboxHomeView()
        .environment(AppRouter())
}
