import Foundation

/// A second Tie on a day that already has a knot. Adds no bead until Peel.
struct FullMark: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var dayKey: Int
    var createdAt: Date
}
