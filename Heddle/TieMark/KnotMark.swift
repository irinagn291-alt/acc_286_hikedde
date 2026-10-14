import Foundation

/// Caption-only mark. Tie writes this on a Loose day and folds that bead to Tied.
struct KnotMark: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var dayKey: Int
    var caption: String
    var createdAt: Date
}
