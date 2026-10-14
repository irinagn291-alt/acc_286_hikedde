import XCTest
@testable import Heddle

@MainActor
final class ThreadFoldTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? TimeZone.current
        return calendar
    }

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var parts = DateComponents()
        parts.year = year
        parts.month = month
        parts.day = day
        parts.hour = 12
        return calendar.date(from: parts) ?? Date(timeIntervalSince1970: 0)
    }

    private func makeStore() -> ThreadStore {
        let name = "hed.fold.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name) ?? UserDefaults.standard
        defaults.removePersistentDomain(forName: name)
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(name, isDirectory: true)
        return ThreadStore(defaults: defaults, disk: ThreadDisk(root: root), calendar: calendar)
    }

    func testBeadDensityPerDayAndOnThisDay() async {
        let store = makeStore()
        let today = date(2026, 10, 3)
        let lastYear = date(2025, 10, 3)
        let other = date(2025, 4, 2)
        XCTAssertEqual(store.beadDensity(on: today), 0)
        XCTAssertEqual(store.openKnot(on: today).phase, .loose)
        XCTAssertEqual(store.tie(caption: "Last year", on: lastYear, now: lastYear), .tied)
        _ = await store.attach(fileName: "prior.jpg", media: .photo, bytes: Data([1]), on: lastYear, now: lastYear)
        XCTAssertEqual(store.tie(caption: "Spring", on: other, now: other), .tied)
        _ = await store.attach(fileName: "spring.jpg", media: .photo, bytes: Data([2]), on: other, now: other)
        XCTAssertEqual(store.beadDensity(on: lastYear), 1)
        XCTAssertEqual(store.beadDensity(on: other), 1)
        let recalled = store.onThisDay(today: today)
        XCTAssertEqual(recalled.count, 1)
        XCTAssertEqual(recalled.first?.caption, "Last year")
        XCTAssertTrue(recalled.allSatisfy { $0.phase == .strung })
    }

    func testTieEmptyCaptionDoesNotWrite() {
        let store = makeStore()
        let today = date(2026, 10, 3)
        XCTAssertEqual(store.tie(caption: "   ", on: today), .emptyCaption)
        XCTAssertTrue(store.document.knotMarks.isEmpty)
        XCTAssertEqual(store.openKnot(on: today).phase, .loose)
    }

    func testTieThenStringThenSecondTieIsFullUntilPeel() async {
        let store = makeStore()
        let today = date(2026, 10, 3)
        XCTAssertEqual(store.tie(caption: "Morning light", on: today, now: today), .tied)
        XCTAssertEqual(store.openKnot(on: today).phase, .tied)
        let strung = await store.attach(
            fileName: "today.jpg",
            media: .photo,
            bytes: Data([9]),
            on: today,
            now: today.addingTimeInterval(10)
        )
        XCTAssertEqual(strung, .strung)
        XCTAssertEqual(store.openKnot(on: today).phase, .strung)
        XCTAssertEqual(store.weftRows().reduce(0) { $0 + $1.strungCount }, 1)
        XCTAssertEqual(store.tie(caption: "Again", on: today, now: today.addingTimeInterval(20)), .full)
        XCTAssertEqual(store.document.fullMarks.count, 1)
        XCTAssertEqual(store.beadDensity(on: today), 1)
        let peeledFull = await store.peel()
        XCTAssertEqual(peeledFull, .peeled)
        XCTAssertTrue(store.document.fullMarks.isEmpty)
        XCTAssertEqual(store.openKnot(on: today).phase, .strung)
        let peeledString = await store.peel()
        XCTAssertEqual(peeledString, .peeled)
        XCTAssertEqual(store.openKnot(on: today).phase, .tied)
        XCTAssertNil(store.openKnot(on: today).fileName)
        let peeledKnot = await store.peel()
        XCTAssertEqual(peeledKnot, .peeled)
        XCTAssertEqual(store.openKnot(on: today).phase, .loose)
    }

    func testStringOnLooseWritesDriftMark() async {
        let store = makeStore()
        let today = date(2026, 10, 3)
        XCTAssertEqual(store.string(fileName: "nope.m4a", media: .voice, on: today), .drift)
        XCTAssertEqual(store.document.driftMarks.count, 1)
        XCTAssertTrue(store.document.stringMarks.isEmpty)
        XCTAssertEqual(store.beadDensity(on: today), 0)
        let peeled = await store.peel()
        XCTAssertEqual(peeled, .peeled)
        XCTAssertTrue(store.document.driftMarks.isEmpty)
    }

    func testClothBinsSunday4Jan2026AsISOWeek1() {
        var unitedStates = calendar
        unitedStates.locale = Locale(identifier: "en_US")
        unitedStates.firstWeekday = 1
        unitedStates.minimumDaysInFirstWeek = 1
        let sunday = date(2026, 1, 4)
        let monday = date(2025, 12, 29)
        let nextMonday = date(2026, 1, 5)
        let sundayKnot = strung(on: sunday, calendar: unitedStates, caption: "Sunday")
        let mondayKnot = strung(on: monday, calendar: unitedStates, caption: "Monday")
        let later = strung(on: nextMonday, calendar: unitedStates, caption: "Later")
        let weekOne = KnotFold.weft([sundayKnot, mondayKnot], calendar: unitedStates)
        XCTAssertEqual(weekOne.count, 1)
        XCTAssertEqual(weekOne[0].isoYear, 2026)
        XCTAssertEqual(weekOne[0].isoWeek, 1)
        XCTAssertEqual(weekOne[0].strungCount, 2)
        let weekTwo = KnotFold.weft([later], calendar: unitedStates)
        XCTAssertEqual(weekTwo[0].isoYear, 2026)
        XCTAssertEqual(weekTwo[0].isoWeek, 2)
    }

    private func strung(on day: Date, calendar: Calendar, caption: String) -> Knot {
        Knot(
            id: UUID(),
            dayKey: DayKey.make(day, calendar: calendar),
            phase: .strung,
            caption: caption,
            fileName: "iso.jpg",
            media: .photo
        )
    }

    func testEmptyThreadFoldsToLoose() {
        let knots = KnotFold.knots(knotMarks: [], stringMarks: [])
        XCTAssertTrue(knots.isEmpty)
        let open = KnotFold.openKnot(knots, on: date(2026, 1, 1), calendar: calendar)
        XCTAssertEqual(open.phase, .loose)
    }

    func testSeedLeavesTodayTiedAndSkipsDevice() {
        let now = date(2026, 10, 3)
        let seeded = ThreadSeed.document(now: now, calendar: calendar)
        XCTAssertTrue(seeded.onboardingComplete)
        XCTAssertTrue(seeded.fullMarks.isEmpty)
        let today = seeded.knots.first { $0.dayKey == DayKey.make(now, calendar: calendar) }
        XCTAssertEqual(today?.phase, .tied)
        XCTAssertFalse(today?.caption.isEmpty ?? true)
        XCTAssertGreaterThan(seeded.knots.filter { $0.phase == .strung }.count, 2)
        let recalled = KnotFold.onThisDay(seeded.knots, today: now, calendar: calendar)
        XCTAssertFalse(recalled.isEmpty)
        let name = "hed.seed.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name) ?? UserDefaults.standard
        XCTAssertFalse(ThreadSeed.shouldApply(isSimulator: false, defaults: defaults))
        XCTAssertTrue(ThreadSeed.shouldApply(isSimulator: true, defaults: defaults))
        defaults.set(true, forKey: ThreadDocument.demoKey)
        XCTAssertFalse(ThreadSeed.shouldApply(isSimulator: true, defaults: defaults))
    }
}
