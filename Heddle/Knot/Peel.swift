import Foundation

/// Peel drops the newest StringMark, KnotMark, FullMark, or DriftMark.
/// Dropping a string reopens Tied. Dropping the caption knot returns Loose.
enum Peel {
    enum Which: Equatable, Sendable {
        case knot(UUID)
        case string(UUID, fileName: String)
        case drift(UUID)
        case full(UUID)
        case none
    }

    static func newest(
        knotMarks: [KnotMark],
        stringMarks: [StringMark],
        driftMarks: [DriftMark],
        fullMarks: [FullMark]
    ) -> Which {
        var best: (date: Date, which: Which)?
        for mark in knotMarks {
            best = later(best, date: mark.createdAt, which: .knot(mark.id))
        }
        for mark in stringMarks {
            best = later(best, date: mark.createdAt, which: .string(mark.id, fileName: mark.fileName))
        }
        for mark in driftMarks {
            best = later(best, date: mark.createdAt, which: .drift(mark.id))
        }
        for mark in fullMarks {
            best = later(best, date: mark.createdAt, which: .full(mark.id))
        }
        return best?.which ?? .none
    }

    private static func later(_ best: (date: Date, which: Which)?, date: Date, which: Which) -> (date: Date, which: Which) {
        guard let best else { return (date, which) }
        if date >= best.date { return (date, which) }
        return best
    }
}
