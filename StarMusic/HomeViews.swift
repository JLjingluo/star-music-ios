import SwiftUI

struct CreationHome: View {
    @EnvironmentObject var store: ProjectStore
    var onStart: (Bool) -> Void
    var onOpen: (MusicProject) -> Void
    var onImport: () -> Void
    var onHelp: () -> Void
    @State private var chooser = false
    @State private var instruments = false
    @State private var pendingChoice: StartChoice?
    @AppStorage("studioMode") private var rawMode = StudioMode.standard.rawValue
    private enum StartChoice { case record, blank, file }
    private var drafts: [MusicProject] { Array(store.projects.filter { !$0.deleted }.prefix(3)) }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Label("哼出旋律，写成自己的歌", systemImage: "waveform")
                        .font(.title3.weight(.semibold)).foregroundStyle(.primary)
                    if rawMode != StudioMode.simple.rawValue {
                        Text("录下脑海里的旋律，整理成可以继续修改的音乐。").font(.subheadline).foregroundStyle(.secondary)
                    }
                    Button { pendingChoice = nil; chooser = true } label: {
                        Label("开始创作", systemImage: "plus").frame(maxWidth: .infinity, minHeight: 44)
                    }.buttonStyle(.borderedProminent).accessibilityIdentifier("home.start")
                }.padding(.vertical, 8)
                Button(action: onImport) { Label("导入音乐", systemImage: "square.and.arrow.down") }
                    .accessibilityIdentifier("home.import")
            }
            if rawMode != StudioMode.simple.rawValue {
                Section("创作工具") {
                    Button { onStart(false) } label: { Label("空白乐谱", systemImage: "music.note.list") }.accessibilityIdentifier("home.blank")
                    Button { instruments = true } label: { Label("乐器库", systemImage: "pianokeys") }.accessibilityIdentifier("home.instruments")
                }
            }
            Section {
                if drafts.isEmpty {
                    EmptyState(symbol: "music.note", title: "还没有草稿", subtitle: "开始创作后，旋律会自动保存在这里。")
                } else {
                    ForEach(drafts) { DraftRow(project: $0, onOpen: onOpen) }
                }
                NavigationLink { DraftsView(onOpen: onOpen) } label: { Label("全部草稿", systemImage: "folder") }.accessibilityIdentifier("home.drafts")
            } header: { Text("最近草稿") } footer: {
                Text(RecognitionSettings.load().engine == .cloud ? "主动使用你的模型时，所选录音会发送至你配置的接口。" : "草稿保存在这台设备上，离线也能继续创作。")
            }
        }.navigationTitle("Star Music")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button(action: onHelp) { Label("帮助", systemImage: "questionmark.circle") } } }
            .sheet(isPresented: $chooser, onDismiss: performChoice) { creationSheet }
            .sheet(isPresented: $instruments) { InstrumentSheet() }
    }
    private var creationSheet: some View {
        NavigationStack {
            List {
                StartOption(title: "哼唱录制", subtitle: "录下旋律，自动整理成乐谱", symbol: "mic") { choose(.record) }.accessibilityIdentifier("start.record")
                StartOption(title: "空白乐谱", subtitle: "从第一个声音开始写", symbol: "music.note.list") { choose(.blank) }.accessibilityIdentifier("start.blank")
                StartOption(title: "导入文件", subtitle: "已有音频、旋律文件或项目备份", symbol: "square.and.arrow.down") { choose(.file) }.accessibilityIdentifier("start.import")
            }.navigationTitle("开始创作").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button("取消", role: .cancel) { chooser = false } } }
        }.presentationDetents([.medium, .large]).presentationDragIndicator(.visible)
    }
    private func choose(_ choice: StartChoice) { pendingChoice = choice; chooser = false }
    private func performChoice() {
        guard let choice = pendingChoice else { return }; pendingChoice = nil
        switch choice { case .record: onStart(true); case .blank: onStart(false); case .file: onImport() }
    }
}

struct ToolCard: View {
    var title: String; var subtitle: String; var symbol: String; var action: () -> Void
    var body: some View {
        Button(action: action) {
            Label { VStack(alignment: .leading, spacing: 4) { Text(title); Text(subtitle).font(.caption).foregroundStyle(.secondary) } } icon: { Image(systemName: symbol) }
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        }.buttonStyle(.bordered)
    }
}
struct StartOption: View {
    var title: String; var subtitle: String; var symbol: String; var action: () -> Void
    var body: some View {
        Button(action: action) {
            Label { VStack(alignment: .leading, spacing: 5) { Text(title).foregroundStyle(.primary); Text(subtitle).font(.subheadline).foregroundStyle(.secondary) } } icon: { Image(systemName: symbol) }
                .frame(minHeight: 44, alignment: .leading)
        }
    }
}
struct EmptyState: View {
    var symbol: String; var title: String; var subtitle: String
    var body: some View { ContentUnavailableView(title, systemImage: symbol, description: Text(subtitle)) }
}

