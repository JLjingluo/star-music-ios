import SwiftUI

@MainActor struct RecordingView: View {
    @EnvironmentObject var store: ProjectStore
    @EnvironmentObject var audio: AudioController
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var scheme
    @State var project: MusicProject
    let initialProject: MusicProject
    var targetTrackID: UUID?
    var onEdit: (MusicProject) -> Void
    var onSaved: ((MusicProject) -> Void)?
    @AppStorage("studioMode") private var rawMode = StudioMode.standard.rawValue
    @State private var completed = false
    @State private var createdFile: String?
    @State private var beat = false
    @State private var permission = false
    @State private var leaving = false
    @State private var processing = false
    @State private var stage = ""
    @State private var task: Task<Void, Never>?
    @State private var lastSave = 0
    @State private var failedAnalysis = false
    @State private var analysisError: String?
    @State private var trim = false
    @State private var trimStart = 0.0
    @State private var trimEnd = 10.0
    @State private var error: String?
    init(project: MusicProject, targetTrackID: UUID? = nil, onSaved: ((MusicProject) -> Void)? = nil, onEdit: @escaping (MusicProject) -> Void) {
        _project = State(initialValue: project); initialProject = project; self.targetTrackID = targetTrackID; self.onSaved = onSaved; self.onEdit = onEdit
    }
    private var trackIndex: Int { targetTrackID.flatMap { id in project.tracks.firstIndex { $0.id == id } } ?? 0 }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text(audio.recordingState == .ready ? "准备好了，就哼唱吧。" : "把脑海里的旋律，留下来。").font(.title2.weight(.semibold)).multilineTextAlignment(.center)
                    Text(musicTime(audio.elapsed)).font(.system(.largeTitle, design: .monospaced).weight(.light)).monospacedDigit().accessibilityLabel("录音时长 \(Int(audio.elapsed)) 秒")
                    Label(statusText, systemImage: audio.recordingState == .recording ? "record.circle" : "mic").font(.caption).foregroundStyle(audio.recordingState == .recording ? Color(red: 0.89, green: 0.58, blue: 0.53) : Color.secondary)
                    Waveform(levels: audio.levels).frame(height: 125).musicCard(radius: 28)
                    if rawMode == StudioMode.professional.rawValue { RecognitionEngineControl() } else if RecognitionSettings.load().engine == .cloud { Text("主动识别会把录音发送到你配置的模型服务。").font(.caption).foregroundStyle(.secondary) }
                    if audio.recordingState == .ready {
                        Picker("录制模式", selection: $beat) { Text("自由哼唱").tag(false); Text("跟着节奏唱").tag(true) }.pickerStyle(.segmented)
                        if beat { Stepper(rawMode == StudioMode.professional.rawValue ? "\(Int(project.bpm)) BPM" : "每分钟 \(Int(project.bpm)) 下节奏声", value: $project.bpm, in: 40...240, step: 1); Text("建议使用耳机，避免节拍声进入录音。").font(.caption2).foregroundStyle(.secondary) }
                        Button { Task { await begin() } } label: { Label("开始录音", systemImage: "record.circle").frame(minHeight: 44) }.musicAction(prominent: true, prominentTint: .red).accessibilityIdentifier("recording.start")
                    } else if audio.recordingState != .finished {
                        HStack(spacing: 16) {
                            Button(audio.recordingState == .recording ? "暂停" : "继续录制") { if audio.recordingState == .recording { audio.pauseRecording(); saveRecordingMetadata() } else { do { try audio.resumeRecording() } catch { self.error = error.localizedDescription } } }.musicAction().frame(minHeight: 44)
                            GoldButton(title: RecognitionSettings.load().engine == .cloud ? "发送原声并识别" : rawMode == StudioMode.professional.rawValue ? "完成并生成乐谱" : "完成，整理旋律", symbol: "checkmark") { finishAndAnalyze() }
                        }
                    } else { GoldButton(title: "整理这段旋律", symbol: "music.note") { finishAndAnalyze() } }
                    DisclosureGroup("录音小提示") {
                        Text("在安静环境中哼唱一条旋律，可提高准确度。暂不支持复杂歌曲。原录音保存在本机，最多分析 5 分钟。")
                            .font(.caption).foregroundStyle(.secondary).padding(.top, 8)
                    }.font(.subheadline).foregroundStyle(.secondary)
                }.padding(20).frame(maxWidth: 850).frame(maxWidth: .infinity)
            }.background(Palette.background(scheme)).navigationTitle(project.name).navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button("取消", role: .cancel) { if createdFile != nil { audio.pauseRecording(); saveRecordingMetadata(); leaving = true } else { dismiss() } }.accessibilityIdentifier("recording.cancel") } }
        }
        .interactiveDismissDisabled(createdFile != nil)
        .onAppear { audio.stopPlayback(); audio.resetRecording() }
        .onDisappear { audio.finishRecording(); task?.cancel(); if !completed { onSaved?(project) } }
        .onChange(of: audio.elapsed) { _, elapsed in
            if Int(elapsed) >= lastSave + 5 { lastSave = Int(elapsed); saveRecordingMetadata() }
            if elapsed >= 300 && audio.recordingState == .recording { audio.pauseRecording(); saveRecordingMetadata(); error = "已达到首版 5 分钟的分析范围，录音已暂停，请完成录制。" }
        }
        .onChange(of: audio.recordingState) { _, state in if state == .paused { saveRecordingMetadata() } }
        .alert("需要麦克风权限", isPresented: $permission) { Button("前往系统设置") { if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) } }; Button("空白创作") { edit() }; Button("取消", role: .cancel) {} } message: { Text("麦克风仅用于录制你的哼唱，原始录音保存在本机。你也可以不使用麦克风，直接写谱。") }
        .confirmationDialog("保留这段灵感吗？", isPresented: $leaving, titleVisibility: .visible) {
            Button("保存并退出") { audio.finishRecording(); if saveRecordingMetadata() { dismiss() } }
            if audio.recordingState == .paused { Button("继续录制") { do { try audio.resumeRecording() } catch { self.error = error.localizedDescription } } }
            Button("放弃本次录音", role: .destructive) { discardTake() }
            Button("取消", role: .cancel) {}
        }
        .sheet(isPresented: $processing) { ProcessingView(stage: stage, cancelTitle: "取消分析，保留原始录音") { task?.cancel(); task = nil; processing = false; if saveRecordingMetadata() { edit() } } }
        .alert("识谱未完成", isPresented: $failedAnalysis) { Button("重新分析") { analyze() }; Button("截取片段") { trimEnd = project.tracks[trackIndex].recordingSeconds ?? 10; trim = true }; Button("手动写谱") { edit() } } message: { Text(analysisError ?? "原始录音仍保留，可重新分析或手动写谱。") }
        .sheet(isPresented: $trim) {
            NavigationStack {
                Form {
                    Section { Text("只分析这个范围，完整原录音仍会保留。") }
                    Section("时间范围") {
                        Stepper("起始 \(trimStart, specifier: "%.1f") 秒", value: $trimStart, in: 0...max(0, (project.tracks[trackIndex].recordingSeconds ?? 10) - 0.2), step: 0.1)
                        Stepper("结束 \(trimEnd, specifier: "%.1f") 秒", value: $trimEnd, in: 0.2...max(0.2, project.tracks[trackIndex].recordingSeconds ?? 10), step: 0.1)
                    }
                    Button("分析片段") { if trimEnd > trimStart { trim = false; analyze(start: trimStart, end: trimEnd) } else { error = "结束时间需要大于开始时间。" } }
                }.navigationTitle("截取清晰片段").navigationBarTitleDisplayMode(.inline)
                    .toolbar { ToolbarItem(placement: .cancellationAction) { Button("取消", role: .cancel) { trim = false } } }
            }.presentationDetents([.medium, .large])
        }
        .alert("录音提示", isPresented: Binding(get: { error != nil || audio.interruptionMessage != nil }, set: { if !$0 { error = nil; audio.interruptionMessage = nil } })) { Button("知道了", role: .cancel) { error = nil; audio.interruptionMessage = nil } } message: { Text(error ?? audio.interruptionMessage ?? "") }
    }
    private var statusText: String { switch audio.recordingState { case .ready: "首次录音会请求麦克风授权"; case .recording: "正在录音"; case .paused: "已暂停 · 原始录音保留"; case .finished: "录制已结束 · 原声保留" } }
    private func begin() async {
        let name = UUID().uuidString + ".wav", url = store.recordingDirectory.appendingPathComponent(name)
        do {
            audio.metronomeBPM = beat ? project.bpm : nil; try await audio.beginRecording(to: url); createdFile = name
            let index = trackIndex
            if project.tracks[index].recordingFile == nil, index == 0 { project = project.migratingLegacyRecording() }
            MusicEdits.attachOriginal(&project.tracks[index], file: name, duration: 0)
            project.syncLegacyRecording()
            project.freeRhythm = !beat; saveRecordingMetadata()
        }
        catch MusicError.permission { permission = true }
        catch { self.error = error.localizedDescription }
    }
    @discardableResult private func saveRecordingMetadata() -> Bool {
        project.tracks[trackIndex].recordingSeconds = audio.elapsed
        if trackIndex == 0 { project.recordingSeconds = audio.elapsed }; project.updated = Date()
        do { try store.save(project); return true } catch { self.error = error.localizedDescription; return false }
    }
    private func finishAndAnalyze() { guard audio.elapsed > 0.1 else { error = "请先录制一段旋律。"; return }; audio.finishRecording(); if saveRecordingMetadata() { analyze() } }
    private func analyze(start: Double = 0, end: Double = .infinity) {
        guard let url = store.recordingURL(project, trackID: project.tracks[trackIndex].id) else { return }; processing = true
        let settings = RecognitionSettings.load(), index = trackIndex
        stage = settings.engine == .cloud ? "正在发送所选原声至你的音频模型…" : rawMode == StudioMode.professional.rawValue ? "正在使用 \(settings.engine.title) 分析音高与节奏…" : "正在分析录音，整理旋律…"
        let bpm = project.bpm, free = project.freeRhythm
        task = Task {
            do {
                let result = try await RecognitionService.analyze(url: url, bpm: bpm, free: free, start: start, end: end, settings: settings)
                try Task.checkCancellation()
                stage = rawMode == StudioMode.professional.rawValue ? "正在生成乐谱并保存草稿…" : "正在保存你的旋律…"
                let offset = project.tracks[index].sourceStartBeat ?? 0
                project.tracks[index].notes = result.notes.map { var note = $0; note.start += offset; note.sourceFile = project.tracks[index].recordingFile; return note }
                project.tracks[index].transcript = result.transcript; project.tracks[index].recognitionSource = settings.engine.title
                project.tracks[index].trimStart = start; project.tracks[index].trimEnd = end.isFinite ? end : nil; project.tracks[index].useOriginalAudio = false
                processing = false; if saveRecordingMetadata() { edit() }
            } catch { processing = false; if !Task.isCancelled { analysisError = error.localizedDescription; failedAnalysis = true } }
            task = nil
        }
    }
    private func edit() { completed = true; onEdit(project) }
    private func discardTake() {
        audio.finishRecording(); task?.cancel()
        do { try store.save(initialProject); project = initialProject; if let createdFile { try? FileManager.default.removeItem(at: store.recordingDirectory.appendingPathComponent(createdFile)) }; dismiss() }
        catch { self.error = error.localizedDescription }
    }
}
struct Waveform: View {
    var levels: [Float]
    var body: some View { GeometryReader { geometry in HStack(alignment: .center, spacing: 3) { ForEach(Array(levels.enumerated()), id: \.offset) { _, level in RoundedRectangle(cornerRadius: 2).fill(Palette.gold.opacity(0.85)).frame(width: max(1, (geometry.size.width - CGFloat(levels.count) * 3) / CGFloat(levels.count)), height: max(2, CGFloat(level) * geometry.size.height)) } }.frame(height: geometry.size.height) }.accessibilityLabel("根据真实麦克风音量绘制的波形") }
}
