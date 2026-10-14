import Foundation

/// Day identity for the thread. Keys are `YYYYMMDD` integers taken from
/// `Calendar.startOfDay`, so bead density and on-this-day share one clock.
enum DayKey {
    static func make(_ date: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: date)
        let parts = calendar.dateComponents([.year, .month, .day], from: start)
        let year = parts.year ?? 0
        let month = parts.month ?? 0
        let day = parts.day ?? 0
        return year * 10_000 + month * 100 + day
    }

    static func monthDay(_ key: Int) -> Int {
        key % 10_000
    }

    static func year(_ key: Int) -> Int {
        key / 10_000
    }
}
