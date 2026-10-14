import UIKit

/// Reads a strung file from Application Support. Views never touch UserDefaults.
enum BeadFile {
    static func mediaURL(fileName: String) -> URL {
        ThreadDisk.applicationSupport()
            .appendingPathComponent("media", isDirectory: true)
            .appendingPathComponent(fileName)
    }

    static func loadImageData(fileName: String?) async -> Data? {
        guard let fileName else { return nil }
        let url = mediaURL(fileName: fileName)
        return await Task.detached(priority: .userInitiated) {
            try? Data(contentsOf: url)
        }.value
    }

    /// Synchronous read so a review frame shows the strung file on the first paint.
    /// A quiet photo still counts. Callers draw a bead only when the file is not an image.
    static func loadImage(fileName: String?) -> UIImage? {
        guard let fileName else { return nil }
        let url = mediaURL(fileName: fileName)
        guard let data = try? Data(contentsOf: url), let image = UIImage(data: data) else { return nil }
        return image
    }
}
