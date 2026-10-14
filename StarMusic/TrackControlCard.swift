import SwiftUI

struct TrackControlCard: View {
    var track: MusicTrack
    var beats: Double
    var professional: Bool
    var canDelete: Bool
    var hasSource: Bool
    var onEdit: () -> Void
    var onUpdate: (MusicTrack) -> Void
    var onDelete: () -> Void
    var onRecord: () -> Void
    var onImport: () -> Void
    var onAnalyze: () -> Void
    var onSpeech: () -> Void
    var onPlaySource: () -> Void
    var onPlayHistory: (String) -> Void
    @State private var rename = false
    @State private var name = ""
    @State private var volume = 0.7
    @State private var confirmDelete = false
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Button(action: onEdit) {
                    VStack(alignment: .leading, spacing: 5) { Text(track.name).font(.headline); Text(track.instrument.name + " · \(track.notes.filter { $0.midi != nil }.count) 个音符").font(.caption).foregroundStyle(.secondary) }
                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                }.buttonStyle(MusicPressStyle()).accessibilityLabel("编辑 \(track.name) 的音符")
                Menu {
                    Button("重命名") { name = track.name; rename = true }
                    Button("在此轨道录唱", action: onRecord)
                    Button("导入到此轨道", action: onImport)
                    if hasSource {
                        Button("试听此轨原声", action: onPlaySource)
                        Button("重新识谱所选原声", action: onAnalyze)
                        Button("用我的模型识别歌词 / 口述", action: onSpeech)
                        if let history = track.sourceHistory, !history.isEmpty { Menu("历史原声") { ForEach(Array(history.enumerated()), id: \.offset) { index, file in Button("录音版本 \(index + 1)") { onPlayHistory(file) } } } }
                    }
                    Button("删除音轨", role: .destructive) { confirmDelete = true }.disabled(!canDelete)
                } label: { Image(systemName: "ellipsis").frame(width: 44, height: 44) }.accessibilityLabel("\(track.name) 更多操作")
            }
            HStack {
                Toggle("静音", isOn: Binding(get: { track.muted }, set: { value in change { $0.muted = value } })).font(.caption)
                Toggle("独奏", isOn: Binding(get: { track.solo }, set: { value in change { $0.solo = value } })).font(.caption)
            }
            HStack { Image(systemName: "speaker.wave.2"); Slider(value: $volume, in: 0...1) { editing in if !editing { change { $0.volume = volume } } } }.accessibilityLabel("\(track.name) 音量")
            PianoRoll(notes: track.notes, beats: beats).frame(height: 64)
            HStack {
                Button("编辑音符", action: onEdit).frame(minHeight: 44)
                Spacer()
                Button(action: onRecord) { Image(systemName: "mic").frame(width: 44, height: 44) }.accessibilityLabel("在 \(track.name) 录唱")
                Button(action: onImport) { Image(systemName: "square.and.arrow.down").frame(width: 44, height: 44) }.accessibilityLabel("导入 \(track.name)")
            }.font(.caption)
            if hasSource {
                Picker("此轨试听", selection: Binding(get: { track.useOriginalAudio ?? false }, set: { value in change { $0.useOriginalAudio = value } })) { Text("乐器演奏").tag(false); Text("原声录音").tag(true) }.pickerStyle(.segmented)
            }
            if professional { sourceControls }
            if let source = track.recognitionSource { Text(source).font(.caption2).foregroundStyle(.secondary) }
            if let text = track.transcript, !text.isEmpty { Text("歌词 / 口述\n" + text).font(.caption).textSelection(.enabled) }
        }.musicCard(radius: 20)
            .onAppear { volume = track.volume }.onChange(of: track.volume) { _, value in volume = value }
            .alert("音轨名称", isPresented: $rename) { TextField("名称", text: $name); Button("保存") { change { $0.name = name.isEmpty ? "未命名声部" : String(name.prefix(60)) } }; Button("取消", role: .cancel) {} }
            .confirmationDialog("删除这条音轨？", isPresented: $confirmDelete, titleVisibility: .visible) { Button("删除音轨", role: .destructive, action: onDelete); Button("取消", role: .cancel) {} } message: { Text("可通过撤销恢复；原始文件不会立即删除。") }
    }
    private var sourceControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Stepper("整轨起点：\(track.sourceStartBeat ?? 0, specifier: "%.1f") 拍", value: Binding(get: { track.sourceStartBeat ?? 0 }, set: { value in change { t in let delta = value - (t.sourceStartBeat ?? 0); t.sourceStartBeat = value; for i in t.notes.indices { t.notes[i].start = max(0, t.notes[i].start + delta) } } }), in: 0...max(64, beats + 32), step: 0.5).font(.caption)
            if hasSource, let duration = track.recordingSeconds, duration > 0.1 {
                Stepper("原声裁剪起点：\(track.trimStart ?? 0, specifier: "%.1f") 秒", value: Binding(get: { track.trimStart ?? 0 }, set: { value in change { $0.trimStart = value } }), in: 0...max(0, (track.trimEnd ?? duration) - 0.1), step: 0.1).font(.caption)
                Stepper("原声裁剪终点：\(track.trimEnd ?? duration, specifier: "%.1f") 秒", value: Binding(get: { track.trimEnd ?? duration }, set: { value in change { $0.trimEnd = value } }), in: min(duration, (track.trimStart ?? 0) + 0.1)...duration, step: 0.1).font(.caption)
                Text("裁剪只改变原声回放范围；重新识谱用于更新音符。BPM 不改变原声音高，也不自动拉伸原声。").font(.caption2).foregroundStyle(.secondary)
            }
        }
    }
    private func change(_ operation: (inout MusicTrack) -> Void) { var value = track; operation(&value); onUpdate(value) }
}
struct TrackRecordingRoute: Identifiable { var id: UUID; var project: MusicProject }
