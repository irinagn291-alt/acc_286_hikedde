import AVFoundation
import CoreHaptics
import Foundation

/// Voice note for String. Recording stays in Application Support after attach.
@MainActor
final class VoiceCapture: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published private(set) var recording = false
    @Published var denied = false
    private var recorder: AVAudioRecorder?
    private var fileURL: URL?

    func toggle() async -> URL? {
        if recording {
            return await finish()
        }
        _ = await begin()
        return nil
    }

    func begin() async -> Bool {
        guard recording == false else { return true }
        let session = AVAudioSession.sharedInstance()
        let allowed = await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
        guard allowed else {
            denied = true
            return false
        }
        denied = false
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("hed-voice-\(UUID().uuidString).m4a")
            let settings: [String: Any] = [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVSampleRateKey: 44_100,
                AVNumberOfChannelsKey: 1
            ]
            let recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder.delegate = self
            recorder.record()
            self.recorder = recorder
            fileURL = url
            recording = true
            return true
        } catch {
            recording = false
            denied = false
            return false
        }
    }

    func finish() async -> URL? {
        guard recording else { return nil }
        recorder?.stop()
        recording = false
        let url = fileURL
        recorder = nil
        fileURL = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
        return url
    }
}

/// Plays a strung voice file. Progress is the fraction of the clip that has sounded.
@MainActor
final class VoicePlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published private(set) var playing = false
    @Published private(set) var progress: Double = 0
    @Published private(set) var duration: TimeInterval = 0
    private var player: AVAudioPlayer?
    private var ticker: Task<Void, Never>?
    private var loaded: URL?

    func toggle(fileName: String?) {
        guard let fileName else { return }
        let url = BeadFile.mediaURL(fileName: fileName)
        if playing, loaded == url {
            stop()
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            player.prepareToPlay()
            self.player = player
            loaded = url
            duration = player.duration
            progress = 0
            player.play()
            playing = true
            watch()
        } catch {
            stop()
        }
    }

    func stop() {
        ticker?.cancel()
        ticker = nil
        player?.stop()
        player = nil
        playing = false
        progress = 0
    }

    private func watch() {
        ticker?.cancel()
        ticker = Task { @MainActor [weak self] in
            while let self, self.playing, Task.isCancelled == false {
                if let player = self.player, player.duration > 0 {
                    self.progress = player.currentTime / player.duration
                    self.duration = player.duration
                }
                try? await Task.sleep(nanoseconds: 120_000_000)
            }
        }
    }

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.playing = false
            self.progress = flag ? 1 : 0
            self.ticker?.cancel()
        }
    }
}

/// Core Haptics for Tie, String, Peel, and a refused string. Settings can mute it.
@MainActor
final class Tremble {
    static let shared = Tremble()
    static let defaultsKey = "hed.haptics"

    enum Kind {
        case tie
        case string
        case peel
        case refuse
    }

    private var engine: CHHapticEngine?

    static var enabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: defaultsKey) == nil { return true }
            return UserDefaults.standard.bool(forKey: defaultsKey)
        }
        set { UserDefaults.standard.set(newValue, forKey: defaultsKey) }
    }

    func play(_ kind: Kind) {
        guard Self.enabled, CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            if engine == nil {
                engine = try CHHapticEngine()
                try engine?.start()
            }
            let events = pattern(kind)
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            engine = nil
        }
    }

    private func pattern(_ kind: Kind) -> [CHHapticEvent] {
        switch kind {
        case .tie:
            return [event(intensity: 0.45, sharpness: 0.3, at: 0)]
        case .string:
            return [
                event(intensity: 0.35, sharpness: 0.2, at: 0),
                event(intensity: 0.7, sharpness: 0.6, at: 0.08)
            ]
        case .peel:
            return [event(intensity: 0.55, sharpness: 0.85, at: 0, duration: 0.12)]
        case .refuse:
            return [
                event(intensity: 0.4, sharpness: 0.9, at: 0),
                event(intensity: 0.4, sharpness: 0.9, at: 0.09)
            ]
        }
    }

    private func event(intensity: Float, sharpness: Float, at time: TimeInterval, duration: TimeInterval = 0.04) -> CHHapticEvent {
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
        return CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [intensity, sharpness],
            relativeTime: time,
            duration: duration
        )
    }
}
