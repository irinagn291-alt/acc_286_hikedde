import SwiftUI

/// Strung knots that share this month and day in earlier years, set beside today.
struct OnThisDayView: View {
    @ObservedObject var session: HubSession
    @Environment(\.dismiss) private var dismiss
    @StateObject private var player = VoicePlayer()

    private var rows: [Knot] { session.store.onThisDay(today: Date()) }

    var body: some View {
        NavigationStack {
            Group {
                if let recovery = session.recovery, rows.isEmpty {
                    StatusPage(
                        art: "hed_TwistHero",
                        title: "On this day could not be read",
                        line: recovery,
                        verb: "Retry",
                        action: { Task { await session.retry() } }
                    )
                } else if rows.isEmpty {
                    StatusPage(
                        art: "hed_TwistHero",
                        title: "No prior year on this date",
                        line: "String today to leave a knot for next year",
                        verb: "String",
                        action: { session.armString() }
                    )
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: BeadChrome.pad) {
                            Text("Today")
                                .font(BeadChrome.caption)
                                .foregroundStyle(DesignTokens.muted)
                            knotCard(session.openKnot, prior: false)
                            Text("Earlier years")
                                .font(BeadChrome.caption)
                                .foregroundStyle(DesignTokens.muted)
                            ForEach(rows) { knot in
                                knotCard(knot, prior: true)
                            }
                        }
                        .padding(BeadChrome.pad)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DesignTokens.bg)
            .navigationTitle("On this day")
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

    private func knotCard(_ knot: Knot, prior: Bool) -> some View {
        Button {
            if prior {
                session.cover = .thread(knotID: knot.id)
            }
        } label: {
            HStack(alignment: .center, spacing: BeadChrome.stack) {
                thumb(knot)
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: BeadChrome.chip, style: .continuous))
                VStack(alignment: .leading, spacing: BeadChrome.tight) {
                    Text(BeadChrome.dayLabel(knot.dayKey))
                        .font(BeadChrome.caption)
                        .foregroundStyle(DesignTokens.phaseColor(knot.phase))
                    Text(knot.caption.isEmpty ? "No caption" : knot.caption)
                        .font(BeadChrome.body)
                        .foregroundStyle(DesignTokens.ink)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(BeadChrome.stack)
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: BeadChrome.card, style: .continuous))
            .thickFrame()
        }
        .buttonStyle(BeadPressStyle())
        .disabled(prior == false)
        .overlay(alignment: .bottomTrailing) {
            if knot.media == .voice {
                VoiceLane(fileName: knot.fileName, player: player)
                    .frame(width: 180)
                    .padding(BeadChrome.tight)
            }
        }
    }

    @ViewBuilder
    private func thumb(_ knot: Knot) -> some View {
        if let image = BeadFile.loadImage(fileName: knot.fileName) {
            BeadPhoto(image: image)
        } else {
            BeadCanvas(showsThread: false, phase: knot.phase)
        }
    }
}
