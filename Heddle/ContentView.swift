import SwiftUI

struct ContentView: View {
    @StateObject private var session = HubSession()
    @Environment(\.scenePhase) private var scenePhase
    @State private var showWait = false

    var body: some View {
        Group {
            if session.ready == false || waitingForReview {
                if showWait {
                    ProgressView()
                        .tint(DesignTokens.accent)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .accessibilityLabel("Loading")
                } else {
                    Color.clear
                }
            } else if session.document.onboardingComplete == false || session.showIntro {
                OnboardingView(session: session)
            } else {
                HubView(session: session)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignTokens.bg.ignoresSafeArea())
        .preferredColorScheme(.dark)
        .task {
            try? await Task.sleep(nanoseconds: 150_000_000)
            if session.ready == false {
                showWait = true
            }
        }
        .task {
            await session.boot()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                session.refreshClock()
            } else {
                Task { await session.store.noteScenePhase(inactiveOrBackground: true) }
            }
        }
        .onChange(of: session.document.onboardingComplete) { _, done in
            if done { session.consumeReview() }
        }
    }

    private var waitingForReview: Bool {
        session.document.onboardingComplete && session.showIntro == false && session.reviewReady == false
    }
}

#Preview {
    ContentView()
}
