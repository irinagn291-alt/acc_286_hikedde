import PhotosUI
import SwiftUI
import UIKit

/// Home is the vertical thread. Tie and String fuse here. Other rooms are sheets.
struct HubView: View {
    @ObservedObject var session: HubSession
    @StateObject private var voice = VoiceCapture()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamic
    @State private var caption = ""
    @State private var photoItem: PhotosPickerItem?
    @State private var showPhotos = false
    @State private var showStringChoices = false
    @FocusState private var captionFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            if session.knots.isEmpty {
                LoosePage(caption: $caption) {
                    commitTie()
                }
            } else {
                ScrollView {
                    ThreadLayout {
                        OpenBeadView(knot: session.openKnot)
                            .overlay(alignment: .bottom) {
                                if voice.recording {
                                    recordingBanner
                                }
                            }
                            .overlay(alignment: .topTrailing) {
                                if session.celebrate, UIImage(named: "hed_SuccessMark") != nil {
                                    Image("hed_SuccessMark")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: BeadChrome.field, height: BeadChrome.field)
                                        .padding(BeadChrome.stack)
                                        .transition(.opacity)
                                        .accessibilityHidden(true)
                                }
                            }
                        ForEach(pastKnots) { knot in
                            Button {
                                session.cover = .thread(knotID: knot.id)
                            } label: {
                                BeadView(knot: knot)
                            }
                            .buttonStyle(BeadPressStyle())
                            .contentShape(RoundedRectangle(cornerRadius: BeadChrome.card, style: .continuous))
                        }
                    }
                    .padding(.horizontal, BeadChrome.pad)
                    .padding(.bottom, BeadChrome.pad)
                    .background(alignment: .leading) {
                        Rectangle()
                            .fill(DesignTokens.ink)
                            .frame(width: 4)
                            .padding(.leading, BeadChrome.pad + 54)
                            .accessibilityHidden(true)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .safeAreaInset(edge: .bottom) {
            if session.knots.isEmpty == false {
                verbs
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(DesignTokens.bg)
        .onAppear { session.applyCover() }
        .onChange(of: session.stringArmed) { _, armed in
            guard armed else { return }
            session.stringArmed = false
            showStringChoices = true
        }
        .sheet(item: $session.cover) { cover in
            coverBody(cover)
                .presentationCornerRadius(BeadChrome.card)
        }
        .confirmationDialog("String", isPresented: $showStringChoices, titleVisibility: .visible) {
            Button("Photo") { showPhotos = true }
            Button(voice.recording ? "Stop" : "Voice") {
                Task { await commitVoice() }
            }
            Button("Close", role: .cancel) {}
        }
        .photosPicker(isPresented: $showPhotos, selection: $photoItem, matching: .images)
        .onChange(of: photoItem) { _, item in
            guard let item else { return }
            Task { await commitPhoto(item) }
        }
        .alert("Microphone is off", isPresented: $voice.denied) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Close", role: .cancel) {}
        } message: {
            Text("Voice notes need the microphone. Open Settings to turn it on.")
        }
    }

    private var pastKnots: [Knot] {
        session.knots
            .filter { $0.id != session.openKnot.id && $0.phase != .loose }
            .sorted { $0.dayKey > $1.dayKey }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: BeadChrome.tight) {
            Text(jobTitle)
                .font(BeadChrome.display(dynamic: dynamic))
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.6)
            Text(jobLine)
                .font(BeadChrome.body)
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            HStack(alignment: .firstTextBaseline, spacing: BeadChrome.tight) {
                Text(BeadChrome.count(strungCount))
                    .font(BeadChrome.headline)
                    .foregroundStyle(DesignTokens.accent)
                    .monospacedDigit()
                Text("strung on the thread")
                    .font(BeadChrome.body)
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .accessibilityElement(children: .combine)
            navRow
            if let notice = session.notice ?? session.recovery {
                Text(notice)
                    .font(BeadChrome.callout)
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, BeadChrome.pad)
        .padding(.top, BeadChrome.stack)
        .padding(.bottom, BeadChrome.tight)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var navRow: some View {
        HStack(spacing: BeadChrome.tight) {
            iconButton("On this day", symbol: "calendar") { session.cover = .onThisDay }
            iconButton("Weeks", symbol: "square.grid.3x3") { session.cover = .cloth }
            iconButton("Gallery", symbol: "photo.on.rectangle") { session.cover = .gallery }
            iconButton("Settings", symbol: "gearshape") { session.cover = .settings }
        }
    }

    private var strungCount: Int {
        session.knots.filter { $0.phase == .strung }.count
    }

    private var jobTitle: String {
        switch session.openKnot.phase {
        case .tied: return "String today's knot"
        case .strung: return "Today is strung"
        case .loose: return "Tie the knot"
        }
    }

    private var jobLine: String {
        switch session.openKnot.phase {
        case .tied: return "Add a photo or a voice note."
        case .strung: return "Peel to tie again."
        case .loose: return "Write a caption, then tie today."
        }
    }

    private var tieLive: Bool { session.openKnot.phase == .loose }
    private var stringLive: Bool { session.openKnot.phase == .tied }

    private var verbs: some View {
        VStack(alignment: .leading, spacing: BeadChrome.stack) {
            if stringLive == false {
                TextField("Caption", text: $caption)
                    .font(BeadChrome.body)
                    .foregroundStyle(DesignTokens.ink)
                    .focused($captionFocused)
                    .padding(BeadChrome.stack)
                    .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: BeadChrome.chip, style: .continuous))
                    .thickFrame(chip: true)
                    .submitLabel(.done)
                    .onSubmit { captionFocused = false }
            }
            if stringLive {
                stringButton
                tieButton
            } else {
                tieButton
                stringButton
            }
            Button("Peel") {
                Task {
                    await session.peel()
                    Tremble.shared.play(.peel)
                }
            }
            .buttonStyle(CommitButtonStyle(kind: .quiet))
            .disabled(session.working)
        }
        .padding(BeadChrome.pad)
        .background(DesignTokens.bg)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Close") { captionFocused = false }
                    .accessibilityLabel("Close")
            }
        }
    }

    private var tieButton: some View {
        Button("Tie") { commitTie() }
            .buttonStyle(CommitButtonStyle(kind: tieLive ? .commit : .quiet))
            .disabled(session.working)
    }

    private var stringButton: some View {
        Button(voice.recording ? "Stop & String" : "String") {
            if voice.recording {
                Task { await commitVoice() }
            } else {
                showStringChoices = true
            }
        }
        .buttonStyle(CommitButtonStyle(kind: stringLive || voice.recording ? .commit : .quiet, loading: session.working))
        .disabled(session.working)
    }

    private var recordingBanner: some View {
        HStack(spacing: BeadChrome.tight) {
            Circle()
                .fill(DesignTokens.drift)
                .frame(width: 12, height: 12)
            Text("Recording the voice note")
                .font(BeadChrome.callout)
                .foregroundStyle(DesignTokens.ink)
        }
        .padding(BeadChrome.stack)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignTokens.bg.opacity(0.92))
        .accessibilityLabel("Recording the voice note")
    }

    private func iconButton(_ title: String, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: BeadChrome.tight) {
                Image(systemName: symbol)
                    .font(BeadChrome.callout)
                Text(title)
                    .font(BeadChrome.caption)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(DesignTokens.ink)
            .frame(minWidth: 44, minHeight: 44)
            .padding(.horizontal, BeadChrome.tight)
            .contentShape(Rectangle())
        }
        .buttonStyle(BeadPressStyle())
        .accessibilityLabel(title)
    }

    @ViewBuilder
    private func coverBody(_ cover: HubCover) -> some View {
        switch cover {
        case .gallery:
            GalleryView(session: session)
        case .cloth:
            ClothView(session: session)
        case .thread(let knotID):
            ThreadView(session: session, knotID: knotID)
        case .onThisDay:
            OnThisDayView(session: session)
        case .settings:
            SettingsView(session: session)
        }
    }

    private func commitTie() {
        let wrote = session.tie(caption: caption.isEmpty ? session.openKnot.caption : caption)
        if wrote {
            caption = ""
            pulse(.tie)
        } else if session.notice != nil {
            Tremble.shared.play(.refuse)
        }
    }

    private func commitPhoto(_ item: PhotosPickerItem) async {
        session.working = true
        defer {
            session.working = false
            photoItem = nil
        }
        guard let data = try? await item.loadTransferable(type: Data.self) else {
            session.notice = "That photo could not be read."
            return
        }
        let name = "hed-\(UUID().uuidString).jpg"
        if await session.string(fileName: name, media: .photo, bytes: data) {
            pulse(.string)
        } else {
            Tremble.shared.play(.refuse)
        }
    }

    private func commitVoice() async {
        if voice.recording == false {
            _ = await voice.begin()
            return
        }
        guard let url = await voice.finish() else { return }
        let data = await Task.detached(priority: .userInitiated) {
            try? Data(contentsOf: url)
        }.value
        guard let data else {
            session.notice = "That voice note could not be read."
            return
        }
        let name = "hed-\(UUID().uuidString).m4a"
        if await session.string(fileName: name, media: .voice, bytes: data) {
            pulse(.string)
        } else {
            Tremble.shared.play(.refuse)
        }
    }

    private func pulse(_ kind: Tremble.Kind) {
        session.notice = "Saved."
        Tremble.shared.play(kind)
        withAnimation(BeadChrome.motion(reduceMotion)) {
            session.celebrate = true
        }
        Task {
            try? await Task.sleep(nanoseconds: 900_000_000)
            await MainActor.run {
                withAnimation(BeadChrome.ease) {
                    session.celebrate = false
                    if session.notice == "Saved." {
                        session.notice = nil
                    }
                }
            }
        }
    }
}
