import SwiftUI

struct CreationHome: View {
    @EnvironmentObject var store: ProjectStore
    @EnvironmentObject var audio: AudioController
    @Environment(\.colorScheme) private var scheme
    var onStart: (Bool) -> Void
    var onOpen: (MusicProject) -> Void
    var onImport: () -> Void
    var onHelp: () -> Void
    @State private var chooser = false
    @State private var instruments = false
    @State private var pendingChoice: StartChoice?
    private enum StartChoice { case record, blank, file }
    private var drafts: [MusicProject] { Array(store.projects.filter { !$0.deleted }.prefix(3)) }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                brandHeader.cascade(0)
                introduction.cascade(1)
                creationCard.cascade(2)
                importCard.cascade(3)
                toolShelf.cascade(4)
                draftsHeading.cascade(5)
                recentDrafts
                Label("灵感保存在此设备，随时继续。", systemImage: "lock")
                    .font(.caption2).foregroundStyle(.secondary.opacity(0.8)).padding(.top, 2).cascade(8)
            }.padding(.horizontal, 20).padding(.top, 10).padding(.bottom, 24)
                .frame(maxWidth: 740).frame(maxWidth: .infinity)
        }.background(Palette.background(scheme)).toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $chooser, onDismiss: performChoice) { creationSheet }
            .sheet(isPresented: $instruments) { InstrumentSheet() }
    }
    private var brandHeader: some View {
        HStack(spacing: 10) {
            BrandMark().frame(width: 32, height: 32)
            Text("Star Music").font(.system(.title3, design: .rounded).weight(.semibold)).tracking(-0.5)
            Spacer()
            Button(action: onHelp) {
                Image(systemName: "questionmark").font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.secondary).frame(width: 44, height: 44)
                    .background(.primary.opacity(0.045), in: Circle())
            }.buttonStyle(MusicPressStyle()).accessibilityLabel("帮助")
        }
    }
    private var introduction: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 7) { Circle().fill(Palette.gold).frame(width: 4, height: 4); Text("你的创作空间").font(.caption).foregroundStyle(.secondary) }
            Text("今天，写点音乐。").font(.system(.largeTitle, design: .rounded).weight(.medium)).tracking(-1.2)
        }.padding(.top, 8).padding(.bottom, 4)
    }
    private var creationCard: some View {
        Button { pendingChoice = nil; chooser = true } label: {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 28)
                    .fill(LinearGradient(colors: [Color(red: 0.96, green: 0.93, blue: 0.84), Palette.paper], startPoint: .topLeading, endPoint: .bottomTrailing))
                PaperStaveArtwork().frame(width: 190, height: 150).opacity(0.43)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing).padding(.top, 16).clipped()
                VStack(alignment: .leading, spacing: 0) {
                    Text("让脑海里的旋律，有迹可循。").font(.caption).foregroundStyle(Palette.ink.opacity(0.55))
                    Spacer(minLength: 24)
                    Text("开始创作").font(.system(.title, design: .rounded).weight(.semibold)).tracking(-0.8)
                    Text("哼出旋律，写成自己的歌。").font(.subheadline).foregroundStyle(Palette.ink.opacity(0.65)).padding(.top, 8)
                    Spacer(minLength: 24)
                    HStack {
                        HStack(spacing: 6) { Image(systemName: "mic").font(.caption); Text("录音  ·  写谱  ·  导入").font(.caption2) }.foregroundStyle(Palette.ink.opacity(0.55))
                        Spacer()
                        Image(systemName: "arrow.up.right").font(.system(size: 17, weight: .medium))
                            .frame(width: 44, height: 44).background(Palette.ink, in: Circle()).foregroundStyle(Palette.paper)
                    }
                }.padding(24).foregroundStyle(Palette.ink)
            }.frame(minHeight: 226)
                .overlay(RoundedRectangle(cornerRadius: 28).stroke(.white.opacity(0.38), lineWidth: 0.8))
                .shadow(color: .black.opacity(scheme == .dark ? 0.15 : 0.045), radius: 15, x: 0, y: 8)
        }.buttonStyle(MusicPressStyle(scale: 0.985)).accessibilityIdentifier("home.start")
            .accessibilityLabel("开始创作").accessibilityHint("选择哼唱录制、空白乐谱或导入文件")
    }
    private var importCard: some View {
        Button(action: onImport) {
            HStack(spacing: 14) {
                Image(systemName: "square.and.arrow.down").font(.system(size: 19, weight: .regular))
                    .frame(width: 42, height: 44).background(Palette.gold.opacity(0.09), in: RoundedRectangle(cornerRadius: 12)).foregroundStyle(Palette.gold)
                VStack(alignment: .leading, spacing: 5) {
                    Text("导入音乐").font(.subheadline.weight(.medium))
                    Text("接着已有的灵感，往下写。").font(.caption).foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
                Image(systemName: "arrow.up.right").font(.caption).foregroundStyle(.secondary)
            }.padding(.horizontal, 18).padding(.vertical, 14)
                .background(Palette.card(scheme), in: RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(.primary.opacity(0.045), lineWidth: 0.7))
        }.buttonStyle(MusicPressStyle()).accessibilityIdentifier("home.import")
    }
    private var toolShelf: some View {
        HStack(spacing: 12) {
            ToolCard(title: "空白乐谱", subtitle: "从第一个音符开始", symbol: "music.note.list") { onStart(false) }.accessibilityIdentifier("home.blank")
            ToolCard(title: "乐器库", subtitle: "为旋律换一种声音", symbol: "pianokeys") { instruments = true }.accessibilityIdentifier("home.instruments")
        }
    }
    private var draftsHeading: some View {
        HStack {
            Text("最近草稿").font(.headline.weight(.medium))
            Text("\(store.projects.filter { !$0.deleted }.count)").font(.caption).foregroundStyle(.tertiary)
            Spacer()
            NavigationLink { DraftsView(onOpen: onOpen) } label: {
                HStack(spacing: 5) { Text("全部"); Image(systemName: "arrow.right").font(.caption2) }
                    .font(.caption).foregroundStyle(.secondary).frame(minHeight: 44)
            }.buttonStyle(MusicPressStyle()).accessibilityIdentifier("home.drafts")
        }.padding(.top, 8)
    }
    @ViewBuilder private var recentDrafts: some View {
        if drafts.isEmpty { EmptyState(symbol: "music.note", title: "下一段旋律，等你写下", subtitle: "你的创作会自动保存在这里。").cascade(6) }
        else {
            VStack(spacing: 0) {
                ForEach(Array(drafts.enumerated()), id: \.element.id) { index, project in
                    DraftRow(project: project, onOpen: onOpen, grouped: true).cascade(6 + index)
                    if index != drafts.count - 1 { Rectangle().fill(.primary.opacity(0.045)).frame(height: 0.7).padding(.leading, 84) }
                }
            }.background(Palette.card(scheme), in: RoundedRectangle(cornerRadius: 24))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(.primary.opacity(0.045), lineWidth: 0.7))
        }
    }
    private var creationSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 13) {
                    Text("每首歌，\n都有自己的起点。").font(.title2.weight(.medium)).tracking(-0.5).padding(.bottom, 9).cascade(0)
                    StartOption(title: "哼唱录制", subtitle: "先留下旋律，再自动生成乐谱", symbol: "mic") { choose(.record) }.cascade(1).accessibilityIdentifier("start.record")
                    StartOption(title: "空白乐谱", subtitle: "从第一颗音符开始写", symbol: "music.note.list") { choose(.blank) }.cascade(2).accessibilityIdentifier("start.blank")
                    StartOption(title: "导入文件", subtitle: "音频、MIDI 或 Star Music 项目包", symbol: "square.and.arrow.down") { choose(.file) }.cascade(3).accessibilityIdentifier("start.import")
                }.padding(24)
            }.background(Palette.background(scheme))
                .toolbar { ToolbarItem(placement: .topBarTrailing) { Button { chooser = false } label: { Image(systemName: "xmark").font(.caption.weight(.semibold)).frame(width: 44, height: 44) }.buttonStyle(MusicPressStyle()).accessibilityLabel("关闭创作选择") } }
        }.presentationDetents([.medium, .large]).presentationDragIndicator(.visible).presentationCornerRadius(30)
    }
    private func choose(_ choice: StartChoice) { pendingChoice = choice; chooser = false }
    private func performChoice() {
        guard let choice = pendingChoice else { return }; pendingChoice = nil
        switch choice { case .record: onStart(true); case .blank: onStart(false); case .file: onImport() }
    }
}

