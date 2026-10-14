import Foundation

/// File projection of the thread. Document JSON and media bytes are written
/// atomically off the main actor. User data stays in Application Support.
actor ThreadDisk {
    let root: URL
    private let fileManager: FileManager

    init(root: URL, fileManager: FileManager = .default) {
        self.root = root
        self.fileManager = fileManager
    }

    static func applicationSupport() -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        return (base ?? URL(fileURLWithPath: NSTemporaryDirectory())).appendingPathComponent("Сhikedde", isDirectory: true)
    }

    func writeDocument(_ data: Data) throws {
        try Task.checkCancellation()
        try fileManager.createDirectory(at: root, withIntermediateDirectories: true)
        let current = documentURL
        if fileManager.fileExists(atPath: current.path) {
            let existing = try Data(contentsOf: current)
            try existing.write(to: backupURL, options: .atomic)
        }
        try data.write(to: current, options: .atomic)
    }

    func readDocument() -> Data? {
        try? Data(contentsOf: documentURL)
    }

    func readBackup() -> Data? {
        try? Data(contentsOf: backupURL)
    }

    func writeMedia(_ data: Data, fileName: String) throws {
        try Task.checkCancellation()
        let folder = mediaURL
        try fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
        let destination = folder.appendingPathComponent(fileName)
        try data.write(to: destination, options: .atomic)
    }

    func deleteMedia(fileName: String) throws {
        let url = mediaURL.appendingPathComponent(fileName)
        guard fileManager.fileExists(atPath: url.path) else { return }
        try fileManager.removeItem(at: url)
    }

    /// Replaces the document and its backup, then removes media files.
    func reset(with data: Data) throws {
        try Task.checkCancellation()
        try fileManager.createDirectory(at: root, withIntermediateDirectories: true)
        try data.write(to: documentURL, options: .atomic)
        try data.write(to: backupURL, options: .atomic)
        if fileManager.fileExists(atPath: mediaURL.path) {
            try fileManager.removeItem(at: mediaURL)
        }
    }

    private var documentURL: URL {
        root.appendingPathComponent("thread.json")
    }

    private var backupURL: URL {
        root.appendingPathComponent("thread.json.backup")
    }

    private var mediaURL: URL {
        root.appendingPathComponent("media", isDirectory: true)
    }
}
