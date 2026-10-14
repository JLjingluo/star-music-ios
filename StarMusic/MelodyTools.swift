import SwiftUI

enum MelodyTransform {
    static func shifted(_ source: MusicProject, steps: Int, trackID: UUID? = nil) throws -> MusicProject {
        var result = source
        guard (-24...24).contains(steps) else { throw MusicError.invalidProject }
        let indices = result.tracks.indices.filter { trackID == nil || result.tracks[$0].id == trackID }
        guard !indices.isEmpty else { throw MusicError.invalidProject }
        let pitches = indices.flatMap { result.tracks[$0].notes.compactMap(\.midi) }
        guard !pitches.isEmpty else { throw MusicError.noNotes }
        guard pitches.allSatisfy({ (0...127).contains($0 + steps) }) else { throw MusicError.save("已经到达支持的音高范围，请少调整一些") }
        for index in indices {
            if result.tracks[index].notes.contains(where: { $0.midi != nil }) { result.tracks[index].useOriginalAudio = false }
            for i in result.tracks[index].notes.indices { if let pitch = result.tracks[index].notes[i].midi { result.tracks[index].notes[i].midi = pitch + steps } }
        }
        return result
    }
}

struct MelodyCanvas: View {
    var notes: [MusicNote]
    var beats: Double
    var selected: UUID?
    var addMode: Bool
    var onSelect: (UUID) -> Void
    var onAdd: (Int, Double) -> Void
    var onMove: (UUID, Int) -> Void
    private var low: Int { max(0, (notes.compactMap(\.midi).min() ?? 60) - 3) }
    private var high: Int { min(127, max(low + 12, (notes.compactMap(\.midi).max() ?? 72) + 3)) }
    private var width: CGFloat { max(310, CGFloat(beats) * 38) }
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack { Text("旋律高低").font(.subheadline.weight(.medium)); Spacer(); Text("从左往右听").font(.caption).foregroundStyle(.secondary) }
            HStack(spacing: 8) {
                VStack { Text("高"); Spacer(); Text("低") }.font(.caption2).foregroundStyle(.secondary).frame(height: 160)
                ScrollView(.horizontal, showsIndicators: false) {
                    ZStack(alignment: .topLeading) {
                        Canvas { context, size in
                            for row in 0...4 { let y = CGFloat(row) * 40; var line = Path(); line.move(to: CGPoint(x: 0, y: y)); line.addLine(to: CGPoint(x: size.width, y: y)); context.stroke(line, with: .color(.gray.opacity(0.15)), lineWidth: 1) }
                        }
                        if notes.isEmpty { Text(addMode ? "轻点这里，写下一个声音" : "录唱后，旋律会出现在这里").font(.caption).foregroundStyle(.secondary).frame(width: 290, height: 160) }
                        ForEach(notes.filter { $0.midi != nil }) { note in
                            let x = CGFloat(note.start / max(4, beats)) * width
                            let y = CGFloat(Double(high - (note.midi ?? low)) / Double(max(1, high - low))) * 140 + 10
                            Button { onSelect(note.id) } label: {
                                Capsule().fill(note.id == selected ? Palette.gold : Palette.gold.opacity(0.55)).frame(width: max(12, CGFloat(note.duration / max(4, beats)) * width - 3), height: 12)
                                    .overlay(Capsule().stroke(note.confidence < 0.8 ? Color.primary.opacity(0.5) : .clear, style: StrokeStyle(lineWidth: 1, dash: [3])))
                                    .frame(height: 44)
                            }.buttonStyle(.plain).position(x: x + max(12, CGFloat(note.duration / max(4, beats)) * width - 3) / 2, y: y)
                                .accessibilityLabel("旋律片段，\(note.confidence < 0.8 ? "建议校正" : "可编辑")")
                                .simultaneousGesture(DragGesture(minimumDistance: 8).onEnded { value in onMove(note.id, Int((-value.translation.height / 140 * CGFloat(high - low)).rounded())) })
                        }
                    }.frame(width: width, height: 170)
                        .contentShape(Rectangle()).onTapGesture { point in if addMode { let pitch = max(0, min(127, high - Int((point.y - 10) / 140 * CGFloat(high - low)))); onAdd(pitch, max(0, point.x / width * max(4, beats))) } }
                }
            }
        }.musicCard(radius: 20).accessibilityIdentifier("editor.melody")
    }
}

struct KeyShiftSheet: View {
    @EnvironmentObject private var audio: AudioController
    @Environment(\.dismiss) private var dismiss
    var project: MusicProject
    var recordingDirectory: URL
    var professional: Bool
    var onApply: (MusicProject) -> Void
    @State private var steps = 0
    @State private var error: String?
    @State private var previewing = false
    private var description: String { steps == 0 ? "原来的高度" : steps > 0 ? "比原来高 \(steps) 点" : "比原来低 \(-steps) 点" }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Text("找到更舒服的高度。").font(.title2.weight(.medium))
                    Text("整首旋律一起升高或降低，前后顺序和节奏保持不变。原始录音保留，试听使用乐器演奏。").font(.subheadline).foregroundStyle(.secondary)
                    HStack {
                        Button { steps = max(-24, steps - 1); audio.stopPlayback() } label: { Label("低一点", systemImage: "minus").frame(maxWidth: .infinity, minHeight: 48) }.buttonStyle(.bordered).accessibilityIdentifier("key.lower")
                        Button { steps = min(24, steps + 1); audio.stopPlayback() } label: { Label("高一点", systemImage: "plus").frame(maxWidth: .infinity, minHeight: 48) }.buttonStyle(.bordered).accessibilityIdentifier("key.higher")
                    }
                    Text(professional ? "移调：\(steps) 个半音" : description).font(.headline).frame(maxWidth: .infinity).accessibilityIdentifier("key.height")
                    Button("回到原来的高度") { steps = 0; audio.stopPlayback() }.frame(minHeight: 44)
                    Button(previewing ? "正在准备试听…" : "先听听") { Task { await preview() } }.frame(maxWidth: .infinity, minHeight: 48).buttonStyle(.bordered).disabled(previewing).accessibilityIdentifier("key.preview")
                    GoldButton(title: "用这个调", symbol: "checkmark") { apply() }.accessibilityIdentifier("key.apply")
                    if let error { Text(error).font(.caption).foregroundStyle(.secondary) }
                }.padding(24)
            }.navigationTitle("换个调").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("取消") { dismiss() } } }
        }.onDisappear { audio.stopPlayback() }
    }
    private func apply() {
        do { let result = try MelodyTransform.shifted(project, steps: steps); audio.stopPlayback(); if steps != 0 { onApply(result) }; dismiss() }
        catch { self.error = error.localizedDescription }
    }
    private func preview() async {
        previewing = true; defer { previewing = false }
        do { let candidate = try MelodyTransform.shifted(project, steps: steps); try await audio.play(candidate, recordingDirectory: recordingDirectory) }
        catch { self.error = error.localizedDescription }
    }
}