struct PaperStaveArtwork: View {
    var body: some View {
        Canvas { context, size in
            var staff = Path()
            for row in 0..<5 {
                let y = CGFloat(37 + row * 11)
                staff.move(to: CGPoint(x: 20, y: y + 34))
                staff.addCurve(to: CGPoint(x: size.width + 10, y: y - 8), control1: CGPoint(x: 72, y: y + 33), control2: CGPoint(x: 107, y: y - 15))
            }
            context.stroke(staff, with: .color(Palette.ink.opacity(0.26)), lineWidth: 0.7)
            let points = [CGPoint(x: 74, y: 86), CGPoint(x: 107, y: 60), CGPoint(x: 141, y: 49)]
            for point in points {
                context.fill(Path(ellipseIn: CGRect(x: point.x - 4, y: point.y - 3, width: 8, height: 6)), with: .color(Palette.ink.opacity(0.55)))
                var stem = Path(); stem.move(to: point); stem.addLine(to: CGPoint(x: point.x + 4, y: point.y - 21)); context.stroke(stem, with: .color(Palette.ink.opacity(0.55)), lineWidth: 1)
            }
        }.accessibilityHidden(true)
    }
}

struct BrandMark: View {
    var body: some View { ZStack { RoundedRectangle(cornerRadius: 11).fill(Palette.gold); Image(systemName: "music.note").font(.title3.bold()).foregroundStyle(Palette.ink); Rectangle().fill(Palette.gold).frame(width: 4).rotationEffect(.degrees(42)).padding(5) }.accessibilityHidden(true) }
}
struct ToolCard: View {
    var title: String; var subtitle: String; var symbol: String; var action: () -> Void
    var body: some View { Button(action: action) { HStack(spacing: 10) { Image(systemName: symbol).font(.title3).frame(width: 30, height: 44); VStack(alignment: .leading, spacing: 6) { Text(title).font(.subheadline.weight(.medium)); Text(subtitle).font(.caption2).foregroundStyle(.secondary).lineLimit(2) }; Spacer(minLength: 0) }.frame(maxWidth: .infinity, alignment: .leading).musicCard() }.buttonStyle(MusicPressStyle()) }
}
struct StartOption: View {
    var title: String; var subtitle: String; var symbol: String; var action: () -> Void
    var body: some View { Button(action: action) { HStack(spacing: 16) { Image(systemName: symbol).foregroundStyle(Palette.gold).font(.title2).frame(width: 42, height: 44); VStack(alignment: .leading, spacing: 6) { Text(title).font(.headline); Text(subtitle).font(.caption).foregroundStyle(.secondary) }; Spacer(); Image(systemName: "chevron.right").font(.caption).foregroundStyle(.secondary) }.musicCard(radius: 16) }.buttonStyle(MusicPressStyle()) }
}
struct EmptyState: View {
    var symbol: String; var title: String; var subtitle: String
    var body: some View { VStack(spacing: 14) { Image(systemName: symbol).font(.largeTitle).foregroundStyle(Palette.gold); Text(title).font(.headline); Text(subtitle).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center) }.frame(maxWidth: .infinity).padding(.vertical, 48).musicCard() }
}
struct DraftRow: View {
    @Environment(\.colorScheme) private var scheme
    @EnvironmentObject var store: ProjectStore
    @EnvironmentObject var audio: AudioController
    let project: MusicProject; var onOpen: (MusicProject) -> Void; var grouped = false; var compact = false
    @State private var rename = false
    @State private var name = ""
    @State private var move = false
    @State private var folder = ""
    @State private var share: ShareItem?
    @State private var confirmDelete = false
    var body: some View {
        let rowLayout = compact ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8)) : AnyLayout(HStackLayout(spacing: 8))
        rowLayout {
            Button { if !project.deleted { onOpen(project) } } label: {
                let previewLayout = compact ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12)) : AnyLayout(HStackLayout(spacing: 12))
                previewLayout {
                    MiniScore(notes: project.tracks[0].notes).frame(width: compact ? nil : 52, height: compact ? 88 : 58)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(project.name).font(.subheadline.weight(.medium)).lineLimit(2)
                        Text("\(musicTime(project.seconds)) · \(project.tracks.count) 条音轨" + (project.sample ? " · 示例" : "")).font(.caption2).foregroundStyle(.secondary)
                        if !compact { Text(project.updated, style: .relative).font(.caption2).foregroundStyle(.tertiary) }
                    }
                }.frame(maxWidth: .infinity, minHeight: 58, alignment: .leading)
            }.buttonStyle(MusicPressStyle())
            HStack(spacing: 0) {
            if compact { Spacer(minLength: 0) }
            if project.deleted { Button("恢复") { store.update(project) { $0.deleted = false } }.font(.caption).frame(minWidth: 44, minHeight: 44) }
            else { Button { Task { do { try await audio.play(project) } catch { store.error = error.localizedDescription } } } label: { PlaybackGlyph(playing: audio.playingID == project.id).font(.caption).frame(width: 44, height: 44) }.buttonStyle(MusicPressStyle()).accessibilityLabel("试听 \(project.name)") }
            Menu {
                if !project.deleted {
                    Button("重命名", systemImage: "pencil") { name = project.name; rename = true }
                    Button(project.favorite ? "取消收藏" : "收藏", systemImage: "star") { store.update(project) { $0.favorite.toggle() } }
                    Button("复制项目", systemImage: "doc.on.doc") { do { try store.duplicate(project) } catch { store.error = error.localizedDescription } }
                    Button("移动到文件夹", systemImage: "folder") { folder = project.folder; move = true }
                    Button("导出项目包", systemImage: "square.and.arrow.up") { do { share = ShareItem(url: try store.package(project)) } catch { store.error = error.localizedDescription } }
                    Button("移入最近删除", systemImage: "trash", role: .destructive) { confirmDelete = true }
                } else { Button("恢复草稿", systemImage: "arrow.uturn.backward") { store.update(project) { $0.deleted = false } } }
            } label: { Image(systemName: "ellipsis").frame(width: 44, height: 44).foregroundStyle(.secondary) }.accessibilityLabel("草稿更多操作")
            }
        }.padding(.horizontal, 14).padding(.vertical, 12).background(grouped ? Color.clear : Palette.card(scheme), in: RoundedRectangle(cornerRadius: 18))
        .confirmationDialog("移入最近删除？", isPresented: $confirmDelete, titleVisibility: .visible) { Button("移入最近删除", role: .destructive) { audio.stopPlayback(); store.update(project) { $0.deleted = true } }; Button("取消", role: .cancel) {} } message: { Text("可以随时在最近删除中恢复这份草稿。") }
        .alert("重命名", isPresented: $rename) { TextField("名称", text: $name); Button("保存") { store.update(project) { $0.name = name.isEmpty ? "未命名的旋律" : String(name.prefix(60)) } }; Button("取消", role: .cancel) {} }
        .alert("移动到文件夹", isPresented: $move) { TextField("文件夹名称", text: $folder); Button("移动") { store.update(project) { $0.folder = folder.isEmpty ? "未分类" : String(folder.prefix(40)) } }; Button("取消", role: .cancel) {} }
        .sheet(item: $share) { ShareSheet(url: $0.url) }
    }
}
struct DraftsView: View {
    @EnvironmentObject var store: ProjectStore
    @Environment(\.colorScheme) var scheme
    var onOpen: (MusicProject) -> Void
    @State private var search = ""
    @State private var deleted = false
    @State private var grid = false
    @State private var sort = "最近编辑"
    @State private var folder = "全部文件夹"
    @State private var searchExpanded = false
    @FocusState private var searchFocused: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var typeSize
    var filtered: [MusicProject] { store.projects.filter { $0.deleted == deleted && (search.isEmpty || $0.name.localizedCaseInsensitiveContains(search)) && (folder == "全部文件夹" || $0.folder == folder) }.sorted { a, b in sort == "名称" ? a.name < b.name : sort == "收藏优先" ? (a.favorite == b.favorite ? a.updated > b.updated : a.favorite) : a.updated > b.updated } }
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                searchBar
                HStack {
                    Picker("排序", selection: $sort) { ForEach(["最近编辑", "名称", "收藏优先"], id: \.self) { Text($0) } }.pickerStyle(.menu)
                    Picker("文件夹", selection: $folder) { Text("全部文件夹").tag("全部文件夹"); ForEach(Array(Set(store.projects.map(\.folder))).sorted(), id: \.self) { Text($0).tag($0) } }.pickerStyle(.menu)
                    Spacer(); Button { withAnimation(reduceMotion ? nil : .spring(response: 0.42, dampingFraction: 0.86)) { grid.toggle() } } label: { Image(systemName: grid ? "list.bullet" : "square.grid.2x2").frame(width: 44, height: 44) }.buttonStyle(MusicPressStyle()).accessibilityIdentifier("drafts.layout").accessibilityLabel(grid ? "切换为列表" : "切换为网格")
                }
                if filtered.isEmpty { EmptyState(symbol: "folder", title: deleted ? "没有已删除的草稿" : "没有匹配的旋律", subtitle: "删除的草稿可以恢复，所有草稿都保存在本机。") }
                DraftCollectionLayout(columns: grid && !typeSize.isAccessibilitySize ? 2 : 1) {
                    ForEach(filtered) { DraftRow(project: $0, onOpen: onOpen, compact: grid && !typeSize.isAccessibilitySize) }
                }
            }.padding(16)
        }.background(Palette.background(scheme)).navigationTitle(deleted ? "最近删除" : "草稿箱").navigationBarTitleDisplayMode(.inline)
        
        .toolbar { ToolbarItem(placement: .topBarTrailing) { Button { deleted.toggle() } label: { Image(systemName: deleted ? "folder" : "trash").frame(minWidth: 44, minHeight: 44) }.accessibilityLabel(deleted ? "全部草稿" : "最近删除") } }
    }
    private var searchBar: some View {
        HStack(spacing: 10) {
            Button {
                withAnimation(reduceMotion ? nil : .spring(response: 0.38, dampingFraction: 0.86)) { searchExpanded.toggle() }
                searchFocused = searchExpanded
                if !searchExpanded { search = "" }
            } label: { Image(systemName: searchExpanded ? "xmark" : "magnifyingglass").contentTransition(.symbolEffect(.replace)).frame(width: 44, height: 44) }
                .buttonStyle(MusicPressStyle()).accessibilityLabel(searchExpanded ? "关闭搜索" : "搜索草稿").accessibilityIdentifier("drafts.searchToggle")
            if searchExpanded {
                TextField("搜索你的旋律", text: $search).focused($searchFocused).submitLabel(.search)
                    .onSubmit { searchFocused = false }.accessibilityIdentifier("drafts.searchField")
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                if !search.isEmpty { Button { search = "" } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary).frame(width: 44, height: 44) }.accessibilityLabel("清空搜索") }
            }
        }.padding(.trailing, searchExpanded ? 6 : 0).frame(maxWidth: searchExpanded ? .infinity : 44, alignment: .leading)
            .background(Palette.card(scheme), in: RoundedRectangle(cornerRadius: searchExpanded ? 16 : 22))
            .frame(maxWidth: .infinity, alignment: .trailing)
    }

}
struct CommunityView: View {
    @EnvironmentObject var store: ProjectStore
    @EnvironmentObject var audio: AudioController
    @Environment(\.colorScheme) var scheme
    var onRemix: (MusicProject) -> Void
    @State private var selected = "推荐"
    @State private var search = ""
    @State private var detail: Int?
    @State private var comments = false
    @State private var likes: Set<Int> = Set(UserDefaults.standard.array(forKey: "demoLikes") as? [Int] ?? [])
    @State private var favorites: Set<Int> = Set(UserDefaults.standard.array(forKey: "demoFavorites") as? [Int] ?? [])
    @State private var remix: Int?
    @State private var examples = (0..<3).map { MusicProject.example($0) }
    let titles = ["晚风经过的地方", "在雨停之前", "一颗星的旅行"]
    let authors = ["木与舟", "北岛来信", "Milo"]
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("发现音乐，\n也发现彼此。").font(.title2.bold())
                Picker("社区分类", selection: $selected) { ForEach(["推荐", "关注", "搜索"], id: \.self) { Text($0) } }.pickerStyle(.segmented)
                Label("演示内容 · 作者与互动数据为示例，喜欢和收藏仅保存在此设备。", systemImage: "info.circle").font(.caption).foregroundStyle(.secondary).musicCard(radius: 14)
                if selected == "关注" { EmptyState(symbol: "person.2", title: "灵感从一次相遇开始", subtitle: "关注服务尚未接入，先去推荐页发现旋律。") }
                else {
                    ForEach((0..<3).filter { search.isEmpty || (titles[$0] + authors[$0]).localizedCaseInsensitiveContains(search) }, id: \.self) { i in
                        VStack(alignment: .leading, spacing: 14) {
                            ZStack(alignment: .bottomTrailing) {
                                RoundedRectangle(cornerRadius: 20).fill([Color(red: 0.53, green: 0.61, blue: 0.44), Color(red: 0.39, green: 0.55, blue: 0.61), Color(red: 0.64, green: 0.44, blue: 0.37)][i])
                                MiniScore(notes: examples[i].tracks[0].notes).padding(30).rotationEffect(.degrees(-6)).opacity(0.85)
                                Text(["完整作品", "旋律片段", "创作过程"][i] + " · 示例").font(.caption2).padding(10).background(.black.opacity(0.15), in: Capsule()).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading).padding(16)
                                Button { Task { do { try await audio.play(examples[i]) } catch { store.error = error.localizedDescription } } } label: { PlaybackGlyph(playing: audio.playingID == examples[i].id).frame(width: 48, height: 48).background(.white.opacity(0.9), in: Circle()).foregroundStyle(Palette.ink) }.padding(16).accessibilityLabel("播放演示作品")
                            }.frame(height: 215)
                            Button { detail = i } label: { Text(titles[i]).font(.headline) }.buttonStyle(MusicPressStyle())
                            HStack { Text(authors[i]).font(.caption).foregroundStyle(.secondary); Spacer(); Text(Instrument.allCases[i].name).font(.caption2).foregroundStyle(.secondary) }
                            HStack {
                                Text(musicTime(MusicProject.example(i).seconds)).font(.caption).foregroundStyle(.secondary); Spacer()
                                LikeBurstButton(selected: likes.contains(i)) { if likes.contains(i) { likes.remove(i) } else { likes.insert(i) }; UserDefaults.standard.set(Array(likes), forKey: "demoLikes") }
                                Button { comments = true } label: { Image(systemName: "bubble.right").frame(width: 44, height: 44) }.accessibilityLabel("查看演示评论")
                            }
                        }.musicCard()
                    }
                }
            }.padding(16).frame(maxWidth: 680).frame(maxWidth: .infinity)
        }.background(Palette.background(scheme)).navigationTitle("社区").navigationBarTitleDisplayMode(.inline).searchable(text: $search, prompt: "搜索演示作品与创作者")
        .sheet(isPresented: Binding(get: { detail != nil }, set: { if !$0 { detail = nil } })) {
            if let i = detail {
                NavigationStack {
                    VStack(alignment: .leading, spacing: 24) { MiniScore(notes: examples[i].tracks[0].notes).frame(height: 180); Text(titles[i]).font(.title2.bold()); Text("\(authors[i]) · 演示创作者").foregroundStyle(.secondary); Text("从日常的一点情绪出发，把它写成旋律。希望这段音乐也能陪伴你的某一个瞬间。").font(.subheadline); HStack {
                        Button(favorites.contains(i) ? "已在本地收藏" : "本地收藏") { if favorites.contains(i) { favorites.remove(i) } else { favorites.insert(i) }; UserDefaults.standard.set(Array(favorites), forKey: "demoFavorites") }.frame(minHeight: 44)
                        Spacer(); GoldButton(title: "基于此创作", symbol: "music.note") { remix = i }
                    }; Text("内置原创示例，可复制旋律为独立工程。不会修改示例来源。").font(.caption).foregroundStyle(.secondary); Spacer() }.padding(24).toolbar { ToolbarItem(placement: .topBarTrailing) { Button("关闭") { detail = nil } } }
                }
            }
        }
        .sheet(isPresented: $comments) { VStack(alignment: .leading, spacing: 22) { Text("评论 · 演示内容").font(.title2.bold()); Text("山间的风 · 示例用户").font(.subheadline.bold()); Text("开头的旋律好温柔，像傍晚窗边的光。"); Text("评论服务尚未接入，暂时无法发送、回复或举报。").font(.caption).foregroundStyle(.secondary) }.padding(24).presentationDetents([.medium]) }
        .alert("创建独立改编项目", isPresented: Binding(get: { remix != nil }, set: { if !$0 { remix = nil } })) { Button("创建") { if let i = remix { var p = MusicProject.example(i); p.name = titles[i] + " · 我的改编"; p.sample = false; p.source = "内置原创示例：\(titles[i])，演示作者：\(authors[i])，版本 1"; do { try store.save(p); detail = nil; remix = nil; DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { onRemix(p) } } catch { store.error = error.localizedDescription } } }; Button("取消", role: .cancel) { remix = nil } } message: { Text("素材范围为内置示例主旋律；允许修改与导出。工程会保留来源与署名关系。") }
    }
}
struct MessagesView: View {
    var body: some View { ScrollView { VStack(spacing: 18) { ForEach([("bubble.left", "评论与回复"), ("heart", "赞与收藏"), ("person.badge.plus", "新关注"), ("bell", "系统通知")], id: \.1) { symbol, title in HStack { Image(systemName: symbol).frame(width: 32); Text(title); Spacer(); Text("未接入").font(.caption).foregroundStyle(.secondary) }.musicCard() }; EmptyState(symbol: "bubble.left.and.bubble.right", title: "这里，将是音乐的回声", subtitle: "在线消息服务尚未接入。当前没有真实社区通知。") }.padding(16) }.navigationTitle("消息") }
}
struct ProfileView: View {
    @EnvironmentObject var store: ProjectStore
    @AppStorage("appearance") private var appearance = "dark"
    @AppStorage("hapticsEnabled") private var haptics = true
    var onOpen: (MusicProject) -> Void
    @State private var help = false
    var body: some View {
        List {
            Section { HStack(spacing: 18) { Text("星").font(.title).frame(width: 64, height: 64).background(Palette.gold.opacity(0.15), in: Circle()).foregroundStyle(Palette.gold); VStack(alignment: .leading, spacing: 8) { Text("星光创作者").font(.title3.bold()); Text("每一段旋律，都是我的一个小宇宙。").font(.caption).foregroundStyle(.secondary); Text("本地模拟身份 · 无需登录").font(.caption2).foregroundStyle(.secondary) } }.padding(.vertical, 12) }
            Section {
                NavigationLink { DraftsView(onOpen: onOpen) } label: { Label("我的草稿 · \(store.projects.filter { !$0.deleted }.count)", systemImage: "folder") }
                NavigationLink { LocalCollectionView() } label: { Label("本地收藏与喜欢", systemImage: "bookmark") }
                Label("已发布作品 · 服务尚未接入", systemImage: "music.note").foregroundStyle(.secondary)
            }
            Section("设置") {
                Picker("外观", selection: $appearance) { Text("深色").tag("dark"); Text("浅色").tag("light"); Text("跟随系统").tag("system") }
                Toggle("轻触反馈", isOn: $haptics).toggleStyle(JellyToggleStyle()).accessibilityIdentifier("settings.haptics")
                Button { help = true } label: { Label("关于与帮助", systemImage: "questionmark.circle") }
            }
            Section { Text("草稿保存在本机应用沙盒中。删除应用会移除本地数据；请定期通过草稿菜单导出项目包。所有音源为内置合成，无需联网下载。").font(.caption).foregroundStyle(.secondary) }
        }.navigationTitle("我的").sheet(isPresented: $help) { HelpView() }
    }
}
struct LocalCollectionView: View {
    let liked = Set(UserDefaults.standard.array(forKey: "demoLikes") as? [Int] ?? [])
    let saved = Set(UserDefaults.standard.array(forKey: "demoFavorites") as? [Int] ?? [])
    var body: some View { List { ForEach(Array(liked.union(saved)).sorted(), id: \.self) { i in VStack(alignment: .leading, spacing: 6) { Text(["晚风经过的地方", "在雨停之前", "一颗星的旅行"][i]); Text("内置示例 · 仅保存在此设备").font(.caption).foregroundStyle(.secondary) } }; if liked.union(saved).isEmpty { Text("还没有收藏或喜欢的演示作品。").foregroundStyle(.secondary) } }.navigationTitle("本地收藏与喜欢") }
}
struct HelpView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View { NavigationStack { ScrollView { VStack(alignment: .leading, spacing: 24) { Text("每一个人，\n都可以创作音乐。").font(.title.bold()); ForEach([("记录灵感", "录音首次请求麦克风权限。清晰地哼唱单声部旋律，结束后先保存原声，再自动转谱。"), ("编辑旋律", "点击音符编辑音高与时值。开启添加模式后点击谱面放置音符。上下拖动按谱线位置吸附，半音变化使用音高控件。"), ("找到你的声音", "内置钢琴、木吉他与合成器，均可离线试听。多轨支持静音、独奏和音量。"), ("保管你的灵感", "草稿真正写入应用沙盒后才显示已保存。导出的项目包包含原始录音；MIDI 保留音符，WAV 导出成品音频。"), ("当前阶段", "本地创作与社区演示；真实账号、在线发布、关注、评论和消息服务尚未接入。复杂复音、鼓网格、自动伴奏、PDF 与 MusicXML 将在后续阶段增加。")], id: \.0) { title, description in VStack(alignment: .leading, spacing: 10) { Text(title).font(.headline); Text(description).font(.subheadline).foregroundStyle(.secondary) } } }.padding(24) }.toolbar { ToolbarItem(placement: .topBarTrailing) { Button("完成") { dismiss() } } } } }
}
