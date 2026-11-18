import SwiftUI

@main struct MyApp: App {
    @Environment(\.scenePhase) private var scenePhase
    // Services are created once here and passed down; views never create them.
    @State private var beatPlayer = BeatPlayer()

    init() {
        // Make the Pulse12 font available before any screen draws text.
        AppFont.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(beatPlayer: beatPlayer)
        }
        .onChange(of: scenePhase) { _, phase in
            // No background audio: stop the drums when the app leaves the screen.
            if phase == .background {
                beatPlayer.stop()
            }
        }
    }
}
