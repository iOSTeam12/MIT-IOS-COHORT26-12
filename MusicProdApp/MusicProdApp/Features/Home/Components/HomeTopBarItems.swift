import SwiftUI

/// The Musician Coins pill (Figma "Points Pill"): cyan outline, star
/// symbol and the coin count. Not a button: Figma gives it no action.
/// Note: the star follows Figma for now, although our rules say "no
/// stars". The team will decide later.
struct CoinsPill: View {
    let coins: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "star.circle")
                .font(.system(size: 18))
                .foregroundStyle(AppColor.accentCyan)
            Text("\(coins)")
                .appFont(.coins)
                .foregroundStyle(AppColor.textPrimary)
        }
        .padding(.horizontal, 10)
        .frame(height: 32)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(AppColor.accentCyan, lineWidth: 1)
        )
        // Figma drop shadow: offset 0/4, blur 10 (SwiftUI radius = blur / 2).
        .shadow(color: AppColor.dropShadow, radius: 5, y: 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Musician Coins: \(coins)")
    }
}

/// The profile button (Figma "Profile Button"): a 32 pt square with a
/// person symbol. The tappable area is 44 pt (6 pt invisible margin on
/// every side), as CLAUDE.md asks for 32 pt buttons.
struct ProfileButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "person")
                .font(.system(size: 16))
                .foregroundStyle(AppColor.textPrimary)
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(AppColor.surface.opacity(0.9))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(AppColor.stroke, lineWidth: 1)
                )
                .shadow(color: AppColor.dropShadow, radius: 5, y: 4)
                .padding(6)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Profile")
    }
}

/// "BPM 060" in the top-left corner. Not tappable (for now).
struct BPMReadout: View {
    let bpm: Int
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Text("BPM")
                .appFont(.caption)
                .foregroundStyle(AppColor.textSecondary)
            Text(text)
                .appFont(.bigNumber)
                .foregroundStyle(AppColor.accentCyan)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(bpm) BPM")
    }
}
