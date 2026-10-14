import XCTest
@testable import Heddle

@MainActor
final class ThreadPersistenceTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? TimeZone.current
        return calendar
    }

    private func harness() -> (ThreadStore, UserDefaults, URL, String) {
        let name = "hed.persist.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name) ?? UserDefaults.standard
        defaults.removePersistentDomain(forName: name)
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(name, isDirectory: true)
        let store = ThreadStore(defaults: defaults, disk: ThreadDisk(root: root), calendar: calendar, debounceNanoseconds: 60_000_000_000)
        return (store, defaults, root, name)
    }

    func testRoundTripReload() async throws {
        let (store, defaults, root, _) = harness()
        let today = date(2026, 6, 15)
        XCTAssertEqual(store.tie(caption: "Filed", on: today, now: today), .tied)
        let outcome = await store.attach(fileName: "filed.jpg", media: .photo, bytes: Data("bead".utf8), on: today, now: today)
        XCTAssertEqual(outcome, .strung)
        await store.flush()
        let media = root.appendingPathComponent("media").appendingPathComponent("filed.jpg")
        let written = try Data(contentsOf: media)
        XCTAssertEqual(written, Data("bead".utf8))

        let reloaded = ThreadStore(defaults: defaults, disk: ThreadDisk(root: root), calendar: calendar)
        await reloaded.load(seedIfSimulator: false)
        XCTAssertEqual(reloaded.document.knots.count, 1)
        XCTAssertEqual(reloaded.document.knots.first?.phase, .strung)
        XCTAssertEqual(reloaded.document.knots.first?.caption, "Filed")
        XCTAssertEqual(reloaded.document.knots.first?.fileName, "filed.jpg")
        XCTAssertNil(reloaded.recoveryNote)
    }

    func testCorruptDefaultsRestoreBackupThenLoose() async throws {
        let (store, defaults, root, _) = harness()
        let today = date(2026, 6, 15)
        let earlier = date(2026, 6, 1)
        XCTAssertEqual(store.tie(caption: "Kept", on: earlier, now: earlier), .tied)
        await store.flush()
        XCTAssertEqual(store.tie(caption: "Later", on: today, now: today), .tied)
        await store.flush()
        defaults.set(Data("not-json".utf8), forKey: ThreadDocument.defaultsKey)
        try Data("nope".utf8).write(to: root.appendingPathComponent("thread.json"), options: .atomic)

        let restored = ThreadStore(defaults: defaults, disk: ThreadDisk(root: root), calendar: calendar)
        await restored.load(seedIfSimulator: false)
        XCTAssertEqual(restored.document.knotMarks.map(\.caption), ["Kept"])
        XCTAssertEqual(restored.recoveryNote, "Restored the last good thread.")

        defaults.set(Data("still-bad".utf8), forKey: ThreadDocument.defaultsKey)
        try Data("nope".utf8).write(to: root.appendingPathComponent("thread.json.backup"), options: .atomic)
        try Data("nope".utf8).write(to: root.appendingPathComponent("thread.json"), options: .atomic)
        let fresh = ThreadStore(defaults: defaults, disk: ThreadDisk(root: root), calendar: calendar)
        await fresh.load(seedIfSimulator: false)
        XCTAssertTrue(fresh.document.knots.isEmpty)
        XCTAssertEqual(fresh.openKnot(on: today).phase, .loose)
        XCTAssertEqual(fresh.recoveryNote, "The thread file was unreadable. Started loose.")
    }

    func testResetAllDataDeletesMedia() async {
        let (store, defaults, root, _) = harness()
        let today = date(2026, 6, 15)
        XCTAssertEqual(store.tie(caption: "Gone", on: today, now: today), .tied)
        _ = await store.attach(fileName: "gone.jpg", media: .voice, bytes: Data([4]), on: today, now: today)
        await store.flush()
        let settings = Settings(store: store)
        await settings.resetAllData()
        XCTAssertTrue(store.document.knots.isEmpty)
        XCTAssertFalse(FileManager.default.fileExists(atPath: root.appendingPathComponent("media/gone.jpg").path))
        let reloaded = ThreadStore(defaults: defaults, disk: ThreadDisk(root: root), calendar: calendar)
        await reloaded.load(seedIfSimulator: false)
        XCTAssertTrue(reloaded.document.knotMarks.isEmpty)
        XCTAssertNil(reloaded.recoveryNote)
    }

    func testDebouncedSaveDoesNotFlushUntilAsked() async {
        let (store, defaults, _, _) = harness()
        XCTAssertEqual(store.tie(caption: "Wait", on: date(2026, 1, 2)), .tied)
        XCTAssertNil(defaults.data(forKey: ThreadDocument.defaultsKey))
        await store.noteScenePhase(inactiveOrBackground: true)
        XCTAssertNotNil(defaults.data(forKey: ThreadDocument.defaultsKey))
    }

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var parts = DateComponents()
        parts.year = year
        parts.month = month
        parts.day = day
        parts.hour = 12
        return calendar.date(from: parts) ?? Date(timeIntervalSince1970: 0)
    }
}
