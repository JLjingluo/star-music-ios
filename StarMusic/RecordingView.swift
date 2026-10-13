import SwiftUI

@MainActor struct RecordingView: View {
    @EnvironmentObject var store: ProjectStore
    @EnvironmentObject var audio: AudioController
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var scheme
    @State var project: MusicProject
    var onEdit: (MusicProject) -> Void
    @State private var beat = false
    @State private var permission = false
    @State private var leaving = false
    @State private var processing = false
    @State private var stage = ""
    @State private var task: Task<Void, Never>?
    @State private var lastSave = 0
    @State private var failedAnalysis = false
    @State private var trim = false
    @State private var trimStart = 0.0
    @State private var trimEnd = 10.0
    @State private var error: String?
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text("CAPTURE YOUR INSPIRATION").font(.caption2).tracking(2).foregroundStyle(.secondary)
                    Text(audio.recordingState == .ready ? "准备好了，就哼唱吧。" : "把脑海里的旋律，留下来。").font(.title2.weight(.semibold)).multilineTextAlignment(.center)
                    Text(musicTime(audio.elapsed)).font(.system(.largeTitle, design: .monospaced).weight(.light)).monospacedDigit().accessibilityLabel("录音时长 \(Int(audio.elapsed)) 秒")
                    Label(statusText, systemImage: audio.recordingState == .recording ? "record.circle" : "mic").font(.caption).foregroundStyle(audio.recordingState == .recording ? Color(red: 0.89, green: 0.58, blue: 0.53) : Color.secondary)
                    Waveform(levels: audio.levels).frame(height: 125).padding(.horizontal, 10)
                    if audio.recordingState == .ready {
                        Picker("录制模式", selection: $beat) { Text("自由哼唱").tag(false); Text("跟节拍哼唱").tag(true) }.pickerStyle(.segmented)
                        if beat { Stepper("\(Int(project.bpm)) BPM", value: $project.bpm, in: 40...240, step: 1); Text("建议使用耳机，避免节拍声进入录音。").font(.caption2).foregroundStyle(.secondary) }
                        Button { Task { await begin() } } label: { Circle().fill(Color(red: 0.88, green: 0.57, blue: 0.53)).frame(width: 64, height: 64).padding(8).overlay(Circle().stroke(.secondary.opacity(0.4), lineWidth: 1)) }.accessibilityLabel("开始录音")
                    } else if audio.recordingState != .finished {
                        HStack(spacing: 16) {
                            Button(audio.recordingState == .recording ? "暂停" : "继续录制") { if audio.recordingState == .recording { audio.pauseRecording(); saveRecordingMetadata() } else { do { try audio.resumeRecording() } catch { self.error = error.localizedDescription } } }.buttonStyle(.bordered).frame(minHeight: 44)
                            GoldButton(title: "完成并生成乐谱", symbol: "checkmark") { finishAndAnalyze() }
                        }
                    } else { GoldButton(title: "继续编辑", symbol: "music.note") { onEdit(project) } }
                    Text("在安静环境中，清晰地哼唱一条旋律。\n首版支持单声部哼唱，不承诺识别复杂歌曲。\n原始录音保存在本机，最长支持 5 分钟转谱。").font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center).lineSpacing(5)
                }.padding(24).frame(maxWidth: 850).frame(maxWidth: .infinity).musicCard(radius: 24).padding(16)
            }.background(Palette.background(scheme)).navigationTitle(project.name).navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .topBarLeading) { Button { if project.recordingFile != nil { audio.pauseRecording(); saveRecordingMetadata(); leaving = true } else { dismiss() } } label: { Image(systemName: "chevron.left").frame(width: 44, height: 44) }.accessibilityLabel("关闭录音页面") } }
        }
        .interactiveDismissDisabled(project.recordingFile != nil)
        .onAppear { audio.stopPlayback(); audio.resetRecording() }
        .onDisappear { audio.finishRecording(); task?.cancel() }
        .onChange(of: audio.elapsed) { _, elapsed in
            if Int(elapsed) >= lastSave + 5 { lastSave = Int(elapsed); saveRecordingMetadata() }
            if elapsed >= 300 && audio.recordingState == .recording { audio.pauseRecording(); saveRecordingMetadata(); error = "已达到首版 5 分钟的分析范围，录音已暂停，请完成录制。" }
        }
        .onChange(of: audio.recordingState) { _, state in if state == .paused { saveRecordingMetadata() } }
        .alert("需要麦克风权限", isPresented: $permission) { Button("前往系统设置") { if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) } }; Button("空白创作") { onEdit(project) }; Button("取消", role: .cancel) {} } message: { Text("麦克风仅用于录制你的哼唱，原始录音保存在本机。你也可以不使用麦克风，直接写谱。") }
        .confirmationDialog("保留这段灵感吗？", isPresented: $leaving, titleVisibility: .visible) {
            Button("保存并退出") { audio.finishRecording(); if saveRecordingMetadata() { dismiss() } }
            Button("继续录制") { do { try audio.resumeRecording() } catch { self.error = error.localizedDescription } }
            Button("放弃本次录音", role: .destructive) { audio.finishRecording(); project.deleted = true; if saveRecordingMetadata() { dismiss() } }
            Button("取消", role: .cancel) {}
        }
        .overlay {
            if processing {
                VStack(spacing: 20) { ProgressView(); Text(stage).font(.subheadline); Button("取消分析，保留原始录音") { task?.cancel(); task = nil; processing = false; if saveRecordingMetadata() { onEdit(project) } }.frame(minHeight: 44) }.padding(30).background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24)).frame(maxWidth: .infinity, maxHeight: .infinity).background(.black.opacity(0.45)).ignoresSafeArea()
            }
        }
        .alert("还没有识别出清晰的旋律", isPresented: $failedAnalysis) { Button("重新分析") { analyze() }; Button("截取片段") { trimEnd = project.recordingSeconds ?? 10; trim = true }; Button("手动写谱") { onEdit(project) } } message: { Text("原始录音仍保留在草稿中，可以重新分析、截取片段或手动写谱。") }
        .sheet(isPresented: $trim) { VStack(alignment: .leading, spacing: 24) { Text("截取清晰片段").font(.title2.bold()); Text("只分析这个范围，完整原录音仍会保留。").font(.caption).foregroundStyle(.secondary); Stepper("起始 \(trimStart, specifier: "%.1f") 秒", value: $trimStart, in: 0...max(0, (project.recordingSeconds ?? 10) - 0.2), step: 0.1); Stepper("结束 \(trimEnd, specifier: "%.1f") 秒", value: $trimEnd, in: 0.2...max(0.2, project.recordingSeconds ?? 10), step: 0.1); GoldButton(title: "分析片段", symbol: "waveform") { if trimEnd > trimStart { trim = false; analyze(start: trimStart, end: trimEnd) } else { error = "结束时间需要大于开始时间。" } } }.padding(24).presentationDetents([.medium]) }
        .alert("录音提示", isPresented: Binding(get: { error != nil || audio.interruptionMessage != nil }, set: { if !$0 { error = nil; audio.interruptionMessage = nil } })) { Button("知道了", role: .cancel) { error = nil; audio.interruptionMessage = nil } } message: { Text(error ?? audio.interruptionMessage ?? "") }
    }
    private var statusText: String { switch audio.recordingState { case .ready: "首次录音会请求麦克风授权"; case .recording: "正在录音"; case .paused: "已暂停 · 原始录音保留"; case .finished: "原始录音已保存" } }
    private func begin() async {
        let name = UUID().uuidString + ".wav", url = store.recordingDirectory.appendingPathComponent(name)
        do { audio.metronomeBPM = beat ? project.bpm : nil; try await audio.beginRecording(to: url); project.recordingFile = name; project.freeRhythm = !beat; saveRecordingMetadata() }
        catch MusicError.permission { permission = true }
        catch { self.error = error.localizedDescription }
    }
    @discardableResult private func saveRecordingMetadata() -> Bool {
        project.recordingSeconds = audio.elapsed; project.updated = Date()
        do { try store.save(project); return true } catch { self.error = error.localizedDescription; return false }
    }
    private func finishAndAnalyze() { guard audio.elapsed > 0.1 else { error = "请先录制一段旋律。"; return }; audio.finishRecording(); if saveRecordingMetadata() { analyze() } }
    private func analyze(start: Double = 0, end: Double = .infinity) {
        guard let url = store.recordingURL(project) else { return }; processing = true; stage = "正在读取已保存的原始录音…"
        let bpm = project.bpm, free = project.freeRhythm
        task = Task {
            do {
                let reading = Task.detached { try AudioController.samples(from: url) }
                let data = try await reading.value; try Task.checkCancellation(); stage = "正在分析音高与整理节奏…"
                let low = max(0, min(data.samples.count, Int(start * data.sampleRate))), high = end.isFinite ? min(data.samples.count, Int(end * data.sampleRate)) : data.samples.count
                let samples = Array(data.samples[low..<max(low, high)])
                let worker = Task.detached { try PitchAnalyzer.analyze(samples, sampleRate: data.sampleRate, bpm: bpm, free: free) }
                var notes = try await withTaskCancellationHandler(operation: { try await worker.value }, onCancel: { worker.cancel() })
                try Task.checkCancellation(); for i in notes.indices { notes[i].rawStart = (notes[i].rawStart ?? 0) + start }
                stage = "正在生成乐谱并保存草稿…"; project.tracks[0].notes = notes; if saveRecordingMetadata() { processing = false; onEdit(project) }
            } catch is CancellationError { processing = false } catch { processing = false; failedAnalysis = true }
            task = nil
        }
    }
}
struct Waveform: View {
    var levels: [Float]
    var body: some View { GeometryReader { geometry in HStack(alignment: .center, spacing: 3) { ForEach(Array(levels.enumerated()), id: \.offset) { _, level in RoundedRectangle(cornerRadius: 2).fill(Palette.gold.opacity(0.85)).frame(width: max(1, (geometry.size.width - CGFloat(levels.count) * 3) / CGFloat(levels.count)), height: max(2, CGFloat(level) * geometry.size.height)) } }.frame(height: geometry.size.height) }.accessibilityLabel("根据真实麦克风音量绘制的波形") }
}
