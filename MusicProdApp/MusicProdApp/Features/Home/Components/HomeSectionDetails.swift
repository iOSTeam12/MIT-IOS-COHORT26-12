import SwiftUI

/// Everything under the big word for one section (Figma "Details · …"):
/// the progress row, the cyan call-to-action button and the grey link.
struct HomeSectionDetails: View {
    let section: HomeSection
    /// The number at the end of the progress row, e.g. "0/4" or "00".
    let progressValue: String
    let onPrimary: () -> Void
    let onLink: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            progressRow

            HStack(spacing: 24) {
                PrimaryButton(title: section.primaryTitle, action: onPrimary)

                Button(action: onLink) {
                    HStack(spacing: 6) {
                        Text(section.linkTitle)
                        Image(systemName: "chevron.right")
                    }
                    .appFont(.secondaryButton)
                    .foregroundStyle(AppColor.textSecondary)
                    .padding(.horizontal, 8)
                    .frame(height: 48)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    /// "DRUMS ▬▬▬▬ 0/4" or "PROJECTS 00".
    private var progressRow: some View {
        HStack(spacing: 10) {
            switch section.progressStyle {
            case .steps(let label, let total):
                Text(label)
                    .appFont(.label)
                    .foregroundStyle(AppColor.textSecondary)
                // Figma only shows the empty state. The colour of a
                // finished step is not designed yet, so all dashes are grey.
                HStack(spacing: 4) {
                    ForEach(0..<total, id: \.self) { _ in
                        Rectangle()
                            .fill(AppColor.progressEmptyStroke)
                            .frame(width: 20, height: 4)
                    }
                }
            case .count(let label):
                Text(label)
                    .appFont(.label)
                    .foregroundStyle(AppColor.textSecondary)
            }

            Text(progressValue)
                .appFont(.smallNumber)
                .foregroundStyle(AppColor.accentCyan)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityProgress)
    }

    private var accessibilityProgress: String {
        switch section.progressStyle {
        case .steps(let label, _): "\(label.capitalized) progress: \(progressValue.replacingOccurrences(of: "/", with: " of "))"
        case .count(let label): "\(label.capitalized): \(Int(progressValue) ?? 0)"
        }
    }
}
