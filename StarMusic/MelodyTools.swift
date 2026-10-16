import SwiftUI

enum MelodyChangeError: LocalizedError {
    case pitchRange
    var errorDescription: String? { "这次调整超出支持的音高范围，请少调整一点。" }
}

enum MelodyTransform {
    static func shifted(_ source: MusicProject, steps: Int, trackID: UUID? = nil) throws -> MusicProject {
        var result = source
        guard (-24...24).contains(steps) else { throw MusicError.invalidProject }
        let indices = result.tracks.indices.filter { trackID == nil || result.tracks[$0].id == trackID }
        guard !indices.isEmpty else { throw MusicError.invalidProject }
        let pitches = indices.flatMap { result.tracks[$0].notes.compactMap(\.midi) }
        guard !pitches.isEmpty else { throw MusicError.noNotes }
        guard pitches.allSatisfy({ (0...127).contains($0 + steps) }) else { throw MelodyChangeError.pitchRange }
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
    @State private var low = 48
    @State private var high = 84
    private var span: Double { max(4, beats) }
    private var width: CGFloat { max(310, CGFloat(span) * 38) }
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack { Text("旋律高低").font(.subheadline.weight(.medium)); Spacer(); Text("从左往右听").font(.caption).foregroundStyle(.secondary) }
            HStack(spacing: 8) {
                VStack { Text("高"); Spacer(); Text("低") }.font(.caption2).foregroundStyle(.secondary).frame(height: 160)
                ScrollView(.horizontal, showsIndicators: false) { plot }
            }
        }.musicCard(radius: 28).accessibilityElement(children: .contain).accessibilityIdentifier("editor.melody")
            .onAppear { fit(initial: true) }.onChange(of: notes) { _, _ in fit(initial: false) }
    }
    private var plot: some View {
        ZStack(alignment: .topLeading) {
            grid.contentShape(Rectangle()).onTapGesture { point in addAt(point) }.allowsHitTesting(addMode)
            if notes.isEmpty { Text(addMode ? "轻点这里，写下一个声音" : "录唱后，旋律会出现在这里").font(.caption).foregroundStyle(.secondary).frame(width: 290, height: 160).allowsHitTesting(false) }
            ForEach(notes.filter { $0.midi != nil }) { note in noteCell(note) }
        }.frame(width: width, height: 170)
    }
    private var grid: some View {
        Canvas { context, size in
            for row in 0...4 {
                let y = CGFloat(row) * 40
                var line = Path(); line.move(to: CGPoint(x: 0, y: y)); line.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(line, with: .color(.gray.opacity(0.15)), lineWidth: 1)
            }
        }
    }
    private func noteFrame(_ note: MusicNote) -> CGRect {
        let x = CGFloat(note.start / span) * width
        let y = CGFloat(Double(high - (note.midi ?? low)) / Double(max(1, high - low))) * 140 + 10
        let length = max(CGFloat(12), CGFloat(note.duration / span) * width - 3)
        return CGRect(x: x, y: y - 22, width: length, height: 44)
    }
    private func noteCell(_ note: MusicNote) -> some View {
        let frame = noteFrame(note)
        let color = note.id == selected ? Palette.gold : Palette.gold.opacity(0.55)
        let border = note.confidence < 0.8 ? Color.primary.opacity(0.5) : Color.clear
        return Button { onSelect(note.id) } label: {
            Capsule().fill(color).frame(width: frame.width, height: 12)
                .overlay(Capsule().stroke(border, style: StrokeStyle(lineWidth: 1, dash: [3])))
                .frame(width: max(44, frame.width), height: 44)
                .contentShape(Rectangle())
        }.buttonStyle(.plain)
            .accessibilityLabel(note.confidence < 0.8 ? "旋律片段，建议校正" : "旋律片段，可编辑").accessibilitySortPriority(-note.start)
            .simultaneousGesture(DragGesture(minimumDistance: 8).onEnded { value in
                let steps = Int((-Double(value.translation.height) / 140 * Double(high - low)).rounded())
                onMove(note.id, steps)
            })
            .position(x: frame.midX, y: frame.midY)
    }
    private func addAt(_ point: CGPoint) {
        guard addMode, !notes.contains(where: { $0.midi != nil && noteFrame($0).insetBy(dx: -max(0, (44 - noteFrame($0).width) / 2), dy: 0).contains(point) }) else { return }
        let pitch = max(0, min(127, high - Int(Double(point.y - 10) / 140 * Double(high - low))))
        onAdd(pitch, max(0, Double(point.x / width) * span))
    }
    private func fit(initial: Bool) {
        let pitches = notes.compactMap(\.midi)
        guard let minimum = pitches.min(), let maximum = pitches.max() else { return }
        let lower = max(0, Int(floor(Double(minimum) / 12)) * 12 - 3)
        let upper = min(127, max(lower + 12, Int(ceil(Double(maximum) / 12)) * 12 + 3))
        if initial { low = lower; high = upper }
        else { if minimum < low { low = lower }; if maximum > high { high = upper } }
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
            Form {
                Section {
                    if project.tracks.contains(where: { $0.useOriginalAudio == true && !$0.muted && $0.notes.allSatisfy({ $0.midi == nil }) }) { Text("有一部分只有录音，还没有整理成旋律。这部分保持原来的高度。").font(.caption).foregroundStyle(.secondary) }
                    HStack {
                        Button { steps = max(-24, steps - 1); audio.stopPlayback() } label: { Label("低一点", systemImage: "minus").frame(maxWidth: .infinity, minHeight: 48) }.musicAction().accessibilityIdentifier("key.lower")
                        Button { steps = min(24, steps + 1); audio.stopPlayback() } label: { Label("高一点", systemImage: "plus").frame(maxWidth: .infinity, minHeight: 48) }.musicAction().accessibilityIdentifier("key.higher")
                    }
                    Text(professional ? "移调：\(steps) 个半音" : description).font(.headline).frame(maxWidth: .infinity).accessibilityIdentifier("key.height")
                    Button("回到原来的高度") { steps = 0; audio.stopPlayback() }.frame(minHeight: 44)
                    Button(previewing ? "正在准备试听…" : "先听听") { Task { await preview() } }.frame(maxWidth: .infinity, minHeight: 48).buttonStyle(.bordered).disabled(previewing).accessibilityIdentifier("key.preview")
                    if let error { Text(error).font(.caption).foregroundStyle(.secondary) }
                } footer: { Text("整首一起升高或降低，节奏不变。原录音保留，试听使用乐器演奏。") }
            }.navigationTitle("换个调").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button("取消", role: .cancel) { dismiss() } }; ToolbarItem(placement: .confirmationAction) { Button("用这个调") { apply() }.accessibilityIdentifier("key.apply") } }
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
