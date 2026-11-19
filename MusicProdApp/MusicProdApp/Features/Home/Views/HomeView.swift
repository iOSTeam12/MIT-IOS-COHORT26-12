import SwiftUI

/// Home (Figma "Home · first time" 1–3): the bottom of the navigation
/// stack. Shows one section (Learn, Challenge or Sandbox) in the middle;
/// swiping left or right changes it, looping round. Until the user touches
/// Home, the section moves on by itself every bar (see `HomeViewModel`).
///
/// Layout: left and right follow the real safe area (about 60 pt, as in
/// Figma), which keeps everything clear of the Dynamic Island. Top and
/// bottom use Figma's distances from the screen edge, because landscape
/// has no status bar and these corners hold no buttons near the home
/// indicator.
struct HomeView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel = HomeViewModel()
    /// True while a finger drags across Home. Resets by itself, even if
    /// iOS cancels the drag.
    @GestureState private var isDragging = false

    /// Figma: sections slide in 0.6 s, ease in-out.
    private static let slide = Animation.easeInOut(duration: 0.6)

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
                .updating($isDragging) { _, dragging, _ in dragging = true }
                .onEnded { drag in
                    withAnimation(Self.slide) {
                        viewModel.handleSwipe(horizontal: drag.translation.width,
                                              vertical: drag.translation.height)
                    }
                }
        )
        // A tap on the empty background also means the user took over.
        // (Taps on buttons go to the buttons; they take over in `open`.)
        .onTapGesture { viewModel.takeOver() }
        .onAppear { viewModel.restartBar(at: .now) }
        .onChange(of: isDragging) { _, dragging in
            if dragging { viewModel.dragStarted(at: .now) } else { viewModel.dragEnded(at: .now) }
        }
        // Another screen on top of Home: freeze; back on Home: restart at 1.
        .onChange(of: router.path.isEmpty) { _, homeIsOnTop in
            if homeIsOnTop { viewModel.resume(.otherScreen, at: .now) } else { viewModel.pause(.otherScreen, at: .now) }
        }
        // App in the background (or interrupted): same as another screen.
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { viewModel.resume(.appInBackground, at: .now) } else { viewModel.pause(.appInBackground, at: .now) }
        }
        .onChange(of: reduceMotion, initial: true) { _, isOn in
            viewModel.setReduceMotion(isOn, at: .now)
        }
    }

    /// The big word, its neighbours and the section's details.
    private func middle(screenWidth: CGFloat, safeWidth: CGFloat) -> some View {
        VStack(spacing: 20) {
            HomeWordCarousel(
                position: viewModel.position,
                // About a third of the screen width out from the middle.
                neighbourDistance: screenWidth / 3,
                halfSafeWidth: safeWidth / 2,
                onNext: { withAnimation(Self.slide) { viewModel.showNext() } },
                onPrevious: { withAnimation(Self.slide) { viewModel.showPrevious() } }
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
                ProfileButton { open(.profile) }
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
            beatLights
            Spacer()
            SwipeHint()
        }
        // Figma: 28 pt from the bottom edge.
        .padding(.bottom, 28)
    }

    /// The beat lights, redrawn once per beat (TimelineView: visual only,
    /// no sound, so it doesn't need the audio clock). Each redraw also lets
    /// the section move on when a new bar starts.
    private var beatLights: some View {
        TimelineView(.periodic(from: viewModel.barStart, by: viewModel.beatDuration)) { context in
            BeatLights(activeBeat: viewModel.activeLight(at: context.date))
                .onChange(of: context.date) { _, date in
                    withAnimation(Self.slide) { viewModel.advanceIfDue(at: date) }
                }
        }
    }

    /// Opens a screen, or does nothing if it isn't built yet (`nil`).
    /// Any button tap counts as the user taking over.
    private func open(_ route: AppRoute?) {
        viewModel.takeOver()
        if let route { router.open(route) }
    }
}

#Preview(traits: .landscapeLeft) {
    AppFont.registerFonts()
    return HomeView()
        .environment(AppRouter())
        .preferredColorScheme(.dark)
}
