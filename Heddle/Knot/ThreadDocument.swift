import Foundation

/// One Codable thread document. Schema 1 is the only UserDefaults record
/// under `hed.thread.v1`. Weft and on-this-day are not fields.
struct ThreadDocument: Codable, Equatable, Sendable {
    static let schema = 1
    static let defaultsKey = "hed.thread.v1"
    static let demoKey = "hed.demo.v1"

    var schemaVersion: Int
    var knots: [Knot]
    var knotMarks: [KnotMark]
    var stringMarks: [StringMark]
    var driftMarks: [DriftMark]
    var fullMarks: [FullMark]
    var onboardingComplete: Bool

    static let loose = ThreadDocument(
        schemaVersion: schema,
        knots: [],
        knotMarks: [],
        stringMarks: [],
        driftMarks: [],
        fullMarks: [],
        onboardingComplete: false
    )

    enum DecodeFailure: Error {
        case unknownSchema(Int)
        case malformed
    }

    func encoded() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(self)
    }

    static func decode(_ data: Data) -> Result<ThreadDocument, DecodeFailure> {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        do {
            let document = try decoder.decode(ThreadDocument.self, from: data)
            switch document.schemaVersion {
            case schema:
                var folded = document
                folded.knots = KnotFold.knots(
                    knotMarks: document.knotMarks,
                    stringMarks: document.stringMarks
                )
                return .success(folded)
            default:
                return .failure(.unknownSchema(document.schemaVersion))
            }
        } catch {
            return .failure(.malformed)
        }
    }
}
