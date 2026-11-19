import Foundation
import Observation

/// Runs the Home screen: which section is in the middle, the beat lights,
/// the auto-rotation, and the numbers Home shows.
///
/// Sections are counted with `position`, a number that keeps going up
/// (swipe left) or down (swipe right) instead of wrapping round. The
/// section is `position` modulo 3. This lets the word carousel give every
/// word on screen its own steady identity, so a word leaving one side and
/// coming back on the other fades out and in (as in Figma) instead of
/// flying across the screen.
///
/// Auto-rotation (Figma): the lights count 1-2-3-4 once per second and the
/// section moves on at every beat 1. Everything is worked out from one
/// start time (`barStart`), so it cannot drift. Rules:
/// - Any drag, swipe or tap on Home = the user took over: the section never
///   moves by itself again. The lights keep counting as a silent metronome.
/// - Off from the start with Reduce Motion (the lights still count).
/// - The lights freeze while paused (finger dragging, another screen on
///   top, app in the background) and restart at light 1 afterwards.
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

    // MARK: Beat lights and auto-rotation

    /// Why the count is frozen. Several can be true at once, e.g. another
    /// screen is on top *and* the app is in the background.
    enum PauseReason {
        case dragging
        case otherScreen
        case appInBackground
    }

    private let clock = HomeBeatClock(bpm: 60)
    /// When the current bar's light 1 came on.
    private(set) var barStart = Date.now
    /// The section in the middle at `barStart`.
    private var positionAtBarStart = 0
    private var pauseReasons: Set<PauseReason> = []
    /// The light shown while paused.
    private var frozenLight = 1
    /// True after the first drag, swipe or tap on Home. Never goes back.
    private(set) var userTookOver = false
    private var reduceMotion = false

    /// Seconds per beat, for the screen's once-per-beat redraw.
    var beatDuration: TimeInterval { clock.beatDuration }

    /// Whether the section still moves by itself.
    var autoRotates: Bool { !userTookOver && !reduceMotion }

    /// The lit beat light (1–4) at a moment.
    func activeLight(at date: Date) -> Int {
        pauseReasons.isEmpty ? clock.light(after: date.timeIntervalSince(barStart)) : frozenLight
    }

    /// Called on every beat. Moves the section to "start section + bars
    /// done" (calculated, not counted up), if auto-rotation is on.
    func advanceIfDue(at date: Date) {
        guard autoRotates, pauseReasons.isEmpty else { return }
        let target = positionAtBarStart + clock.barsPassed(after: date.timeIntervalSince(barStart))
        if target != position { position = target }
    }

    /// Starts a new bar at light 1 from this moment.
    func restartBar(at date: Date) {
        barStart = date
        positionAtBarStart = position
        frozenLight = 1
    }

    /// A tap anywhere on Home (background or button).
    func takeOver() { userTookOver = true }

    /// A finger started dragging: that counts as taking over, even if the
    /// drag doesn't change section. The lights freeze until it lifts.
    func dragStarted(at date: Date) {
        takeOver()
        pause(.dragging, at: date)
    }

    func dragEnded(at date: Date) { resume(.dragging, at: date) }

    /// Freezes the lights on the beat they show now.
    func pause(_ reason: PauseReason, at date: Date) {
        if pauseReasons.isEmpty { frozenLight = activeLight(at: date) }
        pauseReasons.insert(reason)
    }

    /// When the last reason is gone, the count restarts at light 1.
    func resume(_ reason: PauseReason, at date: Date) {
        guard pauseReasons.remove(reason) != nil, pauseReasons.isEmpty else { return }
        restartBar(at: date)
    }

    /// Follows the system Reduce Motion setting, live.
    func setReduceMotion(_ isOn: Bool, at date: Date) {
        guard isOn != reduceMotion else { return }
        reduceMotion = isOn
        // Fresh bar, so turning it off later can't make the section jump.
        restartBar(at: date)
    }

    /// The section in the middle of the screen.
    var current: HomeSection { Self.section(at: position) }

    /// The section for any slot, looping round in both directions.
    static func section(at position: Int) -> HomeSection {
        let all = HomeSection.allCases
        let index = ((position % all.count) + all.count) % all.count
        return all[index]
    }

    /// Swipe left (or VoiceOver swipe up): the section on the right moves
    /// to the middle. The user took over; the bar restarts at light 1.
    func showNext() {
        position += 1
        userMovedSection()
    }

    /// Swipe right (or VoiceOver swipe down): the section on the left moves
    /// to the middle.
    func showPrevious() {
        position -= 1
        userMovedSection()
    }

    private func userMovedSection() {
        takeOver()
        restartBar(at: .now)
    }

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
