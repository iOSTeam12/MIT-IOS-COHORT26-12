import SwiftUI

/// Home: the bottom of the navigation stack.
/// TEMPORARY placeholder with plain buttons to open each screen. The real
/// Home (Figma "Home · first time") replaces it in a later block.
struct HomeView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                GlassTextButton(title: "Learn") { router.open(.learn) }
                GlassTextButton(title: "Challenge") { router.open(.challenge) }
                GlassTextButton(title: "Sandbox") { router.open(.sandbox) }
                GlassTextButton(title: "Profile") { router.open(.profile) }
            }
            GlassTextButton(title: "Tempo and Beats") { router.open(.lesson) }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background)
    }
}

#Preview(traits: .landscapeLeft) {
    HomeView()
        .environment(AppRouter())
}
