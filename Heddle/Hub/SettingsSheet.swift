import PDFKit
import SwiftUI

/// Export, reset, onboarding again, and the contact link.
struct SettingsView: View {
    @ObservedObject var session: HubSession
    @Environment(\.dismiss) private var dismiss
    @State private var confirmReset = false
    @State private var exportURL: URL?
    @State private var broadsheetURL: URL?
    @AppStorage(Tremble.defaultsKey) private var haptics = true

    var body: some View {
        NavigationStack {
            Form {
                if let recovery = session.recovery {
                    Section {
                        Text(recovery)
                            .font(BeadChrome.body)
                            .foregroundStyle(DesignTokens.ink)
                        Button("Close") { dismiss() }
                            .buttonStyle(CommitButtonStyle(kind: .quiet))
                    }
                    .listRowBackground(DesignTokens.surface)
                } else if session.knots.isEmpty {
                    Section {
                        Text("The thread has no knots")
                            .font(BeadChrome.headline)
                            .foregroundStyle(DesignTokens.ink)
                        Text("Tie a caption on today")
                            .font(BeadChrome.body)
                            .foregroundStyle(DesignTokens.ink)
                    }
                    .listRowBackground(DesignTokens.surface)
                } else {
                    Section {
                        Text("Knots on the thread")
                            .font(BeadChrome.caption)
                            .foregroundStyle(DesignTokens.ink)
                        Text(BeadChrome.count(session.knots.count))
                            .font(BeadChrome.title)
                            .foregroundStyle(DesignTokens.accent)
                            .monospacedDigit()
                    }
                    .listRowBackground(DesignTokens.surface)
                }
                Section {
                    Button("Show introduction") {
                        Task { await session.reopenOnboarding() }
                    }
                    .font(BeadChrome.body)
                    .foregroundStyle(DesignTokens.ink)
                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                    if let exportURL {
                        ShareLink(item: exportURL) {
                            Text("Export thread")
                                .font(BeadChrome.body)
                                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                                .contentShape(Rectangle())
                        }
                    } else {
                        Button("Export thread") {
                            Task { exportURL = await session.exportURL() }
                        }
                        .font(BeadChrome.body)
                        .foregroundStyle(DesignTokens.ink)
                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                    }
                    if let broadsheetURL {
                        ShareLink(item: broadsheetURL) {
                            Text("Export weft")
                                .font(BeadChrome.body)
                                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                                .contentShape(Rectangle())
                        }
                    } else {
                        Button("Export weft") {
                            broadsheetURL = session.exportBroadsheet()
                        }
                        .font(BeadChrome.body)
                        .foregroundStyle(DesignTokens.ink)
                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                    }
                    Toggle("Haptics", isOn: $haptics)
                        .font(BeadChrome.body)
                        .foregroundStyle(DesignTokens.ink)
                        .tint(DesignTokens.accent)
                    Button("Reset thread") { confirmReset = true }
                        .font(BeadChrome.body)
                        .foregroundStyle(DesignTokens.ink)
                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                    if let contact = URL(string: "https://heddle-bead.pro/contact-us") {
                        Link(destination: contact) {
                            Text("Contact")
                                .font(BeadChrome.body)
                                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                                .contentShape(Rectangle())
                        }
                    }
                }
                .listRowBackground(DesignTokens.surface)
            }
            .scrollContentBackground(.hidden)
            .background(DesignTokens.bg)
            .navigationTitle("Settings")
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
            .alert("Reset thread", isPresented: $confirmReset) {
                Button("Delete thread", role: .destructive) {
                    Task { await session.resetThread() }
                }
                Button("Close", role: .cancel) {}
            } message: {
                Text("The thread and its media files will be deleted.")
            }
        }
    }
}

/// Prints the thread as one broadsheet. The file is a PDF the share sheet can hand off.
enum WeftBroadsheet {
    static func write(document: ThreadDocument) -> URL? {
        let page = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: page)
        let data = renderer.pdfData { context in
            context.beginPage()
            let ink = UIColor(red: 0.12, green: 0.18, blue: 0.13, alpha: 1)
            ink.setFill()
            ("Сhikedde" as NSString).draw(at: CGPoint(x: 48, y: 48), withAttributes: [
                .font: UIFont.boldSystemFont(ofSize: 28),
                .foregroundColor: ink
            ])
            ("Weft broadsheet" as NSString).draw(at: CGPoint(x: 48, y: 84), withAttributes: [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: ink
            ])
            var y: CGFloat = 130
            let knots = document.knots.filter { $0.phase != .loose }
            for knot in knots {
                if y > 740 {
                    context.beginPage()
                    y = 48
                }
                let phase: String
                switch knot.phase {
                case .loose: phase = "Loose"
                case .tied: phase = "Tied"
                case .strung: phase = "Strung"
                }
                let line = "\(BeadChrome.dayLabel(knot.dayKey))  \(phase)  \(knot.caption)"
                (line as NSString).draw(
                    in: CGRect(x: 48, y: y, width: 516, height: 36),
                    withAttributes: [
                        .font: UIFont.systemFont(ofSize: 12),
                        .foregroundColor: ink
                    ]
                )
                y += 28
            }
            if knots.isEmpty {
                ("The thread has no knots." as NSString).draw(at: CGPoint(x: 48, y: y), withAttributes: [
                    .font: UIFont.systemFont(ofSize: 14),
                    .foregroundColor: ink
                ])
            }
        }
        guard let pdf = PDFDocument(data: data) else { return nil }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("heddle-weft.pdf")
        return pdf.write(to: url) ? url : nil
    }
}
