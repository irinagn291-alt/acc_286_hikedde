import SwiftUI
import UIKit

/// One strung knot. The bead or photo fills the well. The caption stays on the plate.
struct GalleryTile: View {
    let knot: Knot

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            well
                .frame(maxWidth: .infinity)
                .frame(height: BeadChrome.tileTall)
                .clipped()
            VStack(alignment: .leading, spacing: BeadChrome.tight) {
                Text(knot.caption.isEmpty ? "No caption" : knot.caption)
                    .font(BeadChrome.headline)
                    .foregroundStyle(DesignTokens.ink)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                Text(BeadChrome.dayLabel(knot.dayKey))
                    .font(BeadChrome.body)
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(1)
                Text("Strung")
                    .font(BeadChrome.caption)
                    .foregroundStyle(DesignTokens.accent)
                    .lineLimit(1)
            }
            .padding(BeadChrome.stack)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DesignTokens.bg)
        }
        .background(DesignTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: BeadChrome.card, style: .continuous))
        .thickFrame()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(knot.caption), \(BeadChrome.dayLabel(knot.dayKey))")
        .accessibilityHint("Opens this knot")
    }

    @ViewBuilder
    private var well: some View {
        if let image = BeadFile.loadImage(fileName: knot.fileName) {
            BeadPhoto(image: image)
        } else {
            BeadCanvas()
        }
    }
}
