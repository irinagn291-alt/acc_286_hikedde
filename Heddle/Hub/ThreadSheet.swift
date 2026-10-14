import SwiftUI

/// One earlier bead. Caption and media large. Empty, filled, and error states.
struct ThreadView: View {
    @ObservedObject var session: HubSession
    var knotID: UUID?
    @Environment(\.dismiss) private var dismiss
    @StateObject private var player = VoicePlayer()

    var body: some View {
        NavigationStack {
            Group {
                if let recovery = session.recovery, knot == nil {
                    StatusPage(
                        art: "hed_EmptyList",
                        title: "This bead could not be read",
                        line: recovery,
                        verb: "Retry"
                    ) { Task { await session.retry() } }
                } else if let knot {
                    filled(knot)
                } else {
                    StatusPage(
                        art: "hed_EmptyList",
                        title: "No bead selected",
                        line: "Tap a knot on the thread.",
                        verb: "Close"
                    ) { dismiss() }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DesignTokens.bg)
            .navigationTitle("Thread")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .frame(minWidth: 44, minHeight: 44)
                    }
                    .accessibilityLabel("Close")
                }
            }
        }
    }

    private var knot: Knot? { session.knot(id: knotID) }

    private func filled(_ knot: Knot) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                media(knot)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                VStack(alignment: .leading, spacing: BeadChrome.tight) {
                    Text(knot.caption.isEmpty ? "No caption" : knot.caption)
                        .font(BeadChrome.title)
                        .foregroundStyle(DesignTokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(BeadChrome.dayLabel(knot.dayKey))
                        .font(BeadChrome.body)
                        .foregroundStyle(DesignTokens.ink)
                    Text(phaseLine(knot))
                        .font(BeadChrome.headline)
                        .foregroundStyle(DesignTokens.accent)
                }
                .padding(BeadChrome.pad)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(DesignTokens.bg)
            }
        }
    }

    @ViewBuilder
    private func media(_ knot: Knot) -> some View {
        if let ui = BeadFile.loadImage(fileName: knot.fileName) {
            BeadPhoto(image: ui)
                .accessibilityLabel("Strung photo")
        } else if knot.media == .voice {
            VStack(spacing: BeadChrome.stack) {
                BeadCanvas(phase: knot.phase)
                VoiceLane(fileName: knot.fileName, player: player)
                    .padding(.horizontal, BeadChrome.pad)
            }
            .accessibilityLabel("Voice note")
        } else {
            BeadCanvas(phase: knot.phase)
        }
    }

    private func phaseLine(_ knot: Knot) -> String {
        switch knot.phase {
        case .loose: return "Loose. Tie a caption."
        case .tied: return "Tied. String a photo or a voice note."
        case .strung: return "Strung."
        }
    }

}

struct StatusPage: View {
    var art: String
    var title: String
    var line: String
    var verb: String
    var action: () -> Void
    @Environment(\.dynamicTypeSize) private var dynamic

    var body: some View {
        VStack(alignment: .leading, spacing: BeadChrome.pad) {
            BeadArt(name: art)
                .layoutPriority(-1)
            Text(title)
                .font(BeadChrome.display(dynamic: dynamic))
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(3)
                .minimumScaleFactor(0.6)
            Text(line)
                .font(BeadChrome.body)
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            Button(verb, action: action)
                .buttonStyle(CommitButtonStyle())
        }
        .padding(BeadChrome.pad)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}
