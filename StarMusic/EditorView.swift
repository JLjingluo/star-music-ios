import SwiftUI
import UniformTypeIdentifiers

@MainActor struct EditorView: View {
    @EnvironmentObject var audio: AudioController
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var scheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @StateObject private var session: EditorSession
    @State private var addMode = false
    @State private var multiTrack = false
    @State private var instruments = false
    @State private var share: ShareItem?
    @State private var export = false
    @State private var publish = false
    @State private var transpose = false
    @State private var saveFailure = false
    @State private var renaming = false
    @State private var newName = ""
    @State private var overflow: Double?
    @State private var processing = false
    @State private var analysis: Task<Void, Never>?
    @State private var reanalyze = false
    @State private var loop = false
    @State private var addTrack = false
    @State private var trackChoice: String?
    @State private var importer = false
    @State private var importTrackID: UUID?
    @State private var recording: TrackRecordingRoute?
    @State private var recordConfirmation: UUID?
    @State private var modelSettings = false
    @State private var stage = "正在处理音频…"
    @AppStorage("studioMode") private var rawMode = StudioMode.standard.rawValue
    @State private var expandedTools = false
    private var professional: Bool { rawMode == StudioMode.professional.rawValue }
    private var standard: Bool { rawMode == StudioMode.standard.rawValue }
    private var simpleMode: Bool { rawMode == StudioMode.simple.rawValue && !expandedTools }
    init(project: MusicProject, store: ProjectStore) { _session = StateObject(wrappedValue: EditorSession(project, store: store)) }
    var body: some View {
        editorPresentations
        .navigationTitle(session.project.name)
        .alert("项目名称", isPresented: $renaming) {
            TextField("名称", text: $newName)
            Button("保存") { session.edit { $0.name = newName.isEmpty ? "未命名的旋律" : String(newName.prefix(60)) } }
            Button("取消", role: .cancel) {}
        }
        .confirmationDialog("导出音乐", isPresented: $export, titleVisibility: .visible) { Button(professional ? "项目包（含原始录音）" : "可继续编辑的完整备份") { exportProject() }; Button(professional ? "MIDI 文件" : "给其他音乐软件的旋律文件") { exportMIDI() }; Button(professional ? "WAV 音频" : "可以直接听的音频") { Task { await exportWAV() } }; Button("取消", role: .cancel) {} }
        .alert("发布服务尚未接入", isPresented: $publish) { Button("导出 WAV 分享") { Task { await exportWAV() } }; Button("继续创作", role: .cancel) {} } message: { Text("作品仍是本地草稿。你可以导出音频分享，不会显示模拟发布成功。") }
        .alert("保护你的创作", isPresented: $saveFailure) { Button("重试保存") { session.persist() }; Button("紧急导出项目包") { exportProject() }; Button("继续编辑", role: .cancel) {} } message: { Text("当前编辑仍保留在本次运行的内存中。返回草稿后也可重新打开重试；请勿强制退出或删除应用。") }
        .sheet(isPresented: $transpose) { KeyShiftSheet(project: session.project, recordingDirectory: session.store.recordingDirectory, professional: professional) { shifted in session.edit { $0 = shifted } }.presentationDetents([.large]) }
        .confirmationDialog("音符时值跨越小节", isPresented: Binding(get: { overflow != nil }, set: { if !$0 { overflow = nil } }), titleVisibility: .visible) {
            Button("后移到下一小节") { if let d = overflow { session.editNote { $0.start = (floor($0.start / 4) + 1) * 4; $0.duration = d }; overflow = nil } }
            Button("保留跨小节延音") { if let d = overflow { session.editNote { $0.duration = d; $0.tied = true }; overflow = nil } }
            Button("取消", role: .cancel) { overflow = nil }
        }
        .alert("重新分析会替换所选音轨的音符", isPresented: $reanalyze) { Button("确认重新分析", role: .destructive) { analyzeOriginal() }; Button("取消", role: .cancel) {} } message: { Text("当前轨的改动会被替换，可撤销。其他轨道不受影响；完整原声保留。若选择大模型，将发送所选原声片段至你的接口。") }
        .sheet(isPresented: $processing) { ProcessingView(stage: stage, onCancel: analysis == nil ? nil : { analysis?.cancel(); analysis = nil; processing = false }) }
        .alert("操作未完成", isPresented: Binding(get: { session.store.error != nil }, set: { if !$0 { session.store.error = nil } })) { Button("知道了", role: .cancel) { session.store.error = nil } } message: { Text(session.store.error ?? "") }
        .onDisappear { audio.stopPlayback(); analysis?.cancel(); session.persist() }
    }
    private var editorContent: some View {
        ScrollView {
                VStack(spacing: 18) {
                    editorHeader
                    melodyContent
                    playbackBar
                    Button { audio.stopPlayback(); transpose = true } label: { Label("换个调", systemImage: "arrow.up.arrow.down").font(.subheadline.weight(.medium)).frame(maxWidth: .infinity, minHeight: 48) }.buttonStyle(.bordered).accessibilityIdentifier("editor.keyShift")
                    editingTools
                }.padding(16).animation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.9), value: session.selectedNote)
            }.background(Palette.background(scheme))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { editorToolbar }
    }
    @ToolbarContentBuilder private var editorToolbar: some ToolbarContent {
                ToolbarItem(placement: .topBarTrailing) { StudioModeMenu() }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("重命名", systemImage: "pencil") { newName = session.project.name; renaming = true }
                        Button("保存到本机", systemImage: "checkmark") { if !session.persist() { saveFailure = true } }
                    } label: { Label("项目选项", systemImage: "ellipsis") }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Button { audio.stopPlayback(); session.undo() } label: { Image(systemName: "arrow.uturn.backward").frame(width: 44, height: 44) }.disabled(session.undoHistory.isEmpty).accessibilityLabel("撤销")
                    Button { audio.stopPlayback(); session.redo() } label: { Image(systemName: "arrow.uturn.forward").frame(width: 44, height: 44) }.disabled(session.redoHistory.isEmpty).accessibilityLabel("重做")
                    Spacer(); Button(professional ? "导出" : "保存与分享") { export = true }.frame(minHeight: 44); if professional { Button("发布") { publish = true }.frame(minHeight: 44) }
                }
            }
    @ViewBuilder private var editorHeader: some View {
                    HStack { Text(session.track.name).font(.subheadline.weight(.medium)); Spacer(); Button(session.saveStatus) { if !session.persist() { saveFailure = true } }.font(.caption).frame(minHeight: 44).foregroundStyle(.secondary).accessibilityIdentifier("editor.saveStatus") }
                    if professional { parameterBar }
                    if standard { Text("下面的线条表示旋律高低，往右就是后面的声音。你可以先听，再轻点一个片段修改。").font(.subheadline).foregroundStyle(.secondary).frame(maxWidth: .infinity, alignment: .leading) }
                    if rawMode == StudioMode.professional.rawValue { RecognitionEngineControl() }
                    Picker("编辑视图", selection: $multiTrack) { Text(professional ? "五线谱" : "旋律").tag(false); Text(professional ? "多轨编曲" : "各个声音").tag(true) }.pickerStyle(.segmented)
    }
    @ViewBuilder private var melodyContent: some View {
                    if multiTrack { trackList }
                    else {
                        if professional {
                        ScoreCanvas(notes: session.track.notes, bars: session.project.bars, selected: session.selectedNote, addMode: addMode,
                                    onSelect: { session.selectedNote = $0 }, onAdd: { session.addNote(midi: $0, start: $1) }, onMove: moveNote)
                        } else {
                            MelodyCanvas(notes: session.track.notes, beats: session.project.beats, selected: session.selectedNote, addMode: addMode, onSelect: { session.selectedNote = $0 }, onAdd: { session.addNote(midi: $0, start: $1) }, onMove: moveMelodyNote)
                        }
                        if session.selected != nil { noteInspector.transition(.opacity.combined(with: .move(edge: .top))) }
                        else if professional { Text(addMode ? "添加模式：点击谱面空白处放置音符。" : "点击音符修改 · 上下拖动调整谱位\n黄色轮廓提示识别不确定").font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center) }
                    }
    }
    @ViewBuilder private var editingTools: some View {
                    if !simpleMode { LazyVGrid(columns: [GridItem(.adaptive(minimum: 135))], spacing: 10) {
                        ToolCard(title: addMode ? "结束添加" : professional ? "添加音符" : "写一个声音", subtitle: professional ? "明确的添加模式" : "轻点旋律图，写下声音", symbol: "plus") { addMode.toggle() }.accessibilityIdentifier("editor.addNote")
                        ToolCard(title: "乐器", subtitle: session.track.instrument.name, symbol: session.track.instrument.symbol) { instruments = true }
                        ToolCard(title: professional ? "添加声部" : "添加声音", subtitle: professional ? "空轨、录唱或文件" : "再录一段，或导入文件", symbol: "square.stack.3d.up") { addTrack = true }.accessibilityIdentifier("editor.addTrack")
                        if professional { Menu {
                            Button("换个调") { transpose = true }
                            Button("复制主旋律为新轨道") { session.edit { p in var t = p.tracks[0]; t.id = UUID(); t.name += " · 副本"; t.notes = t.notes.map { var n = $0; n.id = UUID(); return n }; p.tracks.append(t) }; multiTrack = true }
                            Button("复制当前小节到结尾") { copyBar() }
                            Button("量化当前轨道") { let index = session.trackIndex; session.edit { p in for i in p.tracks[index].notes.indices { p.tracks[index].notes[i].start = (p.tracks[index].notes[i].start * 4).rounded() / 4; p.tracks[index].notes[i].duration = max(0.25, (p.tracks[index].notes[i].duration * 4).rounded() / 4) }; p.freeRhythm = false } }
                            if session.store.recordingURL(session.project, trackID: session.track.id) != nil {
                                Button("试听原始录音") { if let url = session.store.recordingURL(session.project, trackID: session.track.id) { do { try audio.playOriginal(url) } catch { session.store.error = error.localizedDescription } } }
                                Button("重新分析原始录音") { reanalyze = true }
                            }
                        } label: { HStack { Image(systemName: "ellipsis").frame(width: 30, height: 44); Text("更多工具").font(.subheadline) }.frame(maxWidth: .infinity, minHeight: 72).musicCard() } }
                    }
                    }
                    if simpleMode { HStack(spacing: 10) {
                        Button(addMode ? "完成添加" : "添加一个声音") { addMode.toggle() }.frame(minHeight: 44).buttonStyle(.bordered)
                        Button("换种声音") { instruments = true }.frame(minHeight: 44).buttonStyle(.bordered)
                    } }
                    if rawMode == StudioMode.simple.rawValue { Button(expandedTools ? "收起更多工具" : "展开更多工具") { expandedTools.toggle() }.frame(minHeight: 44) }
                    Label("原始录音与可编辑旋律分开保留", systemImage: "lock").font(.caption2).foregroundStyle(.secondary)
    }
    private var editorPresentations: some View {
        editorContent
        .sheet(isPresented: $instruments) { InstrumentSheet(selectedNote: session.selected != nil, bars: session.project.bars, current: session.track.instrument, professional: professional, onApply: applyInstrument) }
        .sheet(item: $share) { ShareSheet(url: $0.url) }
        .sheet(isPresented: $modelSettings) { NavigationStack { RecognitionSettingsView() } }
        .sheet(isPresented: $addTrack, onDismiss: performTrackChoice) { addTrackSheet }
        .fullScreenCover(item: $recording) { route in RecordingView(project: route.project, targetTrackID: route.id, onSaved: acceptRecording) { project in acceptRecording(project); recording = nil } }
        .confirmationDialog("在此音轨重新录唱？", isPresented: Binding(get: { recordConfirmation != nil }, set: { if !$0 { recordConfirmation = nil } }), titleVisibility: .visible) { Button("录唱并生成新音符") { if let id = recordConfirmation { recordConfirmation = nil; openRecording(id) } }; Button("取消", role: .cancel) { recordConfirmation = nil } } message: { Text("识别成功后替换此轨音符，可撤销；历史原声保留。其他音轨不受影响。") }
        .fileImporter(isPresented: $importer, allowedContentTypes: [.audio, .midi], allowsMultipleSelection: false) { result in
            switch result { case .success(let urls): if let url = urls.first { Task { await importToTrack(url) } }; case .failure(let error): session.store.error = error.localizedDescription }
        }

    }
    private var addTrackSheet: some View {
        NavigationStack {
            List {
                StartOption(title: professional ? "空白音轨" : "从头写旋律", subtitle: "独立写下一段新旋律", symbol: "music.note.list") { trackChoice = "blank"; addTrack = false }.accessibilityIdentifier("track.addBlank")
                StartOption(title: "哼唱录制", subtitle: "录下新声音，再整理成可编辑旋律", symbol: "mic") { trackChoice = "record"; addTrack = false }.accessibilityIdentifier("track.addRecording")
                StartOption(title: professional ? "导入音频或 MIDI" : "导入已有文件", subtitle: "保留原声，继续修改旋律", symbol: "square.and.arrow.down") { trackChoice = "import"; addTrack = false }.accessibilityIdentifier("track.addImport")
            }.navigationTitle(professional ? "添加声部" : "添加声音").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button("取消", role: .cancel) { addTrack = false } } }
        }.presentationDetents([.medium, .large]).presentationDragIndicator(.visible)
    }
    private func performTrackChoice() {
        guard let choice = trackChoice else { return }; trackChoice = nil
        guard let id = createTrack() else { return }
        if choice == "record" { openRecording(id) }
        if choice == "import" { importTrackID = id; importer = true }
    }
    private var parameterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) { HStack(spacing: 14) {
            Text("4/4 拍").font(.subheadline).padding(12).background(.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 10))
            Stepper("\(Int(session.project.bpm)) BPM", value: Binding(get: { Int(session.project.bpm) }, set: { bpm in audio.stopPlayback(); session.edit { $0.bpm = Double(bpm) } }), in: 30...300).fixedSize().font(.caption)
            Picker("调号", selection: Binding(get: { session.project.key }, set: { key in session.edit { $0.key = key } })) { ForEach(["C", "G", "D", "A", "F", "B♭"], id: \.self) { Text($0).tag($0) } }.pickerStyle(.menu)
            if session.project.freeRhythm { Text("自由节奏 · 未量化").font(.caption2).foregroundStyle(Palette.gold) }
        }.frame(minHeight: 44) }
    }
    private var playbackBar: some View {
        HStack(spacing: 20) {
            Button { audio.stopPlayback() } label: { Image(systemName: "backward.end").frame(width: 44, height: 44) }.accessibilityLabel("回到起点")
            Button { Task { do { audio.loop = loop; try await audio.play(session.project, recordingDirectory: session.store.recordingDirectory) } catch { session.store.error = error.localizedDescription } } } label: { PlaybackGlyph(playing: audio.playingID == session.project.id).frame(width: 44, height: 44) }.buttonStyle(.borderedProminent).accessibilityLabel("播放或暂停")
            Text(professional ? "第 \(min(session.project.bars, Int(audio.playbackSeconds * session.project.bpm / 240) + 1)) / \(session.project.bars) 小节" : musicTime(audio.playbackSeconds) + " / " + musicTime(session.project.seconds)).font(.caption).foregroundStyle(.secondary)
            Button { loop.toggle(); audio.loop = loop; audio.stopPlayback() } label: { Image(systemName: "repeat").foregroundStyle(loop ? Palette.gold : Color.secondary).frame(width: 44, height: 44) }.accessibilityLabel(loop ? "关闭循环" : "开启循环")
        }.frame(maxWidth: .infinity)
    }
    private func moveMelodyNote(_ id: UUID, _ steps: Int) {
        guard steps != 0 else { return }
        session.selectedNote = id; audio.stopPlayback()
        session.editNote { note in if let pitch = note.midi { note.midi = max(0, min(127, pitch + steps)); note.confidence = 1 } }
    }
    private var noteInspector: some View {
        Group { if professional { professionalInspector } else { friendlyInspector } }
    }
    private var friendlyInspector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("调整这一个声音").font(.headline)
            if standard { Text("升高或降低只改变这一处。想让整首一起变高或变低，请用「换个调」。").font(.caption).foregroundStyle(.secondary) }
            HStack {
                Button("低一点") { session.editNote { if let pitch = $0.midi { $0.midi = max(0, pitch - 1); $0.confidence = 1 } } }.frame(minHeight: 44)
                Button("高一点") { session.editNote { if let pitch = $0.midi { $0.midi = min(127, pitch + 1); $0.confidence = 1 } } }.frame(minHeight: 44)
                Spacer()
                Button { if let midi = session.selected?.midi { Task { do { try await audio.preview(session.track.instrument, midi: midi) } catch { session.store.error = error.localizedDescription } } } } label: { Image(systemName: "play").frame(width: 44, height: 44) }.accessibilityLabel("听这个声音")
            }.buttonStyle(.bordered)
            if standard {
                HStack { Button("短一点") { session.editNote { $0.duration = max(0.125, $0.duration / 2) } }; Button("长一点") { session.editNote { $0.duration = min(32, $0.duration * 2) } }; Spacer(); Button("删除", role: .destructive) { session.deleteNote() } }.frame(minHeight: 44)
                if session.selected?.confidence ?? 1 < 0.8 { Text("这一处可能没听清，可以对照录音再调整。").font(.caption).foregroundStyle(.secondary) }
                if let note = session.selected, let url = session.store.recordingURL(session.project, trackID: session.track.id) {
                    Button("听对应的原录音") { do { try audio.playOriginal(url, from: note.rawStart ?? max(0, note.start - (session.track.sourceStartBeat ?? 0)) * 60 / session.project.bpm, length: note.rawDuration ?? note.duration * 60 / session.project.bpm) } catch { session.store.error = error.localizedDescription } }.frame(minHeight: 44)
                }
            } else { Button("删除这个声音", role: .destructive) { session.deleteNote() }.frame(minHeight: 44) }
        }.musicCard(radius: 16)
    }
    private var professionalInspector: some View {
        VStack(alignment: .leading, spacing: 14) {
            if let note = session.selected {
                HStack { Text(note.pitchName).font(.headline); Text("\(note.duration, specifier: "%.2f") 拍").font(.caption).foregroundStyle(.secondary); Spacer(); Button { Task { do { if let midi = note.midi { try await audio.preview(session.track.instrument, midi: midi) } } catch { session.store.error = error.localizedDescription } } } label: { Image(systemName: "play").frame(width: 44, height: 44) }.accessibilityLabel("试听音符"); Button(role: .destructive) { audio.stopPlayback(); session.deleteNote() } label: { Image(systemName: "trash").frame(width: 44, height: 44) }.accessibilityLabel("删除音符") }
                HStack {
                    Picker("音高", selection: Binding(get: { session.selected?.midi ?? -1 }, set: { pitch in session.editNote { $0.midi = pitch == -1 ? nil : pitch; $0.confidence = 1 } })) { Text("休止符").tag(-1); ForEach(0...127, id: \.self) { pitch in Text(MusicNote(midi: pitch, start: 0, duration: 1).pitchName).tag(pitch) } }.pickerStyle(.menu)
                    Picker("时值", selection: Binding(get: { session.selected?.duration ?? 1 }, set: { changeDuration($0) })) { ForEach([0.25, 0.5, 0.75, 1, 1.5, 2, 3, 4], id: \.self) { Text("\($0, specifier: "%.2f") 拍").tag($0) }; if ![0.25, 0.5, 0.75, 1, 1.5, 2, 3, 4].contains(note.duration) { Text("原始时值").tag(note.duration) } }.pickerStyle(.menu)
                }
                ScrollView(.horizontal, showsIndicators: false) { HStack {
                    if session.store.recordingURL(session.project, trackID: session.track.id) != nil { Button("试听原声") { if let url = session.store.recordingURL(session.project, trackID: session.track.id) { do { try audio.playOriginal(url, from: note.rawStart ?? note.start * 60 / session.project.bpm, length: note.rawDuration ?? note.duration * 60 / session.project.bpm) } catch { session.store.error = error.localizedDescription } } }.frame(minHeight: 44) }
                    Button("↑ 八度") { session.editNote { if let m = $0.midi { $0.midi = min(127, m + 12) } } }.frame(minHeight: 44)
                    Button("↓ 八度") { session.editNote { if let m = $0.midi { $0.midi = max(0, m - 12) } } }.frame(minHeight: 44)
                    Button("拆分") { splitNote() }.frame(minHeight: 44)
                    Button("合并") { mergeNote() }.frame(minHeight: 44)
                }.font(.caption).buttonStyle(.bordered) }
                if note.confidence < 0.8 { Text("识别不确定，建议对照原声校正。").font(.caption2).foregroundStyle(.secondary) }
            }
        }.musicCard(radius: 16)
    }
    private var trackList: some View {
        VStack(spacing: 12) {
            ForEach(session.project.tracks) { track in
                TrackControlCard(track: track, beats: session.project.beats, professional: professional, simple: simpleMode,
                    canDelete: session.project.tracks.count > 1, hasSource: session.store.recordingURL(session.project, trackID: track.id) != nil,
                    onEdit: { selectTrack(track.id); multiTrack = false },
                    onUpdate: { replacement in audio.stopPlayback(); session.edit { p in if let i = p.tracks.firstIndex(where: { $0.id == track.id }) { p.tracks[i] = replacement } } },
                    onDelete: { audio.stopPlayback(); session.edit { $0.tracks.removeAll { $0.id == track.id } }; session.trackIndex = min(session.trackIndex, session.project.tracks.count - 1); session.selectedNote = nil },
                    onRecord: { requestRecording(track.id) }, onImport: { importTrackID = track.id; importer = true },
                    onAnalyze: { selectTrack(track.id); reanalyze = true }, onSpeech: { selectTrack(track.id); transcribeSpeech() },
                    onPlaySource: { playSource(track.id) }, onPlayHistory: { file in do { try audio.playOriginal(session.store.recordingDirectory.appendingPathComponent(file)) } catch { session.store.error = error.localizedDescription } })
            }
        }
    }
    private func changeDuration(_ d: Double) { if let note = session.selected, !session.project.freeRhythm, floor(note.start / 4) != floor((note.start + d - 0.001) / 4) { overflow = d } else { session.editNote { $0.duration = d } } }
    private func moveNote(_ id: UUID, _ steps: Int) {
        session.selectedNote = id
        session.editNote { note in guard note.midi != nil else { return }; let position = max(0, min(74, note.staffPosition + steps)); note.midi = max(0, min(127, position / 7 * 12 + [0, 2, 4, 5, 7, 9, 11][position % 7])); note.confidence = 1 }
    }
    private func splitNote() { guard let note = session.selected else { return }; let index = session.trackIndex; session.edit { p in guard let i = p.tracks[index].notes.firstIndex(where: { $0.id == note.id }) else { return }; p.tracks[index].notes[i].duration /= 2; var n = note; n.id = UUID(); n.start += note.duration / 2; n.duration /= 2; p.tracks[index].notes.append(n) } }
    private func mergeNote() {
        guard let note = session.selected else { return }; let sorted = session.track.notes.sorted { $0.start < $1.start }
        guard let i = sorted.firstIndex(where: { $0.id == note.id }), i + 1 < sorted.count else { return }; let next = sorted[i + 1], t = session.trackIndex
        session.edit { p in guard let n = p.tracks[t].notes.firstIndex(where: { $0.id == note.id }) else { return }; p.tracks[t].notes[n].duration = next.start + next.duration - note.start; p.tracks[t].notes.removeAll { $0.id == next.id } }
    }
    private func copyBar() { let bar = floor((session.selected?.start ?? 0) / 4), end = Double(session.project.bars) * 4, notes = session.track.notes.filter { floor($0.start / 4) == bar }, t = session.trackIndex; session.edit { p in p.tracks[t].notes += notes.map { var n = $0; n.id = UUID(); n.start = n.start - bar * 4 + end; return n } } }
    private func applyInstrument(_ instrument: Instrument, _ scope: String, _ start: Int, _ end: Int) {
        audio.stopPlayback(); let t = session.trackIndex, selected = session.selectedNote
        session.edit { p in
            if scope == "整条轨道" { p.tracks[t].instrument = instrument; p.tracks[t].useOriginalAudio = false }
            else {
                let chosen = p.tracks[t].notes.filter { scope == "选中音符" ? $0.id == selected : $0.start >= Double(start - 1) * 4 && $0.start < Double(end) * 4 }
                guard !chosen.isEmpty else { return }; let ids = Set(chosen.map(\.id)); p.tracks[t].notes.removeAll { ids.contains($0.id) }
                p.tracks.append(MusicTrack(name: scope == "选中音符" ? "选中音符配器" : "第 \(start)–\(end) 小节", instrument: instrument, volume: p.tracks[t].volume, notes: chosen, assignment: "移动原轨音符 · \(scope) · \(start)–\(end) 小节"))
            }
        }; instruments = false
    }
    private func exportProject() { do { share = ShareItem(url: try session.store.package(session.project)) } catch { session.store.error = error.localizedDescription } }
    private func exportMIDI() { do { let url = FileManager.default.temporaryDirectory.appendingPathComponent(session.project.id.uuidString + ".mid"); try MIDI.export(session.project).write(to: url, options: .atomic); share = ShareItem(url: url) } catch { session.store.error = error.localizedDescription } }
    private func exportWAV() async {
        processing = true; stage = "正在生成可以播放的音频…"; defer { processing = false }; let p = session.project, recordingRoot = session.store.recordingDirectory
        do { let data = try await Task.detached { try AudioRenderer.wav(p, recordingDirectory: recordingRoot) }.value; let url = FileManager.default.temporaryDirectory.appendingPathComponent(p.id.uuidString + ".wav"); try data.write(to: url, options: .atomic); share = ShareItem(url: url) } catch { session.store.error = error.localizedDescription }
    }
    private func analyzeOriginal() {
        let track = session.track
        guard let url = session.store.recordingURL(session.project, trackID: track.id) else { return }
        processing = true; stage = professional ? "正在使用 " + RecognitionSettings.load().engine.title + " 识谱…" : "正在分析这段录音，整理旋律…"
        let bpm = session.project.bpm, free = session.project.freeRhythm
        analysis = Task {
            do {
                let result = try await RecognitionService.analyze(url: url, bpm: bpm, free: free, start: track.trimStart ?? 0, end: track.trimEnd ?? .infinity)
                try Task.checkCancellation()
                session.edit { p in if let i = p.tracks.firstIndex(where: { $0.id == track.id }) {
                    p.tracks[i].notes = result.notes.map { var n = $0; n.start += track.sourceStartBeat ?? 0; return n }
                    p.tracks[i].transcript = result.transcript; p.tracks[i].recognitionSource = RecognitionSettings.load().engine.title; p.tracks[i].useOriginalAudio = false
                } }
            } catch { if !Task.isCancelled { session.store.error = error.localizedDescription } }
            processing = false; analysis = nil
        }
    }
    private func selectTrack(_ id: UUID) { if let i = session.project.tracks.firstIndex(where: { $0.id == id }) { session.trackIndex = i; session.selectedNote = nil } }
    @discardableResult private func createTrack() -> UUID? {
        guard session.project.tracks.count < 128 else { session.store.error = "一个项目最多支持 128 条音轨。"; return nil }
        audio.stopPlayback(); let track = MusicTrack(name: professional ? "新声部 \(session.project.tracks.count + 1)" : "声音 \(session.project.tracks.count + 1)")
        session.edit { $0.tracks.append(track) }; selectTrack(track.id); multiTrack = true; return track.id
    }
    private func requestRecording(_ id: UUID) {
        if let track = session.project.tracks.first(where: { $0.id == id }), !track.notes.isEmpty || track.recordingFile != nil { recordConfirmation = id }
        else { openRecording(id) }
    }
    private func openRecording(_ id: UUID) { audio.stopPlayback(); recording = TrackRecordingRoute(id: id, project: session.project) }
    private func acceptRecording(_ project: MusicProject) { session.edit { $0 = project }; session.selectedNote = nil; multiTrack = true }
    private func playSource(_ id: UUID) {
        if let track = session.project.tracks.first(where: { $0.id == id }), let url = session.store.recordingURL(session.project, trackID: id) {
            do { try audio.playOriginal(url, from: track.trimStart ?? 0, length: track.recordingSeconds.map { max(0, (track.trimEnd ?? $0) - (track.trimStart ?? 0)) }) } catch { session.store.error = error.localizedDescription }
        }
    }
    private func importToTrack(_ url: URL) async {
        guard let id = importTrackID else { return }; processing = true; stage = "正在检查并保存导入文件…"; audio.stopPlayback()
        defer { processing = false; importTrackID = nil }
        let access = url.startAccessingSecurityScopedResource(); defer { if access { url.stopAccessingSecurityScopedResource() } }
        do {
            guard (try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0) <= 256 * 1024 * 1024 else { throw MusicError.tooLarge }
            if ["mid", "midi"].contains(url.pathExtension.lowercased()) {
                let imported = try MIDI.parse(Data(contentsOf: url)); guard let first = imported.tracks.first else { throw MusicError.invalidMIDI }
                guard session.project.tracks.count + imported.tracks.count - 1 <= 128 else { throw MusicError.tooLarge }
                session.edit { p in if let i = p.tracks.firstIndex(where: { $0.id == id }) { let offset = p.tracks[i].sourceStartBeat ?? 0; p.tracks[i].notes += first.notes.map { var n = $0; n.start += offset; return n }; p.tracks[i].instrument = first.instrument; p.tracks[i].recognitionSource = "MIDI 导入 · 使用项目节拍" }; p.tracks.append(contentsOf: imported.tracks.dropFirst()) }
                return
            }
            let name = UUID().uuidString + "." + url.pathExtension.lowercased(), target = session.store.recordingDirectory.appendingPathComponent(name)
            try FileManager.default.copyItem(at: url, to: target)
            session.edit { p in if let i = p.tracks.firstIndex(where: { $0.id == id }) {
                if let old = p.tracks[i].recordingFile { p.tracks[i].sourceHistory = (p.tracks[i].sourceHistory ?? []) + [old] }
                p.tracks[i].recordingFile = name; p.tracks[i].recordingSeconds = nil; p.tracks[i].trimStart = nil; p.tracks[i].trimEnd = nil; p.tracks[i].useOriginalAudio = true
            } }
            let decoded = try await Task.detached { try AudioController.samples(from: target) }.value
            let duration = Double(decoded.samples.count) / decoded.sampleRate
            session.edit { p in if let i = p.tracks.firstIndex(where: { $0.id == id }) { p.tracks[i].recordingSeconds = duration } }
            stage = "原声已保存，正在生成候选乐谱…"
            do {
                let result = try await RecognitionService.analyze(url: target, bpm: session.project.bpm, free: true)
                try Task.checkCancellation()
                session.edit { p in if let i = p.tracks.firstIndex(where: { $0.id == id }) {
                    let offset = p.tracks[i].sourceStartBeat ?? 0
                    p.tracks[i].notes = result.notes.map { var n = $0; n.start += offset; return n }; p.tracks[i].transcript = result.transcript; p.tracks[i].recognitionSource = RecognitionSettings.load().engine.title; p.freeRhythm = true
                } }
            } catch { session.store.error = "原声已保留，可以独立回放、裁剪或手动写谱。识谱未完成：" + error.localizedDescription }
            selectTrack(id); multiTrack = true
        } catch { session.store.error = error.localizedDescription }
    }
    private func transcribeSpeech() {
        guard let url = session.store.recordingURL(session.project, trackID: session.track.id) else { return }
        let settings = RecognitionSettings.load()
        guard !settings.model.isEmpty, (try? ModelKeychain.read().isEmpty) == false else { modelSettings = true; return }
        let track = session.track; processing = true; stage = "正在把所选原声发送给你的模型识别文字…"
        analysis = Task {
            do {
                let result = try await RecognitionService.analyze(url: url, bpm: session.project.bpm, free: true, start: track.trimStart ?? 0, end: track.trimEnd ?? .infinity, settings: settings, speechOnly: true)
                try Task.checkCancellation()
                session.edit { p in if let i = p.tracks.firstIndex(where: { $0.id == track.id }) { p.tracks[i].transcript = result.transcript } }
                if result.transcript?.isEmpty != false { session.store.error = "模型未返回清晰文字。当前音符和原声仍保留。" }
            } catch { if !Task.isCancelled { session.store.error = error.localizedDescription } }
            processing = false; analysis = nil
        }
    }

}

