import SwiftUI

/// Today's bead on the vertical thread. Drawn in UIKit so the frame shows the bead.
struct OpenBeadView: View {
    let knot: Knot
    @StateObject private var player = VoicePlayer()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                BeadCanvas(phase: knot.phase)
                if knot.media == .photo, let image = BeadFile.loadImage(fileName: knot.fileName) {
                    BeadPhoto(image: image)
                        .clipShape(Circle())
                        .padding(36)
                        .accessibilityLabel("Strung photo")
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 188)
            VStack(alignment: .leading, spacing: BeadChrome.tight) {
                Text(phaseLabel)
                    .font(BeadChrome.caption)
                    .foregroundStyle(DesignTokens.bg)
                    .padding(.horizontal, BeadChrome.stack)
                    .padding(.vertical, BeadChrome.tight)
                    .background(
                        DesignTokens.phaseColor(knot.phase),
                        in: RoundedRectangle(cornerRadius: BeadChrome.chip, style: .continuous)
                    )
                Text(title)
                    .font(BeadChrome.headline)
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                Text(BeadChrome.dayLabel(knot.dayKey))
                    .font(BeadChrome.body)
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(1)
                if knot.media == .voice {
                    VoiceLane(fileName: knot.fileName, player: player)
                }
            }
            .padding(BeadChrome.stack)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DesignTokens.bg)
        }
        .background(DesignTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: BeadChrome.card, style: .continuous))
        .thickFrame()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(phaseLabel). \(title)")
        .onDisappear { player.stop() }
    }

    private var title: String {
        if knot.caption.isEmpty {
            return "Today is open"
        }
        return knot.caption
    }

    private var phaseLabel: String {
        switch knot.phase {
        case .loose: return "Loose"
        case .tied: return "Tied"
        case .strung: return "Strung"
        }
    }
}

/// Play control for a strung voice note. The bar is the fraction already heard.
struct VoiceLane: View {
    var fileName: String?
    @ObservedObject var player: VoicePlayer

    var body: some View {
        Button {
            player.toggle(fileName: fileName)
        } label: {
            HStack(spacing: BeadChrome.tight) {
                Image(systemName: player.playing ? "stop.fill" : "play.fill")
                    .font(BeadChrome.callout)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(DesignTokens.muted.opacity(0.45))
                        Capsule()
                            .fill(DesignTokens.accent)
                            .frame(width: max(8, geo.size.width * player.progress))
                    }
                }
                .frame(height: 8)
                Text(clock)
                    .font(BeadChrome.caption)
                    .foregroundStyle(DesignTokens.ink)
                    .monospacedDigit()
            }
            .foregroundStyle(DesignTokens.ink)
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(BeadPressStyle())
        .accessibilityLabel(player.playing ? "Stop voice note" : "Play voice note")
    }

    private var clock: String {
        let seconds = Int(player.duration.rounded())
        guard seconds > 0 else { return "Voice" }
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}
