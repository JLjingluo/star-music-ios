import SwiftUI
import UniformTypeIdentifiers

@main struct StarMusicApp: App {
    @StateObject private var store = ProjectStore()
    @StateObject private var audio = AudioController()
    @AppStorage("appearance") private var appearance = "dark"
    init() {
        #if DEBUG
        // A dedicated reset flag avoids pinning AppStorage in NSArgumentDomain.
        if ProcessInfo.processInfo.arguments.contains("--ui-test-standard-mode") { UserDefaults.standard.set("standard", forKey: "studioMode") }
        #endif
    }
    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(store).environmentObject(audio)
                .preferredColorScheme(appearance == "system" ? nil : appearance == "dark" ? .dark : .light)
                .tint(Palette.accent)
        }
    }
}

enum Palette {
    static let gold = Color(red: 0.90, green: 0.77, blue: 0.43)
    static let accent = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor(red: 0.90, green: 0.77, blue: 0.43, alpha: 1) : UIColor(red: 0.47, green: 0.34, blue: 0.06, alpha: 1)
    })
    static let onAccent = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor(red: 0.13, green: 0.14, blue: 0.12, alpha: 1) : .white
    })
    static let ink = Color(red: 0.13, green: 0.14, blue: 0.12)
    static let paper = Color(red: 0.93, green: 0.89, blue: 0.78)
    static func background(_ scheme: ColorScheme) -> Color { Color(uiColor: .systemGroupedBackground) }
    static func card(_ scheme: ColorScheme) -> Color { Color(uiColor: .secondarySystemGroupedBackground) }
}

// Native grouping is reserved for music canvases and their inspectors.
struct MusicGroupStyle: ViewModifier {
    var radius: CGFloat
    func body(content: Content) -> some View {
        content.frame(maxWidth: .infinity, alignment: .leading).padding(16)
            .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}
struct MusicActionStyle: ViewModifier {
    var prominent = false
    @ViewBuilder func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            if prominent { content.buttonStyle(.glassProminent).foregroundStyle(Palette.onAccent) }
            else { content.buttonStyle(.glass) }
        } else {
            if prominent { content.buttonStyle(.borderedProminent).foregroundStyle(Palette.onAccent) }
            else { content.buttonStyle(.bordered) }
        }
    }
}
struct MusicGlassGroup<Content: View>: View {
    @ViewBuilder var content: () -> Content
    @ViewBuilder var body: some View {
        if #available(iOS 26.0, *) { GlassEffectContainer(spacing: 12, content: content) }
        else { content() }
    }
}
extension View {
    func musicCard(radius: CGFloat = 24) -> some View { modifier(MusicGroupStyle(radius: radius)) }
    func musicAction(prominent: Bool = false) -> some View { modifier(MusicActionStyle(prominent: prominent)) }
}

