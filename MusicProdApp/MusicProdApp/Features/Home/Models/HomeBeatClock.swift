import Foundation

/// Home's silent count of 4 beats per bar (Figma: one bar = 4 s at 60 BPM).
/// Pure maths: give it the seconds passed since the bar started, and it says
/// which beat light is lit and how many whole bars are done. It holds no
/// timer and no start time, so it can't drift and can be unit-tested later.
///
/// Visual only: Home plays no sound, so this is not the audio clock.
struct HomeBeatClock {
    let bpm: Double
    let beatsPerBar = 4

    /// Extra time allowed when counting beats. Subtracting two dates can
    /// give 3.9999 s instead of 4.0 s; without this the light would stay
    /// one beat behind.
    static let tolerance: TimeInterval = 0.001

    /// One beat in seconds (1 s at 60 BPM).
    var beatDuration: TimeInterval { BeatTiming.beatDuration(bpm: bpm) }

    /// Whole beats since the start. Times before the start count as 0.
    func beatsPassed(after elapsed: TimeInterval) -> Int {
        max(0, Int(((elapsed + Self.tolerance) / beatDuration).rounded(.down)))
    }

    /// The lit beat light, 1 to 4. 0–0.999 s → 1, 1 s → 2, … 4 s → 1 again.
    func light(after elapsed: TimeInterval) -> Int {
        BeatTiming.beatInBar(beatsPassed(after: elapsed), beatsPerBar: beatsPerBar) + 1
    }

    /// Whole bars done. Goes up by one at every beat 1 (4 s, 8 s, …).
    func barsPassed(after elapsed: TimeInterval) -> Int {
        beatsPassed(after: elapsed) / beatsPerBar
    }
}
