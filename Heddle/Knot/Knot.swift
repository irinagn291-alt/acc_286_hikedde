import Foundation

/// A bead on the vertical thread. The fold is Loose, Tied, or Strung.
/// Loose is the absence of a stored bead. Tied holds a caption. Strung
/// holds that caption plus one local photo or voice file name.
struct Knot: Codable, Equatable, Sendable, Identifiable {
    enum Phase: String, Codable, Sendable {
        case loose
        case tied
        case strung
    }

    enum Media: String, Codable, Sendable {
        case photo
        case voice
    }

    var id: UUID
    var dayKey: Int
    var phase: Phase
    var caption: String
    var fileName: String?
    var media: Media?

    static func loose(dayKey: Int) -> Knot {
        Knot(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000000") ?? UUID(),
            dayKey: dayKey,
            phase: .loose,
            caption: "",
            fileName: nil,
            media: nil
        )
    }
}
