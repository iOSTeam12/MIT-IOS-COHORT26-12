/// The three sections Home rotates through (Figma "Home · first time"
/// 1–3), in their on-screen order. The section after Sandbox is Learn
/// again, so the order loops.
///
/// Holds only fixed content (text and where each button goes). Numbers
/// that will come from real data later (progress, coins) live in
/// `HomeViewModel`.
enum HomeSection: CaseIterable {
    case learn
    case challenge
    case sandbox

    /// What the progress row under the subtitle shows.
    enum ProgressStyle {
        /// A label, one dash per step and a count, e.g. "DRUMS ▬▬▬▬ 0/4".
        case steps(label: String, total: Int)
        /// A label and a two-digit number, e.g. "PROJECTS 00".
        case count(label: String)
    }

    /// The big word in the middle, e.g. "LEARN".
    var title: String {
        switch self {
        case .learn: "LEARN"
        case .challenge: "CHALLENGE"
        case .sandbox: "SANDBOX"
        }
    }

    /// The line under the big word.
    var subtitle: String {
        switch self {
        case .learn: "Lessons, beat by beat"
        case .challenge: "Test your ears"
        case .sandbox: "Make your own track"
        }
    }

    var progressStyle: ProgressStyle {
        switch self {
        case .learn: .steps(label: "DRUMS", total: 4)
        case .challenge: .steps(label: "DRUMS", total: 3)
        case .sandbox: .count(label: "PROJECTS")
        }
    }

    /// Text on the cyan call-to-action button.
    var primaryTitle: String {
        switch self {
        case .learn: "Start Drums"
        case .challenge: "Start Challenge"
        case .sandbox: "Create Beat"
        }
    }

    /// Where the call-to-action button goes. `nil` means that screen
    /// doesn't exist yet, so the button does nothing for now.
    var primaryRoute: AppRoute? {
        switch self {
        // Figma opens the lesson preview first; until it exists this
        // opens the lesson "Tempo and Beats" directly.
        case .learn: .lesson
        // Figma: "Challenge · Clip 1 · Ready" (not built yet).
        case .challenge: nil
        // Figma: "Create dialog" overlay (not built yet).
        case .sandbox: nil
        }
    }

    /// Text on the grey link next to the button.
    var linkTitle: String {
        switch self {
        case .learn: "ALL STATIONS"
        case .challenge: "ALL CHALLENGES"
        case .sandbox: "MY PROJECTS"
        }
    }

    /// Where the link goes.
    var linkRoute: AppRoute {
        switch self {
        case .learn: .learn         // Figma: Station Selection
        case .challenge: .challenge // Figma: Challenge hub
        case .sandbox: .sandbox     // Figma: Sandbox (empty)
        }
    }
}
