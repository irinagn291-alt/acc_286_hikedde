import Foundation

/// String attempted while the day is still Loose. Leaves every bead unstrung.
struct DriftMark: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var dayKey: Int
    var createdAt: Date
}
