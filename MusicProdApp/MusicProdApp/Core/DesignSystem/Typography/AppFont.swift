import SwiftUI
import CoreText

/// The app's text styles, taken from the Figma page "HiFi 4 · Digital".
///
/// Only two fonts are allowed:
/// - Pulse12 (the digital font) for titles, headings and numbers.
/// - SF Mono (Apple's monospaced system font) for everything else, buttons included.
///
/// Views never pick a font or size themselves. They write `.appFont(.body)`,
/// `.appFont(.title)` and so on, and the size grows or shrinks with the
/// user's text-size setting (Dynamic Type).
enum AppFont {

    /// One case per job a piece of text does on screen.
    enum Role: CaseIterable {
        // Pulse12
        case hero            // Home: the selected word, e.g. "LEARN"
        case heroSecondary   // Home: the faded words either side
        case title           // Screen header, e.g. "Learn"; station name
        case heading         // Station names under the artwork
        case bigNumber       // BPM "060", beat lights, progress "0/4", Musician Coins
        case kicker          // Small label above a title, e.g. "DRUMS" in the lesson preview
        case smallNumber     // Home: progress count, e.g. "0/4", "00"
        case coins           // Home: the Musician Coins number in the pill
        // SF Mono
        case detailTitle     // Lesson preview title, e.g. "Tempo and Beats"
        case body            // Subtitles and descriptions
        case subtitle        // Home: line under the big word, e.g. "Lessons, beat by beat"
        case label           // Home: progress label, e.g. "DRUMS", "PROJECTS"
        case bodyLarge       // e.g. "Choose a station to build your track"
        case rowTitle        // Lesson row titles, "0 / 4 Complete"
        case caption         // Small capitals, e.g. "SWIPE", "FINALE", "BPM"
        case button          // Text on CTA buttons, e.g. "Start Drums"
        case secondaryButton // Text links, e.g. "ALL STATIONS"

        /// The size in points, exactly as in Figma, before Dynamic Type scaling.
        var size: CGFloat {
            switch self {
            case .hero: 54
            case .heroSecondary: 32
            case .title: 20
            case .heading: 14
            case .bigNumber: 14
            case .kicker: 12
            case .smallNumber: 12
            case .coins: 16
            case .detailTitle: 20
            case .body: 15
            case .subtitle: 12
            case .label: 11
            case .bodyLarge: 16
            case .rowTitle: 15
            case .caption: 11
            case .button: 15
            case .secondaryButton: 13
            }
        }

        /// Which built-in iOS text style this role grows with when the user
        /// changes their text size in Settings.
        var scalesLike: Font.TextStyle {
            switch self {
            case .hero: .largeTitle
            case .heroSecondary: .title
            case .title: .title3
            case .heading: .headline
            case .bigNumber: .headline
            case .kicker: .caption
            case .smallNumber: .caption
            case .coins: .callout
            case .detailTitle: .title3
            case .body: .subheadline
            case .subtitle: .caption
            case .label: .caption2
            case .bodyLarge: .callout
            case .rowTitle: .subheadline
            case .caption: .caption2
            case .button: .subheadline
            case .secondaryButton: .footnote
            }
        }

        /// Extra space between letters, in points (Figma "letter spacing").
        var tracking: CGFloat {
            switch self {
            case .kicker, .secondaryButton, .label: 1.5
            case .caption: 1
            default: 0
            }
        }

        /// Builds the actual font at an already-scaled size.
        func font(size: CGFloat) -> Font {
            switch self {
            case .hero, .heroSecondary, .title, .heading, .bigNumber, .kicker, .smallNumber, .coins:
                // `fixedSize` because the size is already scaled by the modifier
                // below; otherwise iOS would scale it a second time.
                // Note: Figma asks for Pulse12 *Regular* on `kicker`, but only the
                // Bold file exists in Resources/Fonts, so Bold is used for now.
                Font.custom(AppFont.pulse12Name, fixedSize: size)
            case .body, .bodyLarge, .subtitle:
                Font.system(size: size, weight: .regular, design: .monospaced)
            case .rowTitle, .caption, .secondaryButton, .label:
                Font.system(size: size, weight: .semibold, design: .monospaced)
            case .detailTitle, .button:
                Font.system(size: size, weight: .bold, design: .monospaced)
            }
        }
    }

    /// The font's internal (PostScript) name, read from Pulse12-Bold.ttf.
    static let pulse12Name = "Pulse12-Bold"

