import SwiftUI

/// Root view: one NavigationStack with Home at the bottom. Every other
/// screen is opened by pushing an `AppRoute` onto the router's path, and
/// Back pops it. Debug builds also show an "Audio test" button (see DebugFlags).
///
/// TODO: CLAUDE.md says root navigation lives in App/. Decide whether to
/// move this file to App/RootView.swift.
struct ContentView: View {
    let beatPlayer: any BeatPlaying
    @State private var router = AppRouter()
    @State private var showAudioTest = false

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                // Our screens draw their own header, so hide the system bar.
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: AppRoute.self) { route in
                    destination(for: route)
                        .toolbar(.hidden, for: .navigationBar)
                }
        }
        // Every screen can reach the router to open screens or go back.
        .environment(router)
        // Bottom centre, clear of Home's beat lights (bottom left) and
        // SWIPE (bottom right) in Figma.
        .overlay(alignment: .bottom) {
            if DebugFlags.showAudioDebug {
                GlassTextButton(title: "Audio test") { showAudioTest = true }
            }
        }
        .fullScreenCover(isPresented: $showAudioTest) {
            AudioDebugView(beatPlayer: beatPlayer)
        }
        // The app is dark only.
        .preferredColorScheme(.dark)
        // Text can grow up to the largest standard size, but not to the
        // Accessibility sizes: at those, Home's 54 pt hero text would no
        // longer fit a 393 pt-tall landscape screen.
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }

    /// The screen for each route.
    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .learn: StationSelectionView()
        case .challenge: ChallengeDashboardView()
        case .sandbox: SandboxHomeView()
        case .profile: ProfileView()
        case .lesson: LessonFlowView(beatPlayer: beatPlayer)
        }
    }
}

#Preview(traits: .landscapeLeft) {
    AppFont.registerFonts()
    return ContentView(beatPlayer: BeatPlayer())
}
