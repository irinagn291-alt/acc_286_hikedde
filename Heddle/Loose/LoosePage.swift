import SwiftUI

/// Empty thread. Full page, generated art, one headline, one line, one Tie.
struct LoosePage: View {
    @Binding var caption: String
    var tie: () -> Void
    @FocusState private var captionFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: BeadChrome.pad) {
            BeadArt(name: "hed_EmptyHome")
                .layoutPriority(-1)
            Text("The thread has no knots")
                .font(BeadChrome.display(dynamic: dynamic))
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.6)
                .fixedSize(horizontal: false, vertical: true)
            Text("Tie a caption on today")
                .font(BeadChrome.body)
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            TextField("Caption", text: $caption)
                .font(BeadChrome.body)
                .foregroundStyle(DesignTokens.ink)
                .focused($captionFocused)
                .padding(BeadChrome.stack)
                .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: BeadChrome.chip, style: .continuous))
                .thickFrame(chip: true)
                .submitLabel(.done)
                .onSubmit { captionFocused = false }
            Button("Tie", action: tie)
                .buttonStyle(CommitButtonStyle())
                .accessibilityHint("Writes a caption for today")
        }
        .padding(BeadChrome.pad)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Close") { captionFocused = false }
                    .accessibilityLabel("Close")
            }
        }
    }

    @Environment(\.dynamicTypeSize) private var dynamic
}
