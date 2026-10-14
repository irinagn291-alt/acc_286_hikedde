import Foundation

/// Settings seam for destructive storage. Reset deletes the document and media files.
@MainActor
final class Settings {
    private let store: ThreadStore

    init(store: ThreadStore) {
        self.store = store
    }

    func resetAllData() async {
        await store.eraseForReset()
    }

    var recoveryNote: String? { store.recoveryNote }
}
