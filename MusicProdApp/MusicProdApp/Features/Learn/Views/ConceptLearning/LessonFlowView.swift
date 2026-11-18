import SwiftUI

/// Opens the lesson "Tempo and Beats" as a screen on the navigation stack.
/// It creates the lesson's view models, so every time the lesson is opened
/// it starts fresh at the first step. When the learner leaves or finishes,
/// it stops the drums and closes itself (back to whatever opened it).
struct LessonFlowView: View {
    let beatPlayer: any BeatPlaying
    @Environment(AppRouter.self) private var router

    @State private var lessonViewModel = LessonViewModel(content: .lesson1_1)
    @State private var introViewModel: IntroViewModel
    @State private var learnViewModel: LearnViewModel
    @State private var doOneViewModel: DoOneViewModel
    @State private var doTwoViewModel: DoTwoViewModel
    @State private var doThreeViewModel: DoThreeViewModel
    @State private var finaleViewModel: FinaleViewModel

    init(beatPlayer: any BeatPlaying) {
        self.beatPlayer = beatPlayer
        _introViewModel = State(initialValue: IntroViewModel(beatPlayer: beatPlayer))
        _learnViewModel = State(initialValue: LearnViewModel(beatPlayer: beatPlayer))
        _doOneViewModel = State(initialValue: DoOneViewModel(beatPlayer: beatPlayer))
        _doTwoViewModel = State(initialValue: DoTwoViewModel(beatPlayer: beatPlayer))
        _doThreeViewModel = State(initialValue: DoThreeViewModel(beatPlayer: beatPlayer))
        _finaleViewModel = State(initialValue: FinaleViewModel(beatPlayer: beatPlayer))
    }

    var body: some View {
        LessonView(viewModel: lessonViewModel, introViewModel: introViewModel, learnViewModel: learnViewModel,
                   doOneViewModel: doOneViewModel, doTwoViewModel: doTwoViewModel,
                   doThreeViewModel: doThreeViewModel, finaleViewModel: finaleViewModel)
            // "Leave" in the alert, or either button on the complete pop-up.
            .onChange(of: lessonViewModel.hasExited) { _, hasExited in
                if hasExited {
                    beatPlayer.stop()
                    router.back()
                }
            }
            // Safety net: however the lesson closes, the drums stop.
            .onDisappear {
                beatPlayer.stop()
            }
    }
}

#Preview(traits: .landscapeLeft) {
    LessonFlowView(beatPlayer: BeatPlayer())
        .environment(AppRouter())
}
