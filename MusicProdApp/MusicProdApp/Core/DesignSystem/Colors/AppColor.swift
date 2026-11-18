import SwiftUI

/// The app's colour palette. Values checked against the Figma variables on
/// page "HiFi 4 · Digital" (Nov 2026). Always use these instead of typing
/// colours inline.
enum AppColor {
    static let background = Color(hex: 0x000000)    // bg/black
    static let surface = Color(hex: 0x1C1C1E)       // surface/charcoal
    static let surfaceRaised = Color(hex: 0x2C2C2E) // surface/raised
    static let stroke = Color(hex: 0x38383A)        // stroke/subtle
    static let textPrimary = Color(hex: 0xFFFFFF)   // text/primary
    static let textSecondary = Color(hex: 0x9A9EA3) // text/secondary
    static let accentCyan = Color(hex: 0x00DFD6)    // accent/cyan
    static let accentPink = Color(hex: 0xFF1E9D)    // accent/pink (not on the HiFi 4 frames checked)

    // Empty progress segments (Home, Station Selection). Used in Figma as
    // plain hex values, not saved as Figma variables.
    static let progressEmpty = Color(hex: 0x2A2D2F)       // segment fill
    static let progressEmptyStroke = Color(hex: 0x3A3D40) // segment border; Home segment fill
}