struct DraftRow: View {
    @EnvironmentObject var store: ProjectStore
    @EnvironmentObject var audio: AudioController
    let project: MusicProject
    var onOpen: (MusicProject) -> Void
    var compact = false
    @State private var rename = false
    @State private var name = ""
    @State private var move = false
    @State private var folder = ""
    @State private var share: ShareItem?
    @State private var confirmDelete = false
    var body: some View {
        let layout = compact ? AnyLayout(VStackLayout(alignment: .leading, spacing: 10)) : AnyLayout(HStackLayout(spacing: 8))
        layout {
            Button { if !project.deleted { onOpen(project) } } label: {
                HStack(spacing: 12) {
                    MiniScore(notes: project.tracks[0].notes).frame(width: 48, height: 54)
                    VStack(alignment: .leading, spacing: 5) {
                        Text(project.name).font(.body).foregroundStyle(.primary).lineLimit(2)
                        Text("\(musicTime(project.seconds)) · \(project.tracks.count) 条音轨" + (project.sample ? " · 示例" : "")).font(.caption).foregroundStyle(.secondary)
                        Text(project.updated, style: .relative).font(.caption2).foregroundStyle(.secondary)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }.frame(minHeight: 54)
            }.disabled(project.deleted).buttonStyle(.borderless)
            HStack(spacing: 0) {
                if project.deleted { Button("恢复") { store.update(project) { $0.deleted = false } }.frame(minHeight: 44) }
                else {
                    Button { Task { do { try await audio.play(project, recordingDirectory: store.recordingDirectory) } catch { store.error = error.localizedDescription } } } label: { PlaybackGlyph(playing: audio.playingID == project.id).frame(width: 44, height: 44) }.buttonStyle(.borderless).accessibilityLabel("试听 \(project.name)")
                }
                Menu {
                    if !project.deleted {
                        Button("重命名", systemImage: "pencil") { name = project.name; rename = true }
                        Button(project.favorite ? "取消收藏" : "收藏", systemImage: "star") { store.update(project) { $0.favorite.toggle() } }
                        Button("复制项目", systemImage: "doc.on.doc") { do { try store.duplicate(project) } catch { store.error = error.localizedDescription } }
                        Button("移动到文件夹", systemImage: "folder") { folder = project.folder; move = true }
                        Button("导出项目包", systemImage: "square.and.arrow.up") { do { share = ShareItem(url: try store.package(project)) } catch { store.error = error.localizedDescription } }
                        Button("移入最近删除", systemImage: "trash", role: .destructive) { confirmDelete = true }
                    } else { Button("恢复草稿", systemImage: "arrow.uturn.backward") { store.update(project) { $0.deleted = false } } }
                } label: { Label("更多操作", systemImage: "ellipsis").labelStyle(.iconOnly).frame(width: 44, height: 44) }.accessibilityLabel("草稿更多操作")
            }
        }.padding(.vertical, 4)
        .confirmationDialog("移入最近删除？", isPresented: $confirmDelete, titleVisibility: .visible) { Button("移入最近删除", role: .destructive) { audio.stopPlayback(); store.update(project) { $0.deleted = true } }; Button("取消", role: .cancel) {} } message: { Text("可以随时在最近删除中恢复这份草稿。") }
        .alert("重命名", isPresented: $rename) { TextField("名称", text: $name); Button("保存") { store.update(project) { $0.name = name.isEmpty ? "未命名的旋律" : String(name.prefix(60)) } }; Button("取消", role: .cancel) {} }
        .alert("移动到文件夹", isPresented: $move) { TextField("文件夹名称", text: $folder); Button("移动") { store.update(project) { $0.folder = folder.isEmpty ? "未分类" : String(folder.prefix(40)) } }; Button("取消", role: .cancel) {} }
        .sheet(item: $share) { ShareSheet(url: $0.url) }
    }
}

struct DraftsView: View {
    @EnvironmentObject var store: ProjectStore
    var onOpen: (MusicProject) -> Void
    @State private var search = ""
    @State private var deleted = false
    @State private var grid = false
    @State private var sort = "最近编辑"
    @State private var folder = "全部文件夹"
    @Environment(\.dynamicTypeSize) private var typeSize
    private var useGrid: Bool { grid && !typeSize.isAccessibilitySize }
    var filtered: [MusicProject] { store.projects.filter { $0.deleted == deleted && (search.isEmpty || $0.name.localizedCaseInsensitiveContains(search)) && (folder == "全部文件夹" || $0.folder == folder) }.sorted { a, b in sort == "名称" ? a.name < b.name : sort == "收藏优先" ? (a.favorite == b.favorite ? a.updated > b.updated : a.favorite) : a.updated > b.updated } }
    var body: some View {
        Group {
            if filtered.isEmpty { EmptyState(symbol: "folder", title: deleted ? "没有已删除的草稿" : "没有匹配的旋律", subtitle: "试试其他关键词，或更换文件夹。删除的草稿可以恢复。") }
            else if useGrid {
                ScrollView { LazyVGrid(columns: [GridItem(.adaptive(minimum: 250))], spacing: 16) { ForEach(filtered) { DraftRow(project: $0, onOpen: onOpen, compact: true).padding(12).background(.background, in: RoundedRectangle(cornerRadius: 12)) } }.padding() }
            } else { List(filtered) { DraftRow(project: $0, onOpen: onOpen) } }
        }.navigationTitle(deleted ? "最近删除" : "草稿箱").navigationBarTitleDisplayMode(.inline)
            .searchable(text: $search, placement: .navigationBarDrawer(displayMode: .always), prompt: "搜索草稿")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button { grid.toggle() } label: { Label(grid ? "切换为列表" : "切换为网格", systemImage: grid ? "list.bullet" : "square.grid.2x2") }.accessibilityIdentifier("drafts.layout")
                    Menu {
                        Picker("排序", selection: $sort) { ForEach(["最近编辑", "名称", "收藏优先"], id: \.self) { Text($0) } }
                        Picker("文件夹", selection: $folder) { Text("全部文件夹").tag("全部文件夹"); ForEach(Array(Set(store.projects.map(\.folder))).sorted(), id: \.self) { Text($0).tag($0) } }
                        Button(deleted ? "全部草稿" : "最近删除", systemImage: deleted ? "folder" : "trash") { deleted.toggle() }
                    } label: { Label("草稿选项", systemImage: "ellipsis") }.accessibilityIdentifier("drafts.options")
                }
            }
    }
}