struct ScoreCanvas: View {
    var notes: [MusicNote]; var bars: Int; var selected: UUID?; var addMode: Bool
    var onSelect: (UUID) -> Void; var onAdd: (Int, Double) -> Void; var onMove: (UUID, Int) -> Void
    private var width: CGFloat { max(800, CGFloat(bars) * 210 + 100) }
    private func point(_ note: MusicNote) -> CGPoint { CGPoint(x: 120 + note.start * 52.5, y: 128 - Double(note.staffPosition - 37) * 6) }
    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            ZStack(alignment: .topLeading) {
                Canvas { context, size in
                    var lines = Path(); for i in 0..<5 { let y = CGFloat(80 + i * 12); lines.move(to: CGPoint(x: 20, y: y)); lines.addLine(to: CGPoint(x: size.width - 20, y: y)) }; context.stroke(lines, with: .color(.gray.opacity(0.7)), lineWidth: 0.8)
                    context.draw(Text("𝄞").font(.system(size: 67)).foregroundStyle(Palette.ink), at: CGPoint(x: 49, y: 107))
                    context.draw(Text("4\n4").font(.system(size: 19)).foregroundStyle(Palette.ink), at: CGPoint(x: 87, y: 103))
                    for bar in 0..<max(3, bars) {
                        let x = CGFloat(110 + bar * 210); var line = Path(); line.move(to: CGPoint(x: x, y: 80)); line.addLine(to: CGPoint(x: x, y: 128)); context.stroke(line, with: .color(.gray), lineWidth: 0.7)
                        context.draw(Text("\(bar + 1)").font(.system(size: 11)).foregroundStyle(.gray), at: CGPoint(x: x + 8, y: 57))
                    }
                    for note in notes {
                        let p = point(note), color = note.id == selected ? Color(red: 0.64, green: 0.5, blue: 0.12) : Palette.ink
                        if note.midi == nil { context.draw(Text("𝄽").font(.system(size: 30)).foregroundStyle(color), at: CGPoint(x: p.x, y: 104)); continue }
                        if p.y > 128 { for y in stride(from: CGFloat(140), through: p.y + 2, by: 12) { var ledger = Path(); ledger.move(to: CGPoint(x: p.x - 12, y: y)); ledger.addLine(to: CGPoint(x: p.x + 12, y: y)); context.stroke(ledger, with: .color(color), lineWidth: 1) } }
                        if p.y < 80 { for y in stride(from: CGFloat(68), through: p.y - 2, by: -12) { var ledger = Path(); ledger.move(to: CGPoint(x: p.x - 12, y: y)); ledger.addLine(to: CGPoint(x: p.x + 12, y: y)); context.stroke(ledger, with: .color(color), lineWidth: 1) } }
                        let ellipse = Path(ellipseIn: CGRect(x: p.x - 7, y: p.y - 5, width: 14, height: 10)); if note.duration < 2 { context.fill(ellipse, with: .color(color)) } else { context.stroke(ellipse, with: .color(color), lineWidth: 1.7) }
                        if note.duration < 4 { var stem = Path(); stem.move(to: CGPoint(x: p.x + 6, y: p.y)); stem.addLine(to: CGPoint(x: p.x + 6, y: p.y - 32)); context.stroke(stem, with: .color(color), lineWidth: 1.5) }
                        if note.duration <= 0.5 { var flag = Path(); flag.move(to: CGPoint(x: p.x + 6, y: p.y - 32)); flag.addQuadCurve(to: CGPoint(x: p.x + 7, y: p.y - 10), control: CGPoint(x: p.x + 25, y: p.y - 21)); context.stroke(flag, with: .color(color), lineWidth: 1.7) }
                        if [1, 3, 6, 8, 10].contains((note.midi ?? 0) % 12) { context.draw(Text("♯").font(.system(size: 19)).foregroundStyle(color), at: CGPoint(x: p.x - 18, y: p.y)) }
                        if [0.75, 1.5, 3].contains(note.duration) { context.fill(Path(ellipseIn: CGRect(x: p.x + 12, y: p.y - 4, width: 4, height: 4)), with: .color(color)) }
                        if note.confidence < 0.8 { context.stroke(Path(ellipseIn: CGRect(x: p.x - 13, y: p.y - 11, width: 26, height: 22)), with: .color(Color(red: 0.74, green: 0.59, blue: 0.19)), lineWidth: 2) }
                        if note.tied { var tie = Path(); tie.move(to: CGPoint(x: p.x + 8, y: p.y + 12)); tie.addQuadCurve(to: CGPoint(x: min(size.width - 25, p.x + CGFloat(note.duration) * 52.5), y: p.y + 12), control: CGPoint(x: p.x + CGFloat(note.duration) * 26, y: p.y + 30)); context.stroke(tie, with: .color(color), lineWidth: 1.4) }
                    }
                }
                if addMode { Color.clear.contentShape(Rectangle()).gesture(SpatialTapGesture().onEnded { value in let beat = max(0, ((Double(value.location.x) - 120) / 52.5 * 4).rounded() / 4), position = max(0, min(74, Int(((128 - value.location.y) / 6).rounded()) + 37)), midi = position / 7 * 12 + [0, 2, 4, 5, 7, 9, 11][position % 7]; onAdd(min(127, midi), beat) }) }
                ForEach(notes) { note in let p = point(note); Button { onSelect(note.id) } label: { Color.clear.frame(width: 44, height: 44).contentShape(Rectangle()) }.position(p).accessibilityLabel("\(note.pitchName)，\(note.duration.formatted()) 拍").simultaneousGesture(DragGesture(minimumDistance: 12).onEnded { value in let steps = Int((-value.translation.height / 6).rounded()); if steps != 0 { onMove(note.id, steps) } }) }
            }.frame(width: width, height: 235).padding(.vertical, 8)
        }.background(Color(red: 0.92, green: 0.9, blue: 0.86), in: RoundedRectangle(cornerRadius: 20)).clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
