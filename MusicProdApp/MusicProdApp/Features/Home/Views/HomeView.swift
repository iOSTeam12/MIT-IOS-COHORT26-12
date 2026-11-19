import SwiftUI

/// Home (Figma "Home · first time" 1–3): the bottom of the navigation
/// stack. Shows one section (Learn, Challenge or Sandbox) in the middle;
/// swiping left or right changes it, looping round.
///
/// Layout: left and right follow the real safe area (about 60 pt, as in
/// Figma), which keeps everything clear of the Dynamic Island. Top and
/// bottom use Figma's distances from the screen edge, because landscape
/// has no status bar and these corners hold no buttons near the home
/// indicator.
struct HomeView: View {
    @Environment(AppRouter.self) private var router
    @State private var viewModel = HomeViewModel()

    var body: some View {
        GeometryReader { proxy in
            let screenWidth = proxy.size.width
                + proxy.safeAreaInsets.leading + proxy.safeAreaInsets.trailing

            ZStack {
                middle(screenWidth: screenWidth, safeWidth: proxy.size.width)
                topBar
                    .frame(maxHeight: .infinity, alignment: .top)
                bottomBar
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
        .ignoresSafeArea(edges: .vertical)
        .background(AppColor.background.ignoresSafeArea())
        // Swipe anywhere on Home (except starting on a button).
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { drag in
                    withAnimation(.easeInOut(duration: 0.6)) { // Figma: 0.6 s ease in-out
                        viewModel.handleSwipe(horizontal: drag.translation.width,
                                              vertical: drag.translation.height)
                    }
                }
        )
    }

    /// The big word, its neighbours and the section's details.
    private func middle(screenWidth: CGFloat, safeWidth: CGFloat) -> some View {
        VStack(spacing: 20) {
            HomeWordCarousel(
                position: viewModel.position,
                // About a third of the screen width out from the middle.
                neighbourDistance: screenWidth / 3,
                halfSafeWidth: safeWidth / 2,
                onNext: { withAnimation(.easeInOut(duration: 0.6)) { viewModel.showNext() } },
                onPrevious: { withAnimation(.easeInOut(duration: 0.6)) { viewModel.showPrevious() } }
            )

            // A ZStack so the old and new details overlap while they
            // crossfade, instead of stacking below each other.
            ZStack {
                let section = viewModel.current
                HomeSectionDetails(
                    section: section,
                    progressValue: viewModel.progressValueText(for: section),
                    onPrimary: { open(section.primaryRoute) },
                    onLink: { open(section.linkRoute) }
                )
                .id(section)
                .transition(.opacity)
            }
        }
        // Figma puts this block 6–7 pt below the exact centre.
        .padding(.top, 13)
    }

    private var topBar: some View {
        HStack {
            BPMReadout(bpm: viewModel.bpm, text: viewModel.bpmText)
            Spacer()
            // 12 pt gap in Figma = 6 pt spacing + the profile button's
            // invisible 6 pt tap margin.
            HStack(spacing: 6) {
                CoinsPill(coins: viewModel.musicianCoins)
                ProfileButton { router.open(.profile) }
            }
            // Let the invisible tap margin stick out, so the visible
            // button lines up with the safe-area edge as in Figma.
            .padding(.trailing, -6)
        }
        // Figma: buttons 18 pt from the top (minus the 6 pt tap margin).
        .padding(.top, 12)
    }

    private var bottomBar: some View {
        HStack {
            BeatLights()
            Spacer()
            SwipeHint()
        }
        // Figma: 28 pt from the bottom edge.
        .padding(.bottom, 28)
    }

    /// Opens a screen, or does nothing if it isn't built yet (`nil`).
    private func open(_ route: AppRoute?) {
        if let route { router.open(route) }
    }
}

#Preview(traits: .landscapeLeft) {
    AppFont.registerFonts()
    return HomeView()
        .environment(AppRouter())
        .preferredColorScheme(.dark)
}
