import SwiftUI

/// Three to four pages. Skip writes a loose thread and the completion flag.
struct OnboardingView: View {
    @ObservedObject var session: HubSession
    @State private var page = 0
    @Environment(\.dynamicTypeSize) private var dynamic

    private let pages: [(title: String, line: String, art: String)] = [
        ("Tie a caption", "A knot is a short line on today's bead.", "hed_Onboarding1"),
        ("String the knot", "Add a photo or a voice note. It stays on this device.", "hed_Onboarding2"),
        ("Read the cloth", "Each strung knot fills a week on the year cloth.", "hed_Onboarding3"),
        ("Look back", "On this day lines up the same date in prior years.", "hed_TwistHero")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: BeadChrome.pad) {
            HStack {
                Text(BeadChrome.count(page + 1))
                    .font(BeadChrome.caption)
                    .foregroundStyle(DesignTokens.muted)
                    .accessibilityLabel("Page \(BeadChrome.count(page + 1))")
                Spacer()
                Button("Skip") {
                    Task { await session.skipOnboarding() }
                }
                .buttonStyle(CommitButtonStyle(kind: .quiet))
                .frame(maxWidth: BeadChrome.field * 4)
            }
            BeadArt(name: pages[page].art)
                .layoutPriority(-1)
            Text(pages[page].title)
                .font(BeadChrome.display(dynamic: dynamic))
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.6)
            Text(pages[page].line)
                .font(BeadChrome.body)
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            Button(page == pages.count - 1 ? "Continue" : "Next") {
                if page == pages.count - 1 {
                    Task { await session.finishOnboarding() }
                } else {
                    page += 1
                }
            }
            .buttonStyle(CommitButtonStyle())
        }
        .padding(BeadChrome.pad)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(DesignTokens.bg)
    }
}
