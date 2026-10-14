import Foundation

/// Attachment of one local photo or voice file onto a Tied knot.
/// The document stores the file name. Bytes live in Application Support.
struct StringMark: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var dayKey: Int
    var knotID: UUID
    var fileName: String
    var media: Knot.Media
    var createdAt: Date
}