    /// Makes Pulse12 available to SwiftUI. Call once at app start (and in
    /// previews, which skip app start). Calling it again does nothing.
    static func registerFonts() {
        _ = registration
    }

    /// Runs the registration code the first time it is read, and never again.
    private static let registration: Void = {
        guard let url = Bundle.main.url(forResource: "Pulse12-Bold", withExtension: "ttf") else {
            assertionFailure("Pulse12-Bold.ttf is missing from the app bundle")
            return
        }
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }()
}

/// Applies an `AppFont.Role`: the right font, letter spacing, and a size that
/// follows the user's text-size setting.
private struct AppFontModifier: ViewModifier {
    let role: AppFont.Role

    /// `@ScaledMetric` takes the Figma size and returns it scaled for the
    /// user's current text size, updating live when they change it.
    @ScaledMetric private var size: CGFloat

    init(role: AppFont.Role) {
        self.role = role
        _size = ScaledMetric(wrappedValue: role.size, relativeTo: role.scalesLike)
    }

    func body(content: Content) -> some View {
        content
            .font(role.font(size: size))
            .tracking(role.tracking)
    }
}

extension View {
    /// Styles text with one of the app's roles, e.g. `Text("Learn").appFont(.title)`.
    func appFont(_ role: AppFont.Role) -> some View {
        modifier(AppFontModifier(role: role))
    }
}

// MARK: - Preview: every text style and colour, to check Pulse12 renders.

#Preview(traits: .landscapeLeft) {
    AppFont.registerFonts()

    let samples: [(AppFont.Role, String, String)] = [
        (.hero, "hero · Pulse12 54", "LEARN"),
        (.heroSecondary, "heroSecondary · Pulse12 32", "CHALLENGE"),
        (.title, "title · Pulse12 20", "Learn"),
        (.heading, "heading · Pulse12 14", "Bass and Melody"),
        (.bigNumber, "bigNumber · Pulse12 14", "060  0/4  1 2 3 4"),
        (.kicker, "kicker · Pulse12 12", "DRUMS"),
        (.smallNumber, "smallNumber · Pulse12 12", "0/4  00"),
        (.coins, "coins · Pulse12 16", "0"),
        (.detailTitle, "detailTitle · SF Mono Bold 20", "Tempo and Beats"),
        (.body, "body · SF Mono 15", "Short descriptions"),
        (.subtitle, "subtitle · SF Mono 12", "Lessons, beat by beat"),
        (.label, "label · SF Mono SemiBold 11", "DRUMS  PROJECTS"),
        (.bodyLarge, "bodyLarge · SF Mono 16", "Choose a station to build your track"),
        (.rowTitle, "rowTitle · SF Mono SemiBold 15", "Tempo and Beats"),
        (.caption, "caption · SF Mono SemiBold 11", "SWIPE  FINALE  BPM"),
        (.button, "button · SF Mono Bold 15", "Start Drums"),
        (.secondaryButton, "secondaryButton · SF Mono SemiBold 13", "ALL STATIONS"),
    ]

    let colors: [(String, Color)] = [
        ("background", AppColor.background),
        ("surface", AppColor.surface),
        ("surfaceRaised", AppColor.surfaceRaised),
        ("stroke", AppColor.stroke),
        ("progressEmpty", AppColor.progressEmpty),
        ("progressEmptyStroke", AppColor.progressEmptyStroke),
        ("textPrimary", AppColor.textPrimary),
        ("textSecondary", AppColor.textSecondary),
        ("accentCyan", AppColor.accentCyan),
        ("accentPink", AppColor.accentPink),
    ]

    return ScrollView {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(samples, id: \.1) { role, label, text in
                VStack(alignment: .leading, spacing: 4) {
                    Text(label)
                        .appFont(.caption)
                        .foregroundStyle(AppColor.textSecondary)
                    Text(text)
                        .appFont(role)
                        .foregroundStyle([.hero, .heroSecondary, .bigNumber, .smallNumber].contains(role)
                                         ? AppColor.accentCyan : AppColor.textPrimary)
                }
            }

            HStack(spacing: 8) {
                ForEach(colors, id: \.0) { name, color in
                    VStack(spacing: 4) {
                        Rectangle()
                            .fill(color)
                            .frame(width: 56, height: 32)
                            .overlay(Rectangle().stroke(AppColor.stroke))
                        Text(name)
                            .appFont(.caption)
                            .foregroundStyle(AppColor.textSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .frame(width: 64)
                    }
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    .background(AppColor.background)
}
