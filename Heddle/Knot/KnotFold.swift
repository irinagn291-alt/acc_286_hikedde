import Foundation

/// The thread is an ordered fold over Knots. Marks are the only stored
/// events. Density, on-this-day, and cloth weft are computed from the fold.
enum KnotFold {
    /// Rebuilds beads from marks. An empty mark list folds to no beads,
    /// which the hub reads as Loose.
    static func knots(
        knotMarks: [KnotMark],
        stringMarks: [StringMark]
    ) -> [Knot] {
        var built: [UUID: Knot] = [:]
        let captions = knotMarks.sorted { $0.createdAt < $1.createdAt }
        for mark in captions {
            let already = built.values.contains { $0.dayKey == mark.dayKey }
            if already {
                continue
            }
            built[mark.id] = Knot(
                id: mark.id,
                dayKey: mark.dayKey,
                phase: .tied,
                caption: mark.caption,
                fileName: nil,
                media: nil
            )
        }
        let strings = stringMarks.sorted { $0.createdAt < $1.createdAt }
        for mark in strings {
            guard var knot = built[mark.knotID], knot.phase == .tied else {
                continue
            }
            knot.phase = .strung
            knot.fileName = mark.fileName
            knot.media = mark.media
            built[mark.knotID] = knot
        }
        return built.values.sorted { lhs, rhs in
            if lhs.dayKey == rhs.dayKey { return lhs.id.uuidString < rhs.id.uuidString }
            return lhs.dayKey < rhs.dayKey
        }
    }

    /// Bead density for a day key: how many knots sit on that day.
    static func beadDensity(_ knots: [Knot], dayKey: Int) -> Int {
        knots.reduce(0) { count, knot in
            knot.dayKey == dayKey && knot.phase != .loose ? count + 1 : count
        }
    }

    /// On-this-day keeps Strung knots that share month and day in earlier years.
    static func onThisDay(_ knots: [Knot], today: Date, calendar: Calendar = .current) -> [Knot] {
        let key = DayKey.make(today, calendar: calendar)
        let monthDay = DayKey.monthDay(key)
        let year = DayKey.year(key)
        return knots.filter { knot in
            knot.phase == .strung
                && DayKey.monthDay(knot.dayKey) == monthDay
                && DayKey.year(knot.dayKey) < year
        }
    }

    /// Cloth density: Strung count per ISO week. Derived, never stored.
    /// ISO weeks start Monday. Week 1 contains the first Thursday.
    /// The passed calendar supplies the time zone only. Its locale week
    /// fields are not the cloth bins.
    static func weft(_ knots: [Knot], calendar: Calendar = .current) -> [WeftRow] {
        let iso = isoWeekCalendar(matching: calendar)
        var counts: [String: (year: Int, week: Int, count: Int)] = [:]
        for knot in knots where knot.phase == .strung {
            guard let date = date(for: knot.dayKey, calendar: calendar) else { continue }
            let parts = iso.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
            let year = parts.yearForWeekOfYear ?? 0
            let week = parts.weekOfYear ?? 0
            let id = "\(year)-\(week)"
            var row = counts[id] ?? (year, week, 0)
            row.count += 1
            counts[id] = row
        }
        return counts.values
            .map { WeftRow(isoYear: $0.year, isoWeek: $0.week, strungCount: $0.count) }
            .sorted { lhs, rhs in
                if lhs.isoYear == rhs.isoYear { return lhs.isoWeek < rhs.isoWeek }
                return lhs.isoYear < rhs.isoYear
            }
    }

    /// Strung knots that fall in one ISO week. Used by the cloth loom.
    static func knots(inWeek year: Int, week: Int, knots: [Knot], calendar: Calendar = .current) -> [Knot] {
        let iso = isoWeekCalendar(matching: calendar)
        return knots.filter { knot in
            guard knot.phase == .strung, let date = date(for: knot.dayKey, calendar: calendar) else { return false }
            let parts = iso.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
            return parts.yearForWeekOfYear == year && parts.weekOfYear == week
        }
    }

    static func openKnot(_ knots: [Knot], on date: Date, calendar: Calendar = .current) -> Knot {
        let key = DayKey.make(date, calendar: calendar)
        if let knot = knots.first(where: { $0.dayKey == key }) {
            return knot
        }
        return Knot.loose(dayKey: key)
    }

    /// Monday-start week whose first week holds the first Thursday.
    private static func isoWeekCalendar(matching calendar: Calendar) -> Calendar {
        var iso = Calendar(identifier: .iso8601)
        iso.timeZone = calendar.timeZone
        iso.firstWeekday = 2
        iso.minimumDaysInFirstWeek = 4
        return iso
    }

    private static func date(for dayKey: Int, calendar: Calendar) -> Date? {
        var parts = DateComponents()
        parts.year = DayKey.year(dayKey)
        parts.month = (dayKey / 100) % 100
        parts.day = dayKey % 100
        return calendar.date(from: parts)
    }
}
