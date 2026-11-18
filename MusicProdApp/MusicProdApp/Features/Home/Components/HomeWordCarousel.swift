import SwiftUI

/// The big section word in the middle of Home with its subtitle, and the
/// neighbouring sections faded on either side (Figma "Word A / Word B").
///
/// Five words are drawn: the middle one, one each side (30% opacity) and
/// one more each side, invisible and further out. When `position` changes
/// inside an animation, every word slides one place; the invisible outer
/// words are the ones that fade in, so a word wrapping round never flies
/// across the screen.
struct HomeWordCarousel: View {
    /// The middle slot (see `HomeViewModel.position`).
    let position: Int
    /// How far a faded neighbour's centre sits from the middle.
    let neighbourDistance: CGFloat
    /// Half the width of the safe area. Neighbours are pulled in so they
    /// never cross it (keeps them clear of the Dynamic Island).
    let halfSafeWidth: CGFloat
    let onNext: () -> Void
    let onPrevious: () -> Void

    /// Width of each word at full size, measured on screen. Needed to keep
    /// long words like CHALLENGE inside the safe area.
    @State private var wordWidths: [HomeSection: CGFloat] = [:]

    // The two Figma sizes (hero 54, neighbour 32), scaled for Dynamic Type
    // exactly as `.appFont` scales them. The neighbour is the hero word
    // shrunk to this ratio, so the size change can animate smoothly.
    @ScaledMetric private var heroSize: CGFloat
    @ScaledMetric private var neighbourSize: CGFloat

    init(position: Int, neighbourDistance: CGFloat, halfSafeWidth: CGFloat,
         onNext: @escaping () -> Void, onPrevious: @escaping () -> Void) {
        self.position = position
        self.neighbourDistance = neighbourDistance
        self.halfSafeWidth = halfSafeWidth
        self.onNext = onNext
        self.onPrevious = onPrevious
        _heroSize = ScaledMetric(wrappedValue: AppFont.Role.hero.size,
                                 relativeTo: AppFont.Role.hero.scalesLike)
        _neighbourSize = ScaledMetric(wrappedValue: AppFont.Role.heroSecondary.size,
                                      relativeTo: AppFont.Role.heroSecondary.scalesLike)
    }

    private var neighbourScale: CGFloat { neighbourSize / heroSize }

    var body: some View {
        let current = HomeViewModel.section(at: position)

        ZStack(alignment: .top) {
            ForEach(Array((position - 2)...(position + 2)), id: \.self) { slot in
                word(for: HomeViewModel.section(at: slot), distance: slot - position)
            }
        }
        .frame(maxWidth: .infinity)
        // VoiceOver: one element; swipe up/down to change section.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(current.title), \(current.subtitle)")
        .accessibilityAddTraits(.isHeader)
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: onNext()
            case .decrement: onPrevious()
            @unknown default: break
            }
        }
    }

    /// One word with its subtitle. `distance` is how many places it is from
    /// the middle: 0 = middle, -1/1 = faded neighbour, -2/2 = hidden.
    private func word(for section: HomeSection, distance: Int) -> some View {
        let isMiddle = distance == 0

        return VStack(spacing: 12) {
            Text(section.title)
                .appFont(.hero)
                .foregroundStyle(AppColor.accentCyan)
                .fixedSize()
                .onGeometryChange(for: CGFloat.self) { $0.size.width } action: {
                    wordWidths[section] = $0
                }
                // Shrink from the bottom: in Figma the faded words share
                // the big word's bottom edge.
                .scaleEffect(isMiddle ? 1 : neighbourScale, anchor: .bottom)

            Text(section.subtitle)
                .appFont(.subtitle)
                .foregroundStyle(AppColor.textSecondary)
                .fixedSize()
                .opacity(isMiddle ? 1 : 0)
        }
        .opacity(opacity(forDistance: distance))
        .offset(x: xOffset(for: section, distance: distance))
    }

    private func opacity(forDistance distance: Int) -> Double {
        switch abs(distance) {
        case 0: 1
        case 1: 0.3   // Figma: neighbours at 30%
        default: 0
        }
    }

    /// Horizontal position of a word's centre, relative to the middle.
    private func xOffset(for section: HomeSection, distance: Int) -> CGFloat {
        let side: CGFloat = distance < 0 ? -1 : 1
        switch abs(distance) {
        case 0:
            return 0
        case 1:
            // A third of the screen out, but pulled in if the shrunken
            // word would otherwise cross the safe-area edge.
            let halfWord = (wordWidths[section] ?? 0) * neighbourScale / 2
            return side * min(neighbourDistance, halfSafeWidth - halfWord)
        default:
            return side * neighbourDistance * 2
        }
    }
}
