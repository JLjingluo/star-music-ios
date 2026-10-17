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
    @State private var notationPreference: Bool?
    private var showScore: Bool { notationPreference ?? professional }
    @State private var instruments = false
    @State private var share: ShareItem?
    @State private var export = false
    @State private var transpose = false
    @State private var saveFailure = false
    @State private var renaming = false
    @State private var newName = ""
    @State private var noteEntry = false
    @State private var noteCorrection = false
    @State private var overflow: Double?
    @State private var processing = false
    @State private var analysis: Task<Void, Never>?
    @State private var activeTicket: AnalysisTicket?
    @State private var exportTask: Task<Void, Never>?
    @State private var exportIdentity = UUID()
    @State private var workspaceVisible = true
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
    @State private var preserveTiming = true
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
        .confirmationDialog("导出音乐", isPresented: $export, titleVisibility: .visible) { Button(professional ? "项目包（含原始录音）" : "可继续编辑的完整备份") { exportProject() }; Button(professional ? "MIDI 文件" : "给其他音乐软件的旋律文件") { exportMIDI() }; Button(professional ? "WAV 音频" : "可以直接听的音频") { startExport() }; Button("取消", role: .cancel) {} }
        .alert("保护你的创作", isPresented: $saveFailure) { Button("重试保存") { session.persist() }; Button("紧急导出项目包") { exportProject() }; Button("继续编辑", role: .cancel) {} } message: { Text(session.store.durableRecovery.contains(session.project.id) ? "正式保存未完成，已写入恢复快照，重启后会提示恢复。请重试保存或导出最新项目包。" : "最新修改尚未写入磁盘；恢复快照也未能保存。请立即导出最新项目包，并避免强制退出或删除应用。") }
        .sheet(isPresented: $transpose) { KeyShiftSheet(project: session.project, recordingDirectory: session.store.recordingDirectory, professional: professional) { shifted in session.edit { $0 = shifted } }.presentationDetents([.large]) }
        .confirmationDialog("音符时值跨越小节", isPresented: Binding(get: { overflow != nil }, set: { if !$0 { overflow = nil } }), titleVisibility: .visible) {
            Button("移到下一小节（会推迟开始）") { if let d = overflow { session.editNote { $0.start = (floor($0.start / 4) + 1) * 4; $0.duration = d }; overflow = nil } }
            Button("保留当前时间与长度") { if let d = overflow { session.editNote { $0.duration = d; $0.tied = true }; overflow = nil } }
            Button("取消", role: .cancel) { overflow = nil }
        }
        .alert("重新分析会替换所选音轨的音符", isPresented: $reanalyze) { Button("确认重新分析", role: .destructive) { analyzeOriginal() }; Button("取消", role: .cancel) {} } message: { Text("当前轨的改动会被替换，可撤销。其他轨道不受影响；完整原声保留。" + (RecognitionSettings.load().engine == .cloud ? "将发送从 \(session.track.trimStart ?? 0) 秒开始的所选原声至 \((try? RecognitionSettings.load().endpoint().host) ?? "你配置的服务")，可能产生费用。" : "在本机分析，不上传录音。")) }
        .sheet(isPresented: $processing) { ProcessingView(stage: stage, cancelTitle: exportTask == nil ? "取消分析，保留原录音" : "取消导出", onCancel: exportTask != nil ? { cancelExport() } : analysis != nil ? { cancelAnalysis() } : nil) }
        .alert("操作未完成", isPresented: Binding(get: { session.store.error != nil }, set: { if !$0 { session.store.error = nil } })) { Button("知道了", role: .cancel) { session.store.error = nil } } message: { Text(session.store.error ?? "") }
        .onChange(of: rawMode) { _, _ in addMode = false; expandedTools = false }
        .onAppear { workspaceVisible = true }
        .onDisappear { workspaceVisible = false; audio.stopPlayback(); cancelAnalysis(); session.cancelAllAnalysis(); cancelExport(); if recording == nil { session.persist() } }
    }
    private var editorContent: some View {
        ScrollView {
                VStack(spacing: 24) {
                    editorHeader
                    if let candidate = session.recognitionCandidates.first {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("识谱完成，当前音轨已有新修改").font(.headline)
                            Text("原来的改动没有被覆盖。你可以把候选旋律加入独立音轨后比较。").font(.caption).foregroundStyle(.secondary)
                            Button("加入独立音轨") { session.keepCandidateAsTrack(candidate); multiTrack = true }
                            Button("放弃这份候选", role: .destructive) { session.recognitionCandidates.removeAll { $0.id == candidate.id } }
                        }.musicCard()
                    }
                    melodyContent
                    editingTools
                }.padding(16).animation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.9), value: session.selectedNote)
            }.background(Palette.background(scheme))
            .safeAreaInset(edge: .bottom, spacing: 0) { playbackBar.padding(.horizontal, 16).padding(.vertical, 10).background(Palette.background(scheme)) }
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
                    Spacer(); Button { export = true } label: { Label("保存与分享", systemImage: "square.and.arrow.up") }.accessibilityLabel("保存与分享")
                }
            }
    @ViewBuilder private var editorHeader: some View {
                    HStack { Text(session.track.name).font(.subheadline.weight(.medium)); Spacer(); Button(session.saveStatus) { if !session.persist() { saveFailure = true } }.font(.caption).frame(minHeight: 44).foregroundStyle(.secondary).accessibilityIdentifier("editor.saveStatus") }
                    if professional { parameterBar }
                    if rawMode == StudioMode.professional.rawValue { RecognitionEngineControl() }
                    Picker("编辑视图", selection: $multiTrack) { Text(professional ? "五线谱" : "旋律").tag(false); Text(professional ? "多轨编曲" : "各条旋律").tag(true) }.pickerStyle(.segmented)
    }
    @ViewBuilder private var melodyContent: some View {
                    if multiTrack { trackList }
                    else {
                        if showScore {
                        ScoreCanvas(notes: session.track.notes, bars: session.project.bars, freeRhythm: session.project.freeRhythm, selected: session.selectedNote, addMode: addMode,
                                    onSelect: { session.selectedNote = $0; noteCorrection = true }, onAdd: { session.addNote(midi: $0, start: $1) }, onMove: moveNote)
                        } else {
                            MelodyCanvas(notes: session.track.notes, beats: session.project.beats, selected: session.selectedNote, addMode: addMode, onSelect: { session.selectedNote = $0; noteCorrection = true }, onAdd: { session.addNote(midi: $0, start: $1) }, onMove: moveMelodyNote)
                        }
                        if professional { Text(addMode ? "添加模式：点击谱面空白处放置音符。" : session.project.freeRhythm ? "保留原始演唱时长 · 简化参考谱，未强行量化\n问号标记建议对照原声校正" : "点击音符修改 · 上下拖动调整谱位\n问号标记建议对照原声校正").font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center) }
                    }
    }
    private var editingTools: some View {
        VStack(spacing: 16) {
            MusicGlassGroup {
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 12) { visibleTools }
                    VStack(spacing: 12) { visibleTools }
                }
            }
            if rawMode == StudioMode.simple.rawValue {
                Button(expandedTools ? "收起" : "更多工具") { expandedTools.toggle() }
                    .accessibilityLabel(expandedTools ? "收起更多工具" : "展开更多工具").frame(minHeight: 44)
            }
            if standard && !multiTrack {
                Text(addMode ? "轻点空白处添加声音，完成后再次点按加号。" : "从左往右是先后，越高的片段声音越高。轻点可修改。")
                    .font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
            }
        }
    }
    @ViewBuilder private var visibleTools: some View {
        Button { instruments = true } label: { Label(simpleMode ? "换种声音" : session.track.instrument.name, systemImage: session.track.instrument.symbol).frame(minHeight: 44) }.musicAction()
        if !simpleMode {
            Button { addMode.toggle() } label: { Label(addMode ? "完成添加" : "添加", systemImage: addMode ? "checkmark" : "plus").frame(minHeight: 44) }.musicAction().accessibilityIdentifier("editor.addNote")
            Menu {
                Button(professional ? "添加声部" : "添加一条旋律", systemImage: "square.stack.3d.up") { addTrack = true }.accessibilityIdentifier("editor.addTrack")
                Button(showScore ? "切换为旋律高低图" : "显示参考五线谱", systemImage: "music.note.list") { notationPreference = !showScore; multiTrack = false }
                Button("按选项添加声音", systemImage: "plus.circle") { noteEntry = true }.accessibilityIdentifier("editor.noteEntry")
                if professional {
                    Button("复制主旋律为新轨道") { session.edit { p in var t = p.tracks[0]; t.id = UUID(); t.name += " · 副本"; t.notes = t.notes.map { var n = $0; n.id = UUID(); return n }; p.tracks.append(t) }; multiTrack = true }
                    Button("复制当前小节到结尾") { copyBar() }
                    Button("量化当前轨道") { let index = session.trackIndex; session.edit { p in for i in p.tracks[index].notes.indices { p.tracks[index].notes[i].start = (p.tracks[index].notes[i].start * 4).rounded() / 4; p.tracks[index].notes[i].duration = max(0.25, (p.tracks[index].notes[i].duration * 4).rounded() / 4) }; p.freeRhythm = false } }
                    Button("分享音频") { startExport() }
                }
                if session.store.recordingURL(session.project, trackID: session.track.id) != nil {
                    Button("试听原始录音") { playSource(session.track.id) }
                    Button(RecognitionSettings.load().engine == .cloud ? "发送并生成乐谱" : "重新分析原始录音") { reanalyze = true }
                }
            } label: { Label("工具", systemImage: "ellipsis").frame(minHeight: 44) }.musicAction().accessibilityIdentifier("editor.toolsMenu")
        }
    }
    private var editorPresentations: some View {
        editorContent
        .sheet(isPresented: $noteCorrection) {
            NavigationStack {
                ScrollView { noteInspector.padding(20) }
                    .navigationTitle(professional ? "音符校正" : "调整这个片段").navigationBarTitleDisplayMode(.inline)
                    .toolbar { ToolbarItem(placement: .confirmationAction) { Button("完成") { noteCorrection = false } } }
            }.presentationDetents([.medium, .large]).presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $noteEntry) { NoteEntrySheet(bpm: session.project.bpm, startBeat: session.track.notes.map { $0.start + $0.duration }.max() ?? 0, professional: professional) { pitch, start, duration in session.addNote(midi: pitch, start: start, duration: duration) } }
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
                StartOption(title: "录制旋律", subtitle: "录下新声音，再整理成可编辑旋律", symbol: "mic") { trackChoice = "record"; addTrack = false }.accessibilityIdentifier("track.addRecording")
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
            Stepper("\(Int(session.project.bpm)) BPM", value: Binding(get: { Int(session.project.bpm) }, set: { bpm in
                audio.stopPlayback()
                do { let reference = preserveTiming || session.project.tracks.contains { $0.useOriginalAudio == true }; let p = try MusicEdits.changingBPM(session.project, to: Double(bpm), preserveTime: reference); session.edit { $0 = p } }
                catch { session.store.error = error.localizedDescription }
            }), in: 30...300).fixedSize().font(.caption)
            Menu {
                Button("节拍参考：保持实际播放时间") { preserveTiming = true }
                Button("改变乐器播放速度") { preserveTiming = false }.disabled(session.project.tracks.contains { $0.useOriginalAudio == true })
                Text("含原声时只调整节拍参考，不拉伸录音，也不改变播放速度。参考谱按实音记写，调号当前仅作项目标记；整体升降请用换个调。")
            } label: { Image(systemName: "info.circle").frame(width: 44, height: 44) }.accessibilityLabel("节拍参考与播放速度说明")
            Picker("调号", selection: Binding(get: { session.project.key }, set: { key in session.edit { $0.key = key } })) { ForEach(["C", "G", "D", "A", "F", "B♭"], id: \.self) { Text($0).tag($0) } }.pickerStyle(.menu)
            if session.project.freeRhythm { Text("自由节奏 · 未量化").font(.caption2).foregroundStyle(Palette.gold) }
        }.frame(minHeight: 44) }
    }
    private var playbackBar: some View {
        VStack(spacing: 8) {
            MusicGlassGroup {
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 12) { if professional { restartAction }; playAction; shiftAction; if professional { loopAction } }.fixedSize(horizontal: true, vertical: false)
                    VStack(spacing: 8) { HStack(spacing: 12) { playAction; shiftAction }; if professional { HStack(spacing: 12) { restartAction; loopAction } } }
                }
            }
            Text(musicTime(audio.playbackSeconds) + " / " + musicTime(session.project.seconds)).font(.caption.monospacedDigit()).foregroundStyle(.secondary)
        }.frame(maxWidth: .infinity)
    }
    private var restartAction: some View { Button { audio.stopPlayback() } label: { Image(systemName: "backward.end").frame(width: 32, height: 44) }.musicAction().accessibilityLabel("回到起点") }
    private var playAction: some View {
        Button { Task { do { try await audio.play(session.project, recordingDirectory: session.store.recordingDirectory, loop: loop) } catch { session.store.error = error.localizedDescription } } } label: {
            Group { if audio.renderingID == session.project.id { ProgressView() } else { PlaybackGlyph(playing: audio.playingID == session.project.id && !audio.paused) } }.frame(width: 44, height: 44)
        }.musicAction(prominent: true).accessibilityLabel(audio.renderingID == session.project.id ? "取消试听准备" : audio.playingID == session.project.id && !audio.paused ? "暂停" : "播放")
    }
    private var shiftAction: some View { Button { audio.stopPlayback(); transpose = true } label: { Label("换个调", systemImage: "arrow.up.arrow.down").frame(minHeight: 44) }.musicAction().accessibilityIdentifier("editor.keyShift") }
    private var loopAction: some View { Button { loop.toggle(); audio.stopPlayback() } label: { Image(systemName: "repeat").frame(width: 32, height: 44) }.musicAction().accessibilityLabel(loop ? "关闭循环" : "开启循环").accessibilityAddTraits(loop ? .isSelected : []) }
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
            if standard { Text("升高或降低只改变这一处。想让整首一起变高或变低，请用「换个调」。").font(.caption).foregroundStyle(.secondary) }
            HStack {
                Button("低一点") { session.editNote { if let pitch = $0.midi { $0.midi = max(0, pitch - 1); $0.confidence = 1 } } }.frame(minHeight: 44)
                Button("高一点") { session.editNote { if let pitch = $0.midi { $0.midi = min(127, pitch + 1); $0.confidence = 1 } } }.frame(minHeight: 44)
                Spacer()
                Button { if let midi = session.selected?.midi { Task { do { try await audio.preview(session.track.instrument, midi: midi) } catch { session.store.error = error.localizedDescription } } } } label: { Image(systemName: "play").frame(width: 44, height: 44) }.accessibilityLabel("试听这个片段")
            }.buttonStyle(.bordered)
            if standard {
                HStack { Button("短一点") { session.editNote { $0.duration = max(0.125, $0.duration / 2) } }; Button("长一点") { session.editNote { $0.duration = min(32, $0.duration * 2) } }; Spacer(); Button("删除", role: .destructive) { session.deleteNote() } }.frame(minHeight: 44)
                if session.selected?.confidence ?? 1 < 0.8 { Text("这一处可能没听清，可以对照录音再调整。").font(.caption).foregroundStyle(.secondary) }
                if let note = session.selected, let url = session.store.noteRecordingURL(session.project, trackID: session.track.id, note: note) {
                    Button("听对应的原录音") { do { try audio.playOriginal(url, from: MusicEdits.originalStart(note, track: session.track, bpm: session.project.bpm), length: note.rawDuration ?? note.duration * 60 / session.project.bpm) } catch { session.store.error = error.localizedDescription } }.frame(minHeight: 44)
                }
            } else { Button("删除这个片段", role: .destructive) { session.deleteNote() }.frame(minHeight: 44) }
        }
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
                    if session.store.recordingURL(session.project, trackID: session.track.id) != nil { Button("试听原声") { if let url = session.store.noteRecordingURL(session.project, trackID: session.track.id, note: note) { do { try audio.playOriginal(url, from: MusicEdits.originalStart(note, track: session.track, bpm: session.project.bpm), length: note.rawDuration ?? note.duration * 60 / session.project.bpm) } catch { session.store.error = error.localizedDescription } } }.frame(minHeight: 44) }
                    Button("↑ 八度") { session.editNote { if let m = $0.midi { $0.midi = min(127, m + 12) } } }.frame(minHeight: 44)
                    Button("↓ 八度") { session.editNote { if let m = $0.midi { $0.midi = max(0, m - 12) } } }.frame(minHeight: 44)
                    Button("拆分") { splitNote() }.frame(minHeight: 44)
                    Button("合并") { mergeNote() }.frame(minHeight: 44)
                }.font(.caption).buttonStyle(.bordered) }
                if note.confidence < 0.8 { Text("识别不确定，建议对照原声校正。").font(.caption2).foregroundStyle(.secondary) }
            }
        }
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
    private func splitNote() {
        guard let note = session.selected else { return }; let index = session.trackIndex
        let parts = MusicEdits.split(note)
        session.edit { p in guard let i = p.tracks[index].notes.firstIndex(where: { $0.id == note.id }) else { return }; p.tracks[index].notes[i] = parts.0; p.tracks[index].notes.append(parts.1) }
    }
    private func mergeNote() {
        guard let note = session.selected else { return }; let sorted = session.track.notes.sorted { $0.start < $1.start }
        guard let i = sorted.firstIndex(where: { $0.id == note.id }), i + 1 < sorted.count else { return }; let next = sorted[i + 1], t = session.trackIndex
        do {
            let merged = try MusicEdits.merged(note, next)
            session.edit { p in guard let n = p.tracks[t].notes.firstIndex(where: { $0.id == note.id }) else { return }; p.tracks[t].notes[n] = merged; p.tracks[t].notes.removeAll { $0.id == next.id } }
        } catch { session.store.error = error.localizedDescription }
    }
    private func copyBar() { let bar = floor((session.selected?.start ?? 0) / 4), end = Double(session.project.bars) * 4, notes = session.track.notes.filter { floor($0.start / 4) == bar }, t = session.trackIndex; session.edit { p in p.tracks[t].notes += notes.map { var n = $0; n.id = UUID(); n.start = n.start - bar * 4 + end; return n } } }
    private func applyInstrument(_ instrument: Instrument, _ scope: String, _ start: Int, _ end: Int) {
        audio.stopPlayback(); let t = session.trackIndex, selected = session.selectedNote
        session.edit { p in
            if scope == "整条轨道" { p.tracks[t].instrument = instrument; p.tracks[t].useOriginalAudio = false }
            else {
                let chosen = p.tracks[t].notes.filter { scope == "选中音符" ? $0.id == selected : $0.start >= Double(start - 1) * 4 && $0.start < Double(end) * 4 }
                guard !chosen.isEmpty else { return }
                let pieces = MusicEdits.partition(p.tracks[t], ids: Set(chosen.map(\.id)), name: scope == "选中音符" ? "选中的片段" : "第 \(start)–\(end) 小节")
                p.tracks[t] = pieces.0
                var part = pieces.1; part.instrument = instrument; part.assignment = "移动原轨音符 · \(scope) · \(start)–\(end) 小节"
                p.tracks.append(part)
            }
        }
        if scope != "整条轨道", let last = session.project.tracks.last { selectTrack(last.id); multiTrack = true }
        instruments = false
    }
    private func exportProject() {
        guard !processing else { return }
        processing = true
        exportTask = Task {
            let identity = UUID(); exportIdentity = identity; processing = true; stage = "正在整理完整项目备份…"
            defer { if exportIdentity == identity { processing = false; exportTask = nil } }
            do {
                let url = try await session.store.packageAsync(session.project, preferRecovery: false)
                guard !Task.isCancelled, exportIdentity == identity, workspaceVisible else { try? FileManager.default.removeItem(at: url); return }
                share = ShareItem(url: url)
            } catch { if !Task.isCancelled && exportIdentity == identity { session.store.error = error.localizedDescription } }
        }
    }
    private func exportMIDI() { do { let url = FileManager.default.temporaryDirectory.appendingPathComponent(session.project.id.uuidString + ".mid"); try MIDI.export(session.project).write(to: url, options: .atomic); share = ShareItem(url: url) } catch { session.store.error = error.localizedDescription } }
    private func startExport() {
        guard !processing else { return }
        processing = true
        exportTask = Task { await exportWAV() }
    }
    private func cancelExport() { exportIdentity = UUID(); exportTask?.cancel(); exportTask = nil; if activeTicket == nil { processing = false } }
    private func exportWAV() async {
        let identity = UUID(); exportIdentity = identity
        processing = true; stage = "正在分段生成可以播放的音频…"
        let p = session.project, recordingRoot = session.store.recordingDirectory
        defer { if identity == exportIdentity { processing = false; exportTask = nil } }
        do {
            let url = try await AudioRenderer.renderFile(p, recordingDirectory: recordingRoot)
            guard !Task.isCancelled, identity == exportIdentity, workspaceVisible else { try? FileManager.default.removeItem(at: url); return }
            share = ShareItem(url: url)
        } catch { if !Task.isCancelled && identity == exportIdentity { session.store.error = error.localizedDescription } }
    }
    private func cancelAnalysis() {
        if let ticket = activeTicket { session.cancelAnalysis(ticket) }
        activeTicket = nil; analysis?.cancel(); analysis = nil; processing = false
    }
    private func analyzeOriginal() { startAnalysis(speechOnly: false) }
    private func startAnalysis(speechOnly: Bool) {
        cancelAnalysis()
        let settings = RecognitionSettings.load(), track = session.track
        guard let url = session.store.recordingURL(session.project, trackID: track.id) else { return }
        do {
            let ticket = try session.beginAnalysis(trackID: track.id); activeTicket = ticket
            processing = true
            stage = settings.engine == .cloud || speechOnly ? "正在发送所选原声至 \((try? settings.endpoint().host) ?? "你的模型服务")…" : "正在分析这段录音，整理旋律…"
            analysis = Task {
                do {
                    let result = try await RecognitionService.analyze(url: url, bpm: ticket.bpm, free: ticket.freeRhythm, start: track.trimStart ?? 0, end: track.trimEnd ?? .infinity, settings: settings, speechOnly: speechOnly)
                    try Task.checkCancellation()
                    _ = session.finishAnalysis(ticket, result: result, engine: settings.engine.title, transcriptOnly: speechOnly)
                } catch { if !Task.isCancelled && activeTicket?.id == ticket.id { session.store.error = error.localizedDescription } }
                if activeTicket?.id == ticket.id { processing = false; activeTicket = nil; analysis = nil }
            }
        } catch { session.store.error = error.localizedDescription }
    }
    private func selectTrack(_ id: UUID) { if let i = session.project.tracks.firstIndex(where: { $0.id == id }) { session.trackIndex = i; session.selectedNote = nil } }
    @discardableResult private func createTrack() -> UUID? {
        guard session.project.tracks.count < 128 else { session.store.error = "一个项目最多支持 128 条音轨。"; return nil }
        audio.stopPlayback(); let track = MusicTrack(name: professional ? "新声部 \(session.project.tracks.count + 1)" : "旋律 \(session.project.tracks.count + 1)")
        session.edit { $0.tracks.append(track) }; selectTrack(track.id); multiTrack = true; return track.id
    }
    private func requestRecording(_ id: UUID) {
        if let track = session.project.tracks.first(where: { $0.id == id }), !track.notes.isEmpty || track.recordingFile != nil { recordConfirmation = id }
        else { openRecording(id) }
    }
    private func openRecording(_ id: UUID) { audio.stopPlayback(); recording = TrackRecordingRoute(id: id, project: session.project) }
    private func acceptRecording(_ project: MusicProject) { session.acceptRecording(project); session.selectedNote = nil; multiTrack = true }
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
                var imported = try MIDI.parse(Data(contentsOf: url)); let ratio = session.project.bpm / imported.bpm; for t in imported.tracks.indices { for n in imported.tracks[t].notes.indices { imported.tracks[t].notes[n].start *= ratio; imported.tracks[t].notes[n].duration *= ratio } }; guard let first = imported.tracks.first else { throw MusicError.invalidMIDI }
                guard session.project.tracks.count + imported.tracks.count - 1 <= 128 else { throw MusicError.tooLarge }
                session.edit { p in if let i = p.tracks.firstIndex(where: { $0.id == id }) { let offset = p.tracks[i].sourceStartBeat ?? 0; p.tracks[i].notes += first.notes.map { var n = $0; n.start += offset; return n }; p.tracks[i].instrument = first.instrument; p.tracks[i].recognitionSource = "MIDI 导入 · 保留实际播放时间，不吸附网格" }; p.tracks.append(contentsOf: imported.tracks.dropFirst()) }
                return
            }
            let prepared = try await AudioImport.prepare(url, directory: session.store.recordingDirectory)
            guard workspaceVisible, session.project.tracks.contains(where: { $0.id == id }) else { prepared.discard(); return }
            var committed = false; defer { if !committed { prepared.discard() } }
            let name = prepared.name, target = prepared.url
            guard session.edit({ p in if let i = p.tracks.firstIndex(where: { $0.id == id }) {
                MusicEdits.attachOriginal(&p.tracks[i], file: name, duration: prepared.duration); p.freeRhythm = true
            } }) else { throw MusicError.invalidProject }
            committed = true
            if RecognitionSettings.load().engine == .cloud {
                selectTrack(id); multiTrack = true; session.store.error = "原声已保存在本机，尚未上传。请主动选择发送并生成乐谱。"; return
            }
            stage = "原声已保存，正在生成候选乐谱…"
            do {
                let ticket = try session.beginAnalysis(trackID: id), settings = RecognitionSettings.load()
                defer { session.cancelAnalysis(ticket) }
                let result = try await RecognitionService.analyze(url: target, bpm: ticket.bpm, free: true, settings: settings)
                try Task.checkCancellation()
                _ = session.finishAnalysis(ticket, result: result, engine: settings.engine.title)
            } catch { session.store.error = "原声已保留，可以独立回放、裁剪或手动写谱。识谱未完成：" + error.localizedDescription }
            selectTrack(id); multiTrack = true
        } catch { session.store.error = error.localizedDescription }
    }
    private func transcribeSpeech() {
        let settings = RecognitionSettings.load()
        guard !settings.model.isEmpty, (try? ModelKeychain.read(for: settings).isEmpty) == false else { modelSettings = true; return }
        startAnalysis(speechOnly: true)
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
                Section { Text(professional ? "三种内置合成音色 · 离线可用 · 无采样素材" : "三种内置乐器为合成音色，可先试听，离线使用。").font(.caption).foregroundStyle(.secondary) }
                ForEach(Instrument.allCases.filter { search.isEmpty || $0.name.contains(search) || $0.category.contains(search) }) { instrument in
                    HStack(spacing: 14) { Image(systemName: instrument.symbol).font(.title2).foregroundStyle(Palette.gold).frame(width: 34); VStack(alignment: .leading, spacing: 6) { Text(instrument.name).font(.headline); Text("\(instrument.category) · 已内置").font(.caption).foregroundStyle(.secondary) }; Spacer(); Button { Task { do { try await audio.preview(instrument) } catch { store.error = error.localizedDescription } } } label: { Image(systemName: "play").frame(width: 44, height: 44) }.buttonStyle(.borderless).accessibilityLabel("试听 \(instrument.name)"); if let onApply { Button(current == instrument && scope == "整条轨道" ? "已应用" : "应用") { onApply(instrument, scope, start, max(start, end)); dismiss() }.buttonStyle(.borderless).frame(minHeight: 44) } }
                }
                if onApply != nil {
                    Section("应用范围") {
                        Picker("范围", selection: $scope) { Text(professional ? "整条轨道" : "整段旋律").tag("整条轨道"); if selectedNote { Text(professional ? "选中音符" : "选中的片段").tag("选中音符") }; if professional { Text("指定小节").tag("指定小节") } }
                        if scope == "指定小节" { Stepper("第 \(start) 小节起", value: $start, in: 1...max(1, bars)); Stepper("第 \(max(start, end)) 小节止", value: $end, in: 1...max(1, bars)) }
                        Text(professional ? "分段应用会把对应音符移动到可见的新声部，保留具体配器范围。不会只修改全局乐器名称。" : "更换乐器不改高低和节奏。只更换一部分时，会新建一条独立音轨并移入所选片段，可一次撤销。").font(.caption).foregroundStyle(.secondary)
                    }
                }
            }.navigationTitle("乐器库").navigationBarTitleDisplayMode(.inline).searchable(text: $search, prompt: "搜索乐器")
                .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("完成") { audio.stopPlayback(); dismiss() } } }
        }.onAppear { end = max(1, bars) }.presentationDragIndicator(.visible)
    }
}