struct GoldButton: View {
    var title: String; var symbol: String = "plus"; var action: () -> Void
    var body: some View { Button(action: action) { Label(title, systemImage: symbol).frame(minHeight: 44) }.musicAction(prominent: true) }
}
struct ShareSheet: UIViewControllerRepresentable {
    var url: URL
    func makeUIViewController(context: Context) -> UIActivityViewController { UIActivityViewController(activityItems: [url], applicationActivities: nil) }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
struct ShareItem: Identifiable { let id = UUID(); let url: URL }
struct ProjectRoute: Identifiable, Hashable {
    let id = UUID(); let project: MusicProject; var record = false
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct RootView: View {
    @EnvironmentObject var store: ProjectStore
    @EnvironmentObject var audio: AudioController
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("hapticsEnabled") private var haptics = true
    @State private var tab = 0
    @State private var route: ProjectRoute?
    @State private var communityRoute: ProjectRoute?
    @State private var profileRoute: ProjectRoute?
    @State private var importer = false
    @State private var importing = false
    @State private var help = false
    var body: some View {
        TabView(selection: $tab) {
            NavigationStack {
                CreationHome(onStart: create, onOpen: open, onImport: { importer = true }, onHelp: { help = true })
                    .navigationDestination(item: $route) { ProjectWorkspace(route: $0).toolbar(.hidden, for: .tabBar) }
            }.tabItem { Label("创作", systemImage: "music.note") }.tag(0)
            NavigationStack {
                CommunityView(onRemix: { audio.stopPlayback(); communityRoute = ProjectRoute(project: $0) })
                    .navigationDestination(item: $communityRoute) { ProjectWorkspace(route: $0).toolbar(.hidden, for: .tabBar) }
            }.tabItem { Label("社区", systemImage: "person.2") }.tag(1)
            NavigationStack { MessagesView() }.tabItem { Label("消息", systemImage: "bubble.left.and.bubble.right") }.tag(2)
            NavigationStack {
                ProfileView(onOpen: { audio.stopPlayback(); profileRoute = ProjectRoute(project: $0) })
                    .navigationDestination(item: $profileRoute) { ProjectWorkspace(route: $0).toolbar(.hidden, for: .tabBar) }
            }.tabItem { Label("我的", systemImage: "person.crop.circle") }.tag(3)
        }
        .sensoryFeedback(.selection, trigger: tab) { _, _ in haptics }
        .onChange(of: tab) { _, _ in audio.stopPlayback() }
        .sheet(isPresented: $help) { HelpView() }
        .fileImporter(isPresented: $importer, allowedContentTypes: [.audio, .midi, .json, .data], allowsMultipleSelection: false) { result in
            switch result { case .success(let urls): if let url = urls.first { Task { await importMusic(url) } }; case .failure(let error): store.error = error.localizedDescription }
        }
        .sheet(isPresented: $importing) { ProcessingView(stage: "正在导入文件…") }
        .alert("操作未完成", isPresented: Binding(get: { store.error != nil }, set: { if !$0 { store.error = nil } })) { Button("知道了", role: .cancel) { store.error = nil } } message: { Text(store.error ?? "") }
        .onChange(of: scenePhase) { _, phase in if phase != .active { audio.handleInterruption("应用进入后台，录音已暂停并保留，请主动继续。") } }
    }
    private func create(_ record: Bool) {
        var p = MusicProject(); if record { p.name = "哼唱灵感" }
        do { try store.save(p); audio.stopPlayback(); route = ProjectRoute(project: p, record: record) } catch { store.error = error.localizedDescription }
    }
    private func open(_ p: MusicProject) { audio.stopPlayback(); route = ProjectRoute(project: p) }
    private func importMusic(_ url: URL) async {
        importing = true; defer { importing = false }
        let access = url.startAccessingSecurityScopedResource(); defer { if access { url.stopAccessingSecurityScopedResource() } }
        do {
            let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0; guard size <= (url.pathExtension.lowercased() == "starmusic" || url.pathExtension.lowercased() == "json" ? 512 : 256) * 1024 * 1024 else { throw MusicError.tooLarge }
            let ext = url.pathExtension.lowercased(); var p: MusicProject
            if ext == "starmusic" || ext == "json" { p = try store.importPackage(Data(contentsOf: url)) }
            else if ext == "mid" || ext == "midi" { p = try MIDI.parse(Data(contentsOf: url)); p.name = MusicProject.projectName(url.deletingPathExtension().lastPathComponent); try store.save(p) }
            else {
                let prepared = try await AudioImport.prepare(url, directory: store.recordingDirectory)
                let name = prepared.name, target = prepared.url
                p = MusicProject(); p.name = MusicProject.projectName(url.deletingPathExtension().lastPathComponent)
                MusicEdits.attachOriginal(&p.tracks[0], file: name, duration: prepared.duration); p.freeRhythm = true; p.syncLegacyRecording()
                do { try store.save(p) } catch { open(p); throw error }
                do { let recognized = try await RecognitionService.analyze(url: target, bpm: p.bpm, free: true); p.tracks[0].notes = recognized.notes.map { var note = $0; note.sourceFile = name; return note }; p.tracks[0].useOriginalAudio = false; p.tracks[0].transcript = recognized.transcript; p.tracks[0].recognitionSource = RecognitionSettings.load().engine.title }
                catch { store.error = "原始音频已保存，可在编辑器中重试分析或手动写谱。" }
                try store.save(p)
            }
            open(p)
        } catch { store.error = error.localizedDescription }
    }
}

struct ProjectWorkspace: View {
    @EnvironmentObject private var store: ProjectStore
    @Environment(\.dismiss) private var dismiss
    var route: ProjectRoute
    @State private var editing: MusicProject?
    @State private var capturing = false
    @State private var captureStarted = false
    init(route: ProjectRoute) { self.route = route; _editing = State(initialValue: route.record ? nil : route.project) }
    var body: some View {
        Group {
            if let project = editing { EditorView(project: project, store: store) }
            else { ProgressView("准备录音…") }
        }
        .task { if editing == nil && !captureStarted { captureStarted = true; capturing = true } }
        .fullScreenCover(isPresented: $capturing, onDismiss: { if editing == nil { dismiss() } }) {
            RecordingView(project: route.project) { project in editing = project; capturing = false }
        }
    }
}

/// The system owns the modal, dimming, dismissal and accessibility containment.
struct ProcessingView: View {
    var stage: String
    var cancelTitle = "取消分析，保留原录音"
    var onCancel: (() -> Void)?
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                ProgressView().controlSize(.large)
                Text(stage).multilineTextAlignment(.center).accessibilityAddTraits(.updatesFrequently)
                if let onCancel { Button(cancelTitle, role: .cancel, action: onCancel).frame(minHeight: 44) }
            }.padding(24).frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationTitle("正在处理").navigationBarTitleDisplayMode(.inline)
        }.presentationDetents([.medium]).interactiveDismissDisabled()
    }
}
