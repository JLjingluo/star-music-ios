import SwiftUI
import UniformTypeIdentifiers

@main struct StarMusicApp: App {
    @StateObject private var store = ProjectStore()
    @StateObject private var audio = AudioController()
    @AppStorage("appearance") private var appearance = "dark"
    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(store).environmentObject(audio)
                .preferredColorScheme(appearance == "system" ? nil : appearance == "dark" ? .dark : .light)
                .tint(Palette.gold)
        }
    }
}

enum Palette {
    static let gold = Color(red: 0.90, green: 0.77, blue: 0.43)
    static let ink = Color(red: 0.13, green: 0.14, blue: 0.12)
    static let paper = Color(red: 0.93, green: 0.89, blue: 0.78)
    static func background(_ scheme: ColorScheme) -> Color { scheme == .dark ? Color(red: 0.065, green: 0.069, blue: 0.061) : Color(red: 0.965, green: 0.957, blue: 0.936) }
    static func card(_ scheme: ColorScheme) -> Color { scheme == .dark ? Color(red: 0.105, green: 0.112, blue: 0.098) : Color(red: 1, green: 0.997, blue: 0.977) }
}

struct CardStyle: ViewModifier {
    @Environment(\.colorScheme) var scheme
    var radius: CGFloat = 20
    func body(content: Content) -> some View { content.padding(18).background(Palette.card(scheme), in: RoundedRectangle(cornerRadius: radius)).overlay(RoundedRectangle(cornerRadius: radius).stroke(LinearGradient(colors: [.white.opacity(scheme == .dark ? 0.09 : 0.6), .primary.opacity(0.035)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 0.75)) }
}
extension View { func musicCard(radius: CGFloat = 20) -> some View { modifier(CardStyle(radius: radius)) } }

struct GoldButton: View {
    var title: String; var symbol: String = "plus"; var action: () -> Void
    var body: some View { Button(action: action) { Label(title, systemImage: symbol).font(.subheadline.weight(.semibold)).frame(minHeight: 44).padding(.horizontal, 18).background(Palette.gold, in: RoundedRectangle(cornerRadius: 13)).foregroundStyle(Palette.ink) }.buttonStyle(MusicPressStyle()) }
}
struct ShareSheet: UIViewControllerRepresentable {
    var url: URL
    func makeUIViewController(context: Context) -> UIActivityViewController { UIActivityViewController(activityItems: [url], applicationActivities: nil) }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
struct ShareItem: Identifiable { let id = UUID(); let url: URL }
struct ProjectRoute: Identifiable { let id = UUID(); let project: MusicProject; var record = false }

struct RootView: View {
    @EnvironmentObject var store: ProjectStore
    @EnvironmentObject var audio: AudioController
    @Environment(\.scenePhase) private var scenePhase
    @State private var tab = 0
    @State private var route: ProjectRoute?
    @State private var importer = false
    @State private var importing = false
    @State private var help = false
    var body: some View {
        TabView(selection: $tab) {
            NavigationStack { CreationHome(onStart: create, onOpen: open, onImport: { importer = true }, onHelp: { help = true }) }.tabItem { Label("创作", systemImage: "plus.circle") }.tag(0)
            NavigationStack { CommunityView(onRemix: open) }.tabItem { Label("社区", systemImage: "music.note.house") }.tag(1)
            NavigationStack { MessagesView() }.tabItem { Label("消息", systemImage: "bubble.left.and.bubble.right") }.tag(2)
            NavigationStack { ProfileView(onOpen: open) }.tabItem { Label("我的", systemImage: "person.crop.circle") }.tag(3)
        }
        .toolbar(.hidden, for: .tabBar)
        .safeAreaInset(edge: .bottom, spacing: 0) { if route == nil { MusicTabBar(selection: $tab) } }
        .onChange(of: tab) { _, _ in audio.stopPlayback() }
        .fullScreenCover(item: $route) { route in
            if route.record { RecordingView(project: route.project, onEdit: { p in self.route = nil; DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { self.route = ProjectRoute(project: p) } }) }
            else { EditorView(project: route.project, store: store) }
        }
        .sheet(isPresented: $help) { HelpView() }
        .fileImporter(isPresented: $importer, allowedContentTypes: [.audio, .midi, .json, .data], allowsMultipleSelection: false) { result in
            switch result { case .success(let urls): if let url = urls.first { Task { await importMusic(url) } }; case .failure(let error): store.error = error.localizedDescription }
        }
        .overlay { if importing { ZStack { Color.black.opacity(0.55).ignoresSafeArea(); ProgressView("正在导入文件…").padding(30).background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20)) } } }
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
            let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0; guard size <= 32 * 1024 * 1024 else { throw MusicError.tooLarge }
            let ext = url.pathExtension.lowercased(); var p: MusicProject
            if ext == "starmusic" || ext == "json" { p = try store.importPackage(Data(contentsOf: url)) }
            else if ext == "mid" || ext == "midi" { p = try MIDI.parse(Data(contentsOf: url)); p.name = url.deletingPathExtension().lastPathComponent; try store.save(p) }
            else {
                let name = UUID().uuidString + "." + ext, target = store.recordingDirectory.appendingPathComponent(name)
                try FileManager.default.copyItem(at: url, to: target)
                p = MusicProject(); p.name = url.deletingPathExtension().lastPathComponent; p.recordingFile = name; p.freeRhythm = true
                try store.save(p)
                let result = try await Task.detached { try AudioController.samples(from: target) }.value
                p.recordingSeconds = Double(result.samples.count) / result.sampleRate
                do { p.tracks[0].notes = try await Task.detached { try PitchAnalyzer.analyze(result.samples, sampleRate: result.sampleRate, bpm: 96, free: true) }.value }
                catch { store.error = "原始音频已保存，可在编辑器中重试分析或手动写谱。" }
                try store.save(p)
            }
            open(p)
        } catch { store.error = error.localizedDescription }
    }
}
