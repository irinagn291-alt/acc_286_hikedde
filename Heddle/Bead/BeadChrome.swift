import SwiftUI
import UIKit

/// Presentation tokens. Colour, type, space, radius, and elevation each have
/// one accessor so Hub, Cloth, and sheets share the thick-frame rhythm.
enum BeadChrome {
    static let unit: CGFloat = 4
    static let tight: CGFloat = 8
    static let stack: CGFloat = 16
    static let pad: CGFloat = 24
    static let air: CGFloat = 32
    static let field: CGFloat = 48
    static let rule: CGFloat = 4
    static let hairline: CGFloat = 1
    static let decor: CGFloat = 72
    static let plate: CGFloat = 240
    static let openBead: CGFloat = 320
    static let pastBead: CGFloat = 96
    static let tile: CGFloat = 168
    static let tileTall: CGFloat = 248

    static let card: CGFloat = 24
    static let chip: CGFloat = 10

    static let spring = Animation.spring(response: 0.4, dampingFraction: 0.8)
    static let ease = Animation.easeOut(duration: 0.25)

    static func motion(_ reduce: Bool) -> Animation {
        reduce ? ease : spring
    }

    static func display(dynamic: DynamicTypeSize) -> Font {
        let points: CGFloat = dynamic.isAccessibilitySize ? 28 : 40
        return Font.custom(DesignTokens.fontFamily, size: points, relativeTo: .largeTitle).weight(.bold)
    }

    static var title: Font {
        Font.custom(DesignTokens.fontFamily, size: 28, relativeTo: .title).weight(.bold)
    }

    static var headline: Font {
        Font.custom(DesignTokens.fontFamily, size: 22, relativeTo: .title2)
    }

    static var body: Font {
        Font.custom(DesignTokens.fontFamily, size: 17, relativeTo: .body)
    }

    static var callout: Font {
        Font.custom(DesignTokens.fontFamily, size: 15, relativeTo: .callout)
    }

    static var caption: Font {
        Font.custom(DesignTokens.fontFamily, size: 13, relativeTo: .caption)
    }

    static func count(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }

    static func dayLabel(_ dayKey: Int) -> String {
        var parts = DateComponents()
        parts.year = DayKey.year(dayKey)
        parts.month = (dayKey / 100) % 100
        parts.day = dayKey % 100
        let calendar = Calendar.current
        guard let date = calendar.date(from: parts) else { return count(dayKey) }
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

extension View {
    func beadShadow() -> some View {
        shadow(color: Color.black.opacity(0.55), radius: BeadChrome.stack, x: 0, y: BeadChrome.unit)
    }

    func thickFrame(chip: Bool = false) -> some View {
        let radius = chip ? BeadChrome.chip : BeadChrome.card
        return overlay(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .stroke(DesignTokens.ink.opacity(0.55), lineWidth: BeadChrome.rule)
        )
    }
}

/// Pressed state for beads and header controls. Reduce Motion skips the scale.
struct BeadPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        BeadPressFace(pressed: configuration.isPressed, label: configuration.label)
    }
}

private struct BeadPressFace<Label: View>: View {
    var pressed: Bool
    var label: Label
    @Environment(\.accessibilityReduceMotion) private var reduce

    var body: some View {
        label
            .opacity(pressed ? 0.72 : 1)
            .scaleEffect(reduce || pressed == false ? 1 : 0.98)
    }
}

/// Generated art on a surface plate. A bead stands in until the imageset has pixels.
struct BeadArt: View {
    var name: String
    var body: some View {
        ZStack {
            DesignTokens.surface
            if UIImage(named: name) != nil {
                Image(name)
                    .resizable()
                    .scaledToFit()
                    .padding(BeadChrome.pad)
            } else {
                Circle()
                    .fill(DesignTokens.bg)
                    .overlay(
                        Circle().stroke(DesignTokens.ink.opacity(0.55), lineWidth: BeadChrome.rule)
                    )
                    .aspectRatio(1, contentMode: .fit)
                    .padding(BeadChrome.pad)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(minHeight: BeadChrome.field)
        .clipShape(RoundedRectangle(cornerRadius: BeadChrome.card, style: .continuous))
        .thickFrame()
        .beadShadow()
        .accessibilityHidden(true)
    }
}

/// Filled capsule for Tie and String. Quiet and destructive stay off the accent.
struct CommitButtonStyle: ButtonStyle {
    enum Kind {
        case commit
        case quiet
        case destructive
    }

    var kind: Kind = .commit
    var loading: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        CommitFace(kind: kind, loading: loading, pressed: configuration.isPressed, label: configuration.label)
    }
}

private struct CommitFace<Label: View>: View {
    var kind: CommitButtonStyle.Kind
    var loading: Bool
    var pressed: Bool
    var label: Label
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduce

    var body: some View {
        HStack(spacing: BeadChrome.tight) {
            if loading {
                ProgressView()
                    .tint(foreground)
            }
            label
                .font(BeadChrome.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .foregroundStyle(foreground)
        .frame(maxWidth: .infinity, minHeight: 44)
        .padding(.vertical, BeadChrome.tight)
        .contentShape(Capsule())
        .background(fill, in: Capsule())
        .overlay(Capsule().stroke(DesignTokens.ink.opacity(0.4), lineWidth: BeadChrome.rule))
        .opacity(pressed && isEnabled ? 0.72 : 1)
        .scaleEffect(reduce || pressed == false || isEnabled == false ? 1 : 0.98)
        .beadShadow()
    }

    private var fill: Color {
        switch kind {
        case .commit:
            return isEnabled ? DesignTokens.accent : DesignTokens.surface
        case .quiet, .destructive:
            return DesignTokens.surface
        }
    }

    private var foreground: Color {
        switch kind {
        case .commit:
            return isEnabled ? DesignTokens.bg : DesignTokens.muted
        case .quiet:
            return DesignTokens.ink
        case .destructive:
            return DesignTokens.ink
        }
    }
}
