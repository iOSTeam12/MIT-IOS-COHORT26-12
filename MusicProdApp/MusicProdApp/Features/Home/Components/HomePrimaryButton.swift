import SwiftUI

/// Home's call-to-action button ("Start Drums", "Start Challenge",
/// "Create Beat"), exactly as in Figma: flat cyan, corner radius 6,
/// 220 × 48 pt, black SF Mono Bold 15 label. Home only: the lesson screens
/// keep the Liquid Glass `PrimaryButton`.
///
/// With larger text sizes the button grows wider instead of cutting the
/// label off. Figma shows no pressed state, so it dims slightly while held.
struct HomePrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .appFont(.button)
                .foregroundStyle(AppColor.background)
                .lineLimit(1)
                .fixedSize()
                .padding(.horizontal, 28)
                .frame(minWidth: 220, minHeight: 48)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(AppColor.accentCyan)
                )
                .contentShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(DimWhenPressed())
    }
}

/// Shows the button at 70% while a finger is on it.
private struct DimWhenPressed: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

#Preview(traits: .landscapeLeft) {
    AppFont.registerFonts()
    return VStack(spacing: 16) {
        HomePrimaryButton(title: "Start Drums") {}
        HomePrimaryButton(title: "Start Challenge") {}
        HomePrimaryButton(title: "Create Beat") {}
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(AppColor.background)
}
