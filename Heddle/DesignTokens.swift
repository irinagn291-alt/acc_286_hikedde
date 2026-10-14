import SwiftUI
import UIKit

/// SPEC section 7. The only place these hex values live — reach colours
/// and the font family through here. Keep this file and its values.
enum DesignTokens {
    /// #28482E
    static let bg = Color(red: 0.156863, green: 0.282353, blue: 0.180392)
    static let bgHex = "#28482E"
    /// #38573D
    static let surface = Color(red: 0.219608, green: 0.341176, blue: 0.239216)
    static let surfaceHex = "#38573D"
    /// #F4F6F4
    static let ink = Color(red: 0.956863, green: 0.964706, blue: 0.956863)
    static let inkHex = "#F4F6F4"
    /// #7BD58A
    static let accent = Color(red: 0.482353, green: 0.835294, blue: 0.541176)
    static let accentHex = "#7BD58A"
    /// #B6C3B8
    static let muted = Color(red: 0.713725, green: 0.764706, blue: 0.721569)
    static let mutedHex = "#B6C3B8"
    /// Amber knot that is waiting for a string.
    static let tied = Color(red: 0.831373, green: 0.615686, blue: 0.278431)
    /// Rust for a string that did not catch a knot.
    static let drift = Color(red: 0.545098, green: 0.321569, blue: 0.219608)
    static let fontFamily = "Trebuchet MS"

    static let bgUI = UIColor(red: 0.156863, green: 0.282353, blue: 0.180392, alpha: 1)
    static let surfaceUI = UIColor(red: 0.219608, green: 0.341176, blue: 0.239216, alpha: 1)
    static let inkUI = UIColor(red: 0.956863, green: 0.964706, blue: 0.956863, alpha: 1)
    static let accentUI = UIColor(red: 0.482353, green: 0.835294, blue: 0.541176, alpha: 1)
    static let mutedUI = UIColor(red: 0.713725, green: 0.764706, blue: 0.721569, alpha: 1)
    static let tiedUI = UIColor(red: 0.831373, green: 0.615686, blue: 0.278431, alpha: 1)
    static let driftUI = UIColor(red: 0.545098, green: 0.321569, blue: 0.219608, alpha: 1)

    static func phaseColor(_ phase: Knot.Phase) -> Color {
        switch phase {
        case .loose: return muted
        case .tied: return tied
        case .strung: return accent
        }
    }

    static func phaseUI(_ phase: Knot.Phase) -> UIColor {
        switch phase {
        case .loose: return mutedUI
        case .tied: return tiedUI
        case .strung: return accentUI
        }
    }
}
