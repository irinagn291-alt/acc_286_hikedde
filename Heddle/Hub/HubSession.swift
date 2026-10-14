import Foundation
import SwiftUI

/// Sheets over the thread. Tie and String stay on Hub and are not covers.
enum HubCover: Identifiable, Equatable {
    case gallery
    case cloth
    case thread(knotID: UUID?)
    case onThisDay
    case settings

    var id: String {
        switch self {
        case .gallery: return "gallery"
        case .cloth: return "cloth"
        case .thread(let knotID): return "thread-\(knotID?.uuidString ?? "none")"
        case .onThisDay: return "onthisday"
        case .settings: return "settings"
        }
    }
}

/// Views talk to the thread store through this session. One review read after onboarding.
@MainActor
final class HubSession: ObservableObject {
    let store: ThreadStore
    @Published private(set) var ready = false
    @Published private(set) var tick = 0
    @Published var cover: HubCover?
    @Published var notice: String?
    @Published var working = false
    @Published var celebrate = false
    @Published var stringArmed = false
    @Published private(set) var showIntro = false
    @Published private(set) var reviewReady = false
    private var reviewRead = false
    private var reviewKey: String?
    private var coverApplied = false
    private var dayTask: Task<Void, Never>?

    init(store: ThreadStore? = nil) {
        if let store {
            self.store = store
        } else {
            self.store = ThreadStore(
                defaults: .standard,
                disk: ThreadDisk(root: ThreadDisk.applicationSupport())
            )
        }
    }

    var document: ThreadDocument { store.document }
    var recovery: String? { store.recoveryNote }

    var knots: [Knot] {
        _ = tick
        return document.knots
    }

    var openKnot: Knot {
        _ = tick
        return store.openKnot(on: Date())
    }

    func boot() async {
        guard ready == false else { return }
        #if targetEnvironment(simulator)
        await store.load(seedIfSimulator: true)
        #else
        await store.load(seedIfSimulator: false)
        #endif
        ready = true
        tick += 1
        if document.onboardingComplete {
            consumeReview()
        }
        watchDay()
    }

    /// Reads `ReviewLaunch.screen` once, only after onboarding is finished.
    func consumeReview() {
        guard ready, document.onboardingComplete, reviewRead == false else { return }
        reviewRead = true
        reviewKey = ReviewLaunch.screen
        if reviewKey == "onboarding" {
            showIntro = true
        }
        reviewReady = true
    }

    /// Applies the stored key after Hub is on screen so the sheet can present.
    func applyCover() {
        guard reviewReady, coverApplied == false else { return }
        coverApplied = true
        switch reviewKey {
        case "log", "gallery":
            cover = .gallery
        case "goals", "cloth":
            cover = .cloth
        case "thread":
            let earlier = document.knots.last(where: { $0.phase == .strung })
            cover = .thread(knotID: earlier?.id)
        case "onthisday":
            cover = .onThisDay
        case "settings":
            cover = .settings
        default:
            cover = nil
        }
    }

    func armString() {
        cover = nil
        stringArmed = true
    }

    func retry() async {
        await store.load(seedIfSimulator: false)
        tick += 1
    }

    func refreshClock() {
        tick += 1
    }

    private func watchDay() {
        dayTask?.cancel()
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let next = calendar.date(byAdding: .day, value: 1, to: start) ?? start.addingTimeInterval(86_400)
        let delay = max(next.timeIntervalSinceNow, 1)
        dayTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            guard let self, Task.isCancelled == false else { return }
            self.tick += 1
            self.watchDay()
        }
    }

    func tie(caption: String) -> Bool {
        let outcome = store.tie(caption: caption, on: Date())
        tick += 1
        switch outcome {
        case .tied:
            notice = nil
            return true
        case .full:
            notice = "Today already has a knot. Peel to tie again."
            return false
        case .emptyCaption:
            notice = "Write a caption, then Tie."
            return false
        default:
            return false
        }
    }

    func string(fileName: String, media: Knot.Media, bytes: Data) async -> Bool {
        working = true
        defer { working = false }
        let outcome = await store.attach(fileName: fileName, media: media, bytes: bytes, on: Date())
        tick += 1
        switch outcome {
        case .strung:
            notice = nil
            return true
        case .drift:
            notice = "That string did not tie. Tie a caption first."
            return false
        case .alreadyStrung:
            notice = "Today is already strung. Peel to string again."
            return false
        default:
            notice = recovery
            return false
        }
    }

    func peel() async {
        _ = await store.peel()
        tick += 1
        notice = nil
    }

    func skipOnboarding() async {
        await store.skipOnboarding()
        showIntro = false
        tick += 1
        consumeReview()
    }

    func finishOnboarding() async {
        await store.completeOnboarding()
        showIntro = false
        tick += 1
        consumeReview()
    }

    func reopenOnboarding() async {
        cover = nil
        await store.reopenOnboarding()
        tick += 1
    }

    func resetThread() async {
        let settings = Settings(store: store)
        await settings.resetAllData()
        cover = nil
        tick += 1
        notice = recovery
    }

    func exportURL() async -> URL? {
        let data: Data
        do {
            data = try document.encoded()
        } catch {
            notice = "The thread could not be exported."
            return nil
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("heddle-thread.json")
        let saved = await Task.detached(priority: .utility) {
            do {
                try data.write(to: url, options: .atomic)
                return true
            } catch {
                return false
            }
        }.value
        if saved {
            return url
        }
        notice = "The thread could not be exported."
        return nil
    }

    func exportBroadsheet() -> URL? {
        guard let url = WeftBroadsheet.write(document: document) else {
            notice = "The weft could not be printed."
            return nil
        }
        return url
    }

    func knot(id: UUID?) -> Knot? {
        guard let id else { return nil }
        return document.knots.first { $0.id == id }
    }
}