struct PianoRoll: View {
    var notes: [MusicNote]; var beats: Double
    var body: some View { Canvas { context, size in
        for i in 0...8 { let x = size.width * CGFloat(i) / 8; var line = Path(); line.move(to: CGPoint(x: x, y: 0)); line.addLine(to: CGPoint(x: x, y: size.height)); context.stroke(line, with: .color(.gray.opacity(0.2)), lineWidth: 1) }
        for note in notes { guard let midi = note.midi else { continue }; let rect = CGRect(x: note.start / beats * size.width, y: max(4, min(size.height - 10, CGFloat(84 - midi) * 1.2)), width: max(3, note.duration / beats * size.width), height: 6); context.fill(Path(roundedRect: rect, cornerRadius: 2), with: .color(Palette.gold.opacity(0.8))) }
    }.accessibilityLabel("统一小节时间线，共 \(notes.count) 个音符") }
}
struct InstrumentSheet: View {
    @EnvironmentObject var audio: AudioController
    @EnvironmentObject var store: ProjectStore
    @Environment(\.dismiss) var dismiss
    var selectedNote = false; var bars = 1; var current: Instrument?
    var professional = true
    var onApply: ((Instrument, String, Int, Int) -> Void)?
    @State private var scope = "整条轨道"
    @State private var start = 1
    @State private var end = 1
    @State private var search = ""
    var body: some View {
        NavigationStack {
            List {
                Section { Text(professional ? "三种内置合成音色 · 离线可用 · 无采样素材" : "选择一种声音，先听听，再用到你的旋律里。无需联网。").font(.caption).foregroundStyle(.secondary) }
                ForEach(Instrument.allCases.filter { search.isEmpty || $0.name.contains(search) || $0.category.contains(search) }) { instrument in
                    HStack(spacing: 14) { Image(systemName: instrument.symbol).font(.title2).foregroundStyle(Palette.gold).frame(width: 34); VStack(alignment: .leading, spacing: 6) { Text(instrument.name).font(.headline); Text("\(instrument.category) · 已内置").font(.caption).foregroundStyle(.secondary) }; Spacer(); Button { Task { do { try await audio.preview(instrument) } catch { store.error = error.localizedDescription } } } label: { Image(systemName: "play").frame(width: 44, height: 44) }.buttonStyle(.borderless).accessibilityLabel("试听 \(instrument.name)"); if let onApply { Button(current == instrument && scope == "整条轨道" ? "已应用" : "应用") { onApply(instrument, scope, start, max(start, end)); dismiss() }.buttonStyle(.borderless).frame(minHeight: 44) } }
                }
                if onApply != nil {
                    Section("应用范围") {
                        Picker("范围", selection: $scope) { Text(professional ? "整条轨道" : "整段旋律").tag("整条轨道"); if selectedNote { Text(professional ? "选中音符" : "选中的声音").tag("选中音符") }; if professional { Text("指定小节").tag("指定小节") } }
                        if scope == "指定小节" { Stepper("第 \(start) 小节起", value: $start, in: 1...max(1, bars)); Stepper("第 \(max(start, end)) 小节止", value: $end, in: 1...max(1, bars)) }
                        Text(professional ? "分段应用会把对应音符移动到可见的新声部，保留具体配器范围。不会只修改全局乐器名称。" : "更换乐器不会改变旋律的高低和顺序。只更换选中的声音时，会把它单独列出来。").font(.caption).foregroundStyle(.secondary)
                    }
                }
            }.navigationTitle("乐器库").navigationBarTitleDisplayMode(.inline).searchable(text: $search, prompt: "搜索乐器")
                .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("完成") { audio.stopPlayback(); dismiss() } } }
        }.onAppear { end = max(1, bars) }.presentationDragIndicator(.visible)
    }
}