enum DemoMusic {
    static let titles = ["晚风经过的地方", "在雨停之前", "一颗星的旅行"]
    static let authors = ["木与舟", "北岛来信", "Milo"]
    static let kinds = ["完整作品", "旋律片段", "创作过程"]
}
struct CommunityView: View {
    @EnvironmentObject var store: ProjectStore
    @EnvironmentObject var audio: AudioController
    var onRemix: (MusicProject) -> Void
    @State private var selected = "推荐"
    @State private var search = ""
    @State private var detail: Int?
    @State private var examples = (0..<3).map { MusicProject.example($0) }
    private var matches: [Int] { (0..<3).filter { search.isEmpty || (DemoMusic.titles[$0] + DemoMusic.authors[$0]).localizedCaseInsensitiveContains(search) } }
    var body: some View {
        List {
            Section {
                Picker("社区分类", selection: $selected) { Text("推荐").tag("推荐"); Text("关注").tag("关注") }.pickerStyle(.segmented)
            } footer: { Text("演示内容：作者与作品为示例，喜欢和收藏仅保存在此设备。") }
            if selected == "关注" { EmptyState(symbol: "person.2", title: "还没有关注动态", subtitle: "关注服务尚未接入，可以先浏览推荐中的演示作品。") }
            else if matches.isEmpty { ContentUnavailableView.search(text: search) }
            else {
                Section("演示作品") {
                    ForEach(matches, id: \.self) { i in
                        HStack(spacing: 12) {
                            Button { detail = i } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    MiniScore(notes: examples[i].tracks[0].notes).frame(height: 88)
                                    Text(DemoMusic.titles[i]).font(.headline).foregroundStyle(.primary)
                                    Text("\(DemoMusic.authors[i]) · \(DemoMusic.kinds[i]) · \(musicTime(examples[i].seconds))").font(.caption).foregroundStyle(.secondary)
                                }.padding(.vertical, 8)
                            }.buttonStyle(.borderless)
                            Button { Task { do { try await audio.play(examples[i]) } catch { store.error = error.localizedDescription } } } label: { PlaybackGlyph(playing: audio.playingID == examples[i].id).frame(width: 44, height: 44) }.buttonStyle(.borderless).accessibilityLabel("播放演示作品 \(DemoMusic.titles[i])")
                        }
                    }
                }
            }
        }.navigationTitle("社区").searchable(text: $search, prompt: "搜索演示作品与创作者")
            .navigationDestination(item: $detail) { i in DemoWorkDetail(index: i, project: examples[i]) { p in detail = nil; onRemix(p) } }
    }
}
struct DemoWorkDetail: View {
    @EnvironmentObject private var store: ProjectStore
    @EnvironmentObject private var audio: AudioController
    var index: Int
    var project: MusicProject
    var onRemix: (MusicProject) -> Void
    @State private var comments = false
    @State private var remix = false
    @State private var likes: Set<Int> = Set(UserDefaults.standard.array(forKey: "demoLikes") as? [Int] ?? [])
    @State private var favorites: Set<Int> = Set(UserDefaults.standard.array(forKey: "demoFavorites") as? [Int] ?? [])
    var body: some View {
        List {
            Section {
                MiniScore(notes: project.tracks[0].notes).frame(height: 150)
                Text(DemoMusic.titles[index]).font(.title2.weight(.semibold))
                Text("\(DemoMusic.authors[index]) · 演示创作者").foregroundStyle(.secondary)
                Text("从日常的一点情绪出发，把它写成旋律。希望这段音乐也能陪伴你的某一个瞬间。")
                Button { Task { do { try await audio.play(project) } catch { store.error = error.localizedDescription } } } label: { Label(audio.playingID == project.id ? "暂停" : "播放作品", systemImage: audio.playingID == project.id ? "pause.fill" : "play.fill") }
            }
            Section("本地互动") {
                Button { toggle(index, in: &likes, key: "demoLikes") } label: { Label(likes.contains(index) ? "取消本地喜欢" : "本地喜欢", systemImage: likes.contains(index) ? "heart.fill" : "heart") }
                Button { toggle(index, in: &favorites, key: "demoFavorites") } label: { Label(favorites.contains(index) ? "取消本地收藏" : "本地收藏", systemImage: favorites.contains(index) ? "bookmark.fill" : "bookmark") }
                Button { comments = true } label: { Label("演示评论", systemImage: "bubble.right") }
            }
            Section {
                Button { remix = true } label: { Label("基于此创作", systemImage: "music.note") }
            } footer: { Text("内置原创示例，可复制旋律为独立工程。保留来源和署名，不修改示例。") }
        }.navigationTitle("作品详情").navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $comments) { DemoCommentsView() }
            .confirmationDialog("创建独立改编项目", isPresented: $remix, titleVisibility: .visible) {
                Button("创建项目") {
                    var p = MusicProject.example(index); p.name = DemoMusic.titles[index] + " · 我的改编"; p.sample = false
                    p.source = "内置原创示例：\(DemoMusic.titles[index])，演示作者：\(DemoMusic.authors[index])，版本 1"
                    do { try store.save(p); onRemix(p) } catch { store.error = error.localizedDescription }
                }
                Button("取消", role: .cancel) {}
            } message: { Text("素材范围为内置示例主旋律；允许修改与导出。工程会保留来源与署名关系。") }
    }
    private func toggle(_ value: Int, in values: inout Set<Int>, key: String) { if values.contains(value) { values.remove(value) } else { values.insert(value) }; UserDefaults.standard.set(Array(values), forKey: key) }
}
struct DemoCommentsView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List {
                Section("山间的风 · 示例用户") { Text("开头的旋律好温柔，像傍晚窗边的光。") }
                Section { Text("评论服务尚未接入，暂时无法发送、回复或举报。").foregroundStyle(.secondary) }
            }.navigationTitle("演示评论").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("完成") { dismiss() } } }
        }.presentationDetents([.medium, .large])
    }
}
struct MessagesView: View {
    var body: some View {
        List {
            Section {
                ForEach([("bubble.left", "评论与回复"), ("heart", "赞与收藏"), ("person.badge.plus", "新关注"), ("bell", "系统通知")], id: \.1) { symbol, title in
                    LabeledContent { Text("未接入").foregroundStyle(.secondary) } label: { Label(title, systemImage: symbol) }
                }
            }
            Section { ContentUnavailableView("暂无在线消息", systemImage: "bubble.left.and.bubble.right", description: Text("在线服务尚未接入，当前没有真实社区通知。")) }
        }.navigationTitle("消息")
    }
}
struct ProfileView: View {
    @EnvironmentObject var store: ProjectStore
    @AppStorage("appearance") private var appearance = "dark"
    @AppStorage("hapticsEnabled") private var haptics = true
    @AppStorage("studioMode") private var rawMode = StudioMode.standard.rawValue
    var onOpen: (MusicProject) -> Void
    var body: some View {
        Form {
            Section {
                Label { VStack(alignment: .leading, spacing: 6) { Text("星光创作者").font(.headline); Text("本地模拟身份 · 无需登录").font(.caption).foregroundStyle(.secondary) } } icon: { Image(systemName: "person.crop.circle.fill").font(.largeTitle) }.padding(.vertical, 8)
            }
            Section {
                NavigationLink { DraftsView(onOpen: onOpen) } label: { Label("我的草稿 · \(store.projects.filter { !$0.deleted }.count)", systemImage: "folder") }
                NavigationLink { LocalCollectionView(onOpen: onOpen) } label: { Label("本地收藏与喜欢", systemImage: "bookmark") }
                LabeledContent("已发布作品", value: "服务未接入").foregroundStyle(.secondary)
            }
            Section("创作与外观") {
                Picker("创作模式", selection: $rawMode) { ForEach(StudioMode.allCases) { Text($0.title).tag($0.rawValue) } }.accessibilityIdentifier("settings.studioMode")
                Text((StudioMode(rawValue: rawMode) ?? .standard).detail).font(.caption).foregroundStyle(.secondary)
                Picker("外观", selection: $appearance) { Text("深色").tag("dark"); Text("浅色").tag("light"); Text("跟随系统").tag("system") }
                Toggle("轻触反馈", isOn: $haptics).accessibilityIdentifier("settings.haptics")
            }
            Section {
                NavigationLink { RecognitionSettingsView() } label: { Label("识谱与我的模型", systemImage: "waveform.badge.magnifyingglass") }
                NavigationLink { HelpContent() } label: { Label("关于与帮助", systemImage: "questionmark.circle") }
            } footer: { Text("草稿保存在本机。删除应用会移除本地数据，请定期导出项目备份。三种内置乐器声音无需联网。") }
        }.navigationTitle("我的")
    }
}
struct LocalCollectionView: View {
    var onOpen: (MusicProject) -> Void
    let liked = Set(UserDefaults.standard.array(forKey: "demoLikes") as? [Int] ?? [])
    let saved = Set(UserDefaults.standard.array(forKey: "demoFavorites") as? [Int] ?? [])
    var body: some View {
        List {
            if liked.union(saved).isEmpty { ContentUnavailableView("还没有本地收藏", systemImage: "bookmark", description: Text("演示作品的喜欢和收藏会显示在这里。")) }
            ForEach(Array(liked.union(saved)).filter { (0..<3).contains($0) }.sorted(), id: \.self) { i in
                NavigationLink { DemoWorkDetail(index: i, project: MusicProject.example(i), onRemix: onOpen) } label: { VStack(alignment: .leading, spacing: 6) { Text(DemoMusic.titles[i]); Text("内置示例 · 仅保存在此设备").font(.caption).foregroundStyle(.secondary) } }
            }
        }.navigationTitle("本地收藏与喜欢")
    }
}
struct HelpContent: View {
    var body: some View {
        List {
            ForEach([("记录灵感", "首次录音会请求麦克风权限。清晰地哼唱一条旋律，完成后先保存原声，再自动整理旋律。"), ("修改旋律", "普通模式用线条展示高低，轻点一个声音即可调整。专业模式可编辑五线谱。整首变高或变低请用「换个调」。"), ("添加声音", "可以为每个声音单独录唱、导入文件和修改旋律。更换乐器只改变演奏声音，不会自动生成伴奏。"), ("保管创作", "草稿写入本机后才显示已保存。完整备份保留原录音；旋律文件供其他音乐软件编辑，音频文件可直接收听。"), ("当前阶段", "本地创作与社区演示。真实账号、在线发布、关注、评论和消息尚未接入。复杂歌曲的转谱准确性仍有限制。")], id: \.0) { title, description in Section(title) { Text(description) } }
        }.navigationTitle("关于与帮助").navigationBarTitleDisplayMode(.inline)
    }
}
struct HelpView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View { NavigationStack { HelpContent().toolbar { ToolbarItem(placement: .confirmationAction) { Button("完成") { dismiss() } } } } }
}
