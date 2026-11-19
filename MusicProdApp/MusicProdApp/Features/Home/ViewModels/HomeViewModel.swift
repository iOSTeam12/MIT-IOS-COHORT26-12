import Observation

/// Runs the Home screen: which section is in the middle, and the numbers
/// Home shows.
///
/// Sections are counted with `position`, a number that keeps going up
/// (swipe left) or down (swipe right) instead of wrapping round. The
/// section is `position` modulo 3. This lets the word carousel give every
/// word on screen its own steady identity, so a word leaving one side and
/// coming back on the other fades out and in (as in Figma) instead of
/// flying across the screen.
@Observable
final class HomeViewModel {
    /// Which slot is in the middle. 0 = Learn, 1 = Challenge, 2 = Sandbox,
    /// 3 = Learn again, -1 = Sandbox, and so on.
    private(set) var position = 0

    // Static values until real progress data exists (no persistence yet).
    /// Home's tempo. Visual only: Home plays no sound.
    let bpm = 60
    let musicianCoins = 0
    let completedDrumLessons = 0
    let completedDrumChallenges = 0
    let projectCount = 0

    /// The section in the middle of the screen.
    var current: HomeSection { Self.section(at: position) }

    /// The section for any slot, looping round in both directions.
    static func section(at position: Int) -> HomeSection {
        let all = HomeSection.allCases
        let index = ((position % all.count) + all.count) % all.count
        return all[index]
    }

    /// Swipe left: the section on the right moves to the middle.
    func showNext() { position += 1 }

    /// Swipe right: the section on the left moves to the middle.
    func showPrevious() { position -= 1 }

    /// How far (in points) a finger must move sideways to count as a swipe.
    static let minimumSwipeDistance = 40.0

    /// Called when a finger lifts after dragging across Home, with how far
    /// it moved. A mostly sideways drag of at least `minimumSwipeDistance`
    /// changes section: left shows the next, right the previous.
    func handleSwipe(horizontal: Double, vertical: Double) {
        guard abs(horizontal) >= Self.minimumSwipeDistance,
              abs(horizontal) > abs(vertical) else { return }
        if horizontal < 0 { showNext() } else { showPrevious() }
    }

    /// The BPM readout, always three digits: "060".
    var bpmText: String { Self.threeDigits(bpm) }

    /// The number at the end of a section's progress row: "0/4" or "00".
    func progressValueText(for section: HomeSection) -> String {
        switch section.progressStyle {
        case .steps(_, let total):
            let done = section == .learn ? completedDrumLessons : completedDrumChallenges
            return "\(done)/\(total)"
        case .count:
            return projectCount < 10 ? "0\(projectCount)" : "\(projectCount)"
        }
    }

    private static func threeDigits(_ value: Int) -> String {
        let text = String(value)
        return String(repeating: "0", count: max(0, 3 - text.count)) + text
    }
}
