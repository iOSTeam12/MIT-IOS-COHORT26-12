import SwiftUI

/// The four beat lights in the bottom-left corner. One light is bright,
/// the others are at 22% (Figma). For now beat 1 is always lit; block H3b
/// makes them follow the 60 BPM beat.
struct BeatLights: View {
    var activeBeat = 1

    var body: some View {
        HStack(spacing: 12) {
            ForEach(1...4, id: \.self) { beat in
                Text("\(beat)")
                    .appFont(.bigNumber)
                    .foregroundStyle(AppColor.accentCyan)
                    .opacity(beat == activeBeat ? 1 : 0.22)
            }
        }
        // Decorative: VoiceOver skips it.
        .accessibilityHidden(true)
    }
}

/// "‹ SWIPE ›" in the bottom-right corner.
/// TODO: Figma shows this on first launch only. Hide it after the first
/// launch once persistence (SwiftData vs UserDefaults) is decided.
struct SwipeHint: View {
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "chevron.left")
            Text("SWIPE")
            Image(systemName: "chevron.right")
        }
        .appFont(.caption)
        .foregroundStyle(AppColor.textSecondary)
        // VoiceOver users change section on the big word instead.
        .accessibilityHidden(true)
    }
}
