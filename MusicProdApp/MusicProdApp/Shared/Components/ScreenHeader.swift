import SwiftUI

/// The top-left header from Figma (Station Selection, Profile): a back
/// button and the screen title in Pulse12. Back pops the navigation stack.
///
/// Place it inside the safe area (the default), so it stays clear of the
/// Dynamic Island on every iPhone. The numbers below are Figma's margins
/// *inside* the safe area.
struct ScreenHeader: View {
    let title: String
    @Environment(AppRouter.self) private var router

    var body: some View {
        // 12 pt between button and title in Figma, minus the 6 pt of
        // invisible tap padding on the button's right side.
        HStack(spacing: 6) {
            BackButton(action: router.back)
            Text(title)
                .appFont(.title)
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(1)
        }
        // Figma puts the visible button 14 pt from the top. The button has
        // 6 pt of invisible tap padding, so 8 + 6 = 14.
        .padding(.top, 8)
    }
}

/// Figma "Icon Button · Back": a 32 pt Liquid Glass square with a
/// chevron. 6 pt of invisible padding on every side makes the tap area
/// 44 pt, Apple's minimum.
struct BackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColor.textPrimary)
                .frame(width: 32, height: 32)
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 6))
                .padding(6)
                // Makes the transparent padding tappable too.
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Back")
    }
}

#Preview(traits: .landscapeLeft) {
    AppFont.registerFonts()
    return ScreenHeader(title: "Learn")
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppColor.background)
        .environment(AppRouter())
}
