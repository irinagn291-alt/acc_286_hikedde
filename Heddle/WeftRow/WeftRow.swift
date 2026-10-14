import Foundation

/// Derived cloth row. Strung count for one ISO week. Never stored.
struct WeftRow: Equatable, Sendable, Identifiable {
    var isoYear: Int
    var isoWeek: Int
    var strungCount: Int

    var id: String { "\(isoYear)-\(isoWeek)" }
}
