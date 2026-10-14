import SwiftUI

/// Strung media. Empty, filled, and error. The log launch key opens this sheet.
struct GalleryView: View {
    @ObservedObject var session: HubSession
    @Environment(\.dismiss) private var dismiss

    private var strung: [Knot] {
        session.knots.filter { $0.phase == .strung }.sorted { $0.dayKey > $1.dayKey }
    }

    var body: some View {
        NavigationStack {
            Group {
                if let recovery = session.recovery, strung.isEmpty, session.knots.isEmpty == false {
                    StatusPage(
                        art: "hed_EmptyList",
                        title: "Gallery could not be read",
                        line: recovery,
                        verb: "Retry",
                        action: { Task { await session.retry() } }
                    )
                } else if strung.isEmpty {
                    StatusPage(
                        art: "hed_EmptyList",
                        title: "No strung beads",
                        line: "String a photo or a voice note on today's knot",
                        verb: "String",
                        action: { session.armString() }
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: BeadChrome.pad) {
                            ForEach(strung) { knot in
                                Button {
                                    session.cover = .thread(knotID: knot.id)
                                } label: {
                                    GalleryTile(knot: knot)
                                }
                                .buttonStyle(BeadPressStyle())
                                .contentShape(RoundedRectangle(cornerRadius: BeadChrome.card, style: .continuous))
                            }
                        }
                        .padding(BeadChrome.pad)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DesignTokens.bg)
            .navigationTitle("Gallery")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { close }
        }
    }

    private var close: some ToolbarContent {
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
