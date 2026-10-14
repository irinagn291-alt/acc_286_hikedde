import Foundation

/// In-memory source of truth. UserDefaults and the thread file are projections.
/// Views talk to this store and never to UserDefaults. Saves debounce after
/// each mark and flush immediately after Peel or reset.
@MainActor
final class ThreadStore {
    private(set) var document: ThreadDocument
    private(set) var recoveryNote: String?
    private let defaults: UserDefaults
    private let disk: ThreadDisk
    private let calendar: Calendar
    private var saveTask: Task<Void, Never>?
    private let debounceNanoseconds: UInt64

    init(
        defaults: UserDefaults,
        disk: ThreadDisk,
        calendar: Calendar = .current,
        debounceNanoseconds: UInt64 = 300_000_000
    ) {
        self.defaults = defaults
        self.disk = disk
        self.calendar = calendar
        self.debounceNanoseconds = debounceNanoseconds
        self.document = .loose
    }

    func load(seedIfSimulator: Bool) async {
        if let data = defaults.data(forKey: ThreadDocument.defaultsKey),
           case .success(let decoded) = ThreadDocument.decode(data) {
            document = decoded
            recoveryNote = nil
        } else if let current = await disk.readDocument(),
                  case .success(let decoded) = ThreadDocument.decode(current) {
            document = decoded
            if defaults.data(forKey: ThreadDocument.defaultsKey) != nil {
                recoveryNote = "Restored the thread file."
                await flush()
            }
        } else if let backup = await disk.readBackup(),
                  case .success(let decoded) = ThreadDocument.decode(backup) {
            document = decoded
            recoveryNote = "Restored the last good thread."
            await flush()
        } else {
            document = .loose
            if defaults.data(forKey: ThreadDocument.defaultsKey) != nil {
                recoveryNote = "The thread file was unreadable. Started loose."
            }
        }

        if ThreadSeed.shouldApply(isSimulator: seedIfSimulator, defaults: defaults) {
            let seeded = ThreadSeed.document(now: Date(), calendar: calendar)
            document = seeded
            defaults.set(true, forKey: ThreadDocument.demoKey)
            for (name, bytes) in ThreadSeed.mediaPayloads(in: seeded) {
                do {
                    try await disk.writeMedia(bytes, fileName: name)
                } catch {
                    recoveryNote = "A seed file could not be written."
                }
            }
            await flush()
        }
    }

    func tie(caption: String, on date: Date, now: Date = Date()) -> MarkOutcome {
        let trimmed = caption.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return .emptyCaption
        }
        let key = DayKey.make(date, calendar: calendar)
        if document.knots.contains(where: { $0.dayKey == key && $0.phase != .loose }) {
            document.fullMarks.append(FullMark(id: UUID(), dayKey: key, createdAt: now))
            scheduleSave()
            return .full
        }
        document.knotMarks.append(
            KnotMark(id: UUID(), dayKey: key, caption: trimmed, createdAt: now)
        )
        refold()
        scheduleSave()
        return .tied
    }

    func string(fileName: String, media: Knot.Media, on date: Date, now: Date = Date()) -> MarkOutcome {
        let key = DayKey.make(date, calendar: calendar)
        if document.knots.contains(where: { $0.dayKey == key && $0.phase == .strung }) {
            return .alreadyStrung
        }
        guard let knot = document.knots.first(where: { $0.dayKey == key && $0.phase == .tied }) else {
            document.driftMarks.append(DriftMark(id: UUID(), dayKey: key, createdAt: now))
            scheduleSave()
            return .drift
        }
        document.stringMarks.append(
            StringMark(
                id: UUID(),
                dayKey: key,
                knotID: knot.id,
                fileName: fileName,
                media: media,
                createdAt: now
            )
        )
        refold()
        scheduleSave()
        return .strung
    }

    func attach(fileName: String, media: Knot.Media, bytes: Data, on date: Date, now: Date = Date()) async -> MarkOutcome {
        let outcome = string(fileName: fileName, media: media, on: date, now: now)
        if outcome == .strung {
            do {
                try await disk.writeMedia(bytes, fileName: fileName)
            } catch {
                recoveryNote = "The media file could not be saved."
            }
        }
        return outcome
    }

    func peel() async -> MarkOutcome {
        let which = Peel.newest(
            knotMarks: document.knotMarks,
            stringMarks: document.stringMarks,
            driftMarks: document.driftMarks,
            fullMarks: document.fullMarks
        )
        switch which {
        case .none:
            return .nothingToPeel
        case .knot(let id):
            document.knotMarks.removeAll { $0.id == id }
        case .string(let id, let fileName):
            document.stringMarks.removeAll { $0.id == id }
            do {
                try await disk.deleteMedia(fileName: fileName)
            } catch {
                recoveryNote = "The media file could not be removed."
            }
        case .drift(let id):
            document.driftMarks.removeAll { $0.id == id }
        case .full(let id):
            document.fullMarks.removeAll { $0.id == id }
        }
        refold()
        await flush()
        return .peeled
    }

    func beadDensity(on date: Date) -> Int {
        KnotFold.beadDensity(document.knots, dayKey: DayKey.make(date, calendar: calendar))
    }

    func onThisDay(today: Date) -> [Knot] {
        KnotFold.onThisDay(document.knots, today: today, calendar: calendar)
    }

    func weftRows() -> [WeftRow] {
        KnotFold.weft(document.knots, calendar: calendar)
    }

    func openKnot(on date: Date) -> Knot {
        KnotFold.openKnot(document.knots, on: date, calendar: calendar)
    }

    /// Skip and finish both persist the completion flag. Skip keeps a loose
    /// thread when nothing has been tied yet.
    func skipOnboarding() async {
        if document.knotMarks.isEmpty && document.stringMarks.isEmpty {
            document = .loose
        }
        document.onboardingComplete = true
        await flush()
    }

    func completeOnboarding() async {
        document.onboardingComplete = true
        await flush()
    }

    func reopenOnboarding() async {
        document.onboardingComplete = false
        await flush()
    }

    func eraseForReset() async {
        saveTask?.cancel()
        saveTask = nil
        document = .loose
        recoveryNote = nil
        let data: Data
        do {
            data = try document.encoded()
        } catch {
            recoveryNote = "The thread could not be cleared."
            return
        }
        defaults.set(data, forKey: ThreadDocument.defaultsKey)
        do {
            try await disk.reset(with: data)
        } catch {
            recoveryNote = "Media files could not be deleted."
        }
    }

    func noteScenePhase(inactiveOrBackground: Bool) async {
        if inactiveOrBackground {
            await flush()
        }
    }

    func flush() async {
        saveTask?.cancel()
        saveTask = nil
        let data: Data
        do {
            data = try document.encoded()
        } catch {
            recoveryNote = "The thread could not be saved."
            return
        }
        do {
            try await disk.writeDocument(data)
            defaults.set(data, forKey: ThreadDocument.defaultsKey)
        } catch is CancellationError {
            return
        } catch {
            recoveryNote = "The thread could not be saved."
        }
    }

    private func scheduleSave() {
        saveTask?.cancel()
        let delay = debounceNanoseconds
        saveTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: delay)
            guard let self, !Task.isCancelled else { return }
            await self.flush()
        }
    }

    private func refold() {
        document.knots = KnotFold.knots(
            knotMarks: document.knotMarks,
            stringMarks: document.stringMarks
        )
    }
}

enum MarkOutcome: Equatable, Sendable {
    case tied
    case strung
    case full
    case drift
    case alreadyStrung
    case peeled
    case emptyCaption
    case nothingToPeel
}
