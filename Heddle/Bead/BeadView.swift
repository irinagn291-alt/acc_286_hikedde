import SwiftUI

/// A past bead on the thread. The photo or drawn bead sits on the thread line.
struct BeadView: View {
    let knot: Knot

    var body: some View {
        HStack(alignment: .center, spacing: BeadChrome.stack) {
            bead
                .frame(width: 84, height: 84)
                .clipShape(Circle())
                .overlay(Circle().stroke(DesignTokens.ink, lineWidth: BeadChrome.rule))
            VStack(alignment: .leading, spacing: BeadChrome.tight) {
                Text(knot.caption.isEmpty ? "No caption" : knot.caption)
                    .font(BeadChrome.body)
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Text(BeadChrome.dayLabel(knot.dayKey))
                    .font(BeadChrome.caption)
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Text(phaseWord)
                .font(BeadChrome.caption)
                .foregroundStyle(DesignTokens.phaseColor(knot.phase))
                .lineLimit(1)
        }
        .padding(BeadChrome.stack)
        .frame(maxWidth: .infinity, minHeight: BeadChrome.pastBead, alignment: .leading)
        .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: BeadChrome.card, style: .continuous))
        .thickFrame()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(knot.caption.isEmpty ? "No caption" : knot.caption)
        .accessibilityHint("Opens this bead")
    }

    @ViewBuilder
    private var bead: some View {
        if let image = BeadFile.loadImage(fileName: knot.fileName) {
            BeadPhoto(image: image)
        } else {
            BeadCanvas(showsThread: true, phase: knot.phase)
        }
    }

    private var phaseWord: String {
        switch knot.phase {
        case .loose: return "Loose"
        case .tied: return "Tied"
        case .strung: return "Strung"
        }
    }
}
