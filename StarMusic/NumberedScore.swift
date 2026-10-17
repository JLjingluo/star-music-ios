import SwiftUI
import UIKit

/// A second notation of the same pitches and times, never a quantization or a
/// destructive conversion. Middle-register 1 is C4 (or the chosen tonic above it).
enum ScorePresentation: String, CaseIterable, Identifiable {
    case melody, staff, numbered
    var id: String { rawValue }
    var title: String { switch self { case .melody: "旋律高低图"; case .staff: "五线谱"; case .numbered: "简谱" } }
}
struct NumberedPitch: Equatable {
    let digit: Int
    let sharp: Bool
    let octave: Int
    init(midi: Int?, key: String) {
        guard let midi else { digit = 0; sharp = false; octave = 0; return }
        let tonic = ["C": 0, "G": 7, "D": 2, "A": 9, "F": 5, "B♭": 10][key] ?? 0
        let relative = midi - (60 + tonic)
        octave = Int(floor(Double(relative) / 12))
        let pc = (relative % 12 + 12) % 12
        let scale = [0, 2, 4, 5, 7, 9, 11]
        let degree = scale.lastIndex(where: { $0 <= pc }) ?? 0
        digit = degree + 1; sharp = scale[degree] != pc
    }
    var text: String { (sharp ? "♯" : "") + String(digit) }
    var plain: String { text + String(repeating: "'", count: max(0, octave)) + String(repeating: ",", count: max(0, -octave)) }
}
struct NumberedRhythm {
    let flags: Int
    let dotted: Bool
    let dashes: Int
    init(duration: Double, free: Bool) {
        let bases: [Double] = [0.0625, 0.125, 0.25, 0.5, 1]
        let exact = bases.contains { abs(duration - $0) < 0.000001 || abs(duration - $0 * 1.5) < 0.000001 }
        let notation = NoteNotation(duration: duration)
        flags = !free && exact ? notation.flags : 0
        dotted = !free && exact && notation.dotted
        // 2/3/4 beats use one/two/three extension dashes. Unrepresentable or
        // very long durations keep their explicit time rather than fake flags.
        dashes = !free && (2...4).contains(duration) && abs(duration.rounded() - duration) < 0.000001 ? Int(duration) - 1 : 0
    }
}
struct NumberedScoreView: View {
    var notes: [MusicNote]; var key: String; var bpm: Double; var free: Bool; var selected: UUID?
    var onSelect: (UUID) -> Void
    @State private var page = 0
    private var pages: [[MusicNote]] { ScoreLayout.pages(notes, pageSize: 8) }
    var body: some View {
        let visible = pages[min(page, pages.count - 1)]
        let pitches = visible.map { NumberedPitch(midi: $0.midi, key: key) }
        let above = max(12, CGFloat(pitches.map(\.octave).max() ?? 0) * 8)
        let below = max(12, CGFloat(-(pitches.map(\.octave).min() ?? 0)) * 8)
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("1 = \(key)").font(.headline)
                Spacer()
                if pages.count > 1 {
                    Button("上一页", systemImage: "chevron.left") { page = max(0, page - 1) }.labelStyle(.iconOnly).frame(width: 44, height: 44).disabled(page == 0)
                    Text("\(page + 1) / \(pages.count)").font(.caption).monospacedDigit()
                    Button("下一页", systemImage: "chevron.right") { page = min(pages.count - 1, page + 1) }.labelStyle(.iconOnly).frame(width: 44, height: 44).disabled(page == pages.count - 1)
                }
            }
            if visible.isEmpty { Text("添加声音或录唱后，旋律会显示成简谱。").foregroundStyle(.secondary) }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 16)], spacing: 20) {
                ForEach(visible) { note in
                    Button { onSelect(note.id) } label: { numberedCell(note, above: above, below: below) }.buttonStyle(.plain)
                        .accessibilityLabel("\(note.pitchName)，简谱 \(NumberedPitch(midi: note.midi, key: key).plain)，从 \((note.start * 60 / bpm).formatted()) 秒开始，持续 \((note.duration * 60 / bpm).formatted()) 秒")
                        .accessibilityIdentifier("numbered.note.\(note.id)")
                }
            }
            Text(free ? "按原来的节奏试听 · 每格下方为开始时间和持续秒数" : "数字表示音高，上下圆点表示高低八度；下方显示实际长度。")
                .font(.caption).foregroundStyle(.secondary)
        }.padding(20).background(Color(red: 0.94, green: 0.93, blue: 0.89), in: RoundedRectangle(cornerRadius: 24))
            .foregroundStyle(Palette.ink).accessibilityElement(children: .contain).accessibilityIdentifier("editor.numberedScore")
            .onChange(of: notes.count) { _, _ in page = min(page, pages.count - 1) }
    }
    private func numberedCell(_ note: MusicNote, above: CGFloat, below: CGFloat) -> some View {
        let pitch = NumberedPitch(midi: note.midi, key: key)
        let style = NumberedRhythm(duration: note.duration, free: free)
        return VStack(spacing: 3) {
            Text(String(repeating: "•\n", count: max(0, pitch.octave)).trimmingCharacters(in: .newlines)).font(.system(size: 8)).lineSpacing(-2).frame(height: above, alignment: .bottom)
            Text(String(pitch.digit)).font(.system(size: 26, weight: .medium))
                .overlay(alignment: .leading) { if pitch.sharp { Text("♯").font(.system(size: 20)).offset(x: -18) } }
                .overlay(alignment: .trailing) {
                    if style.dotted { Text("·").font(.system(size: 20)).offset(x: 12) }
                    if style.dashes > 0 { Text(String(repeating: "—", count: style.dashes)).font(.system(size: 10)).offset(x: 44) }
                }
            Text(String(repeating: "•\n", count: max(0, -pitch.octave)).trimmingCharacters(in: .newlines)).font(.system(size: 8)).lineSpacing(-2).frame(height: below, alignment: .top)
            if !free { VStack(spacing: 2) { ForEach(0..<style.flags, id: \.self) { _ in Rectangle().frame(width: 24, height: 1) } }.frame(height: 12, alignment: .top) }
            Text(free ? String(format: "%.2fs · %.2fs", note.start * 60 / bpm, note.duration * 60 / bpm) : String(format: "%.3g 拍", note.duration)).font(.caption2).monospacedDigit().lineLimit(1).minimumScaleFactor(0.7)
            if note.confidence < 0.8 { Image(systemName: "questionmark.circle").font(.caption) } else { Color.clear.frame(height: 14) }
        }.frame(maxWidth: .infinity).padding(.vertical, 8)
            .background(note.id == selected ? Color.blue.opacity(0.12) : .clear, in: RoundedRectangle(cornerRadius: 12))
            .overlay { if note.id == selected { RoundedRectangle(cornerRadius: 12).stroke(.blue, lineWidth: 2) } }
    }
}

enum NumberedScoreExport {
    static func text(_ project: MusicProject) -> String {
        var lines = [project.name, "简谱 · 1 = \(project.key) · 4/4 · \(Int(project.bpm)) BPM", "数字后的 ' 为高八度，, 为低八度；0 为休止。", project.freeRhythm ? "自由哼唱：保留原时间，未强行量化。" : "以实际开始拍数与长度为准。", ""]
        for track in project.tracks {
            lines.append("【\(track.name) · \(track.instrument.name)】")
            lines.append("小节\t简谱\t开始(秒)\t长度(秒)\t开始(拍)\t长度(拍)")
            for note in track.notes.sorted(by: { $0.start < $1.start }) {
                let symbol = NumberedPitch(midi: note.midi, key: project.key)
                lines.append(String(format: "%d\t%@%@\t%.4f\t%.4f\t%.4f\t%.4f", Int(note.start / 4) + 1, symbol.plain, note.tied ? "⌒" : "", note.start * 60 / project.bpm, note.duration * 60 / project.bpm, note.start, note.duration))
            }
            lines.append("")
        }
        return lines.joined(separator: "\n")
    }
    /// A paginated vector PDF; no giant screenshot or all-project bitmap.
    static func pdf(_ project: MusicProject, to url: URL) throws {
        try project.validate()
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 595, height: 842))
        var page = 0
        try renderer.writePDF(to: url) { context in
            func label(_ string: String, x: CGFloat, y: CGFloat, size: CGFloat, color: UIColor = .black) {
                (string as NSString).draw(in: CGRect(x: x, y: y, width: 510, height: size * 2.8), withAttributes: [.font: UIFont.systemFont(ofSize: size), .foregroundColor: color])
            }
            func begin(_ track: MusicTrack) {
                context.beginPage(); page += 1
                label(String(project.name.prefix(70)), x: 42, y: 30, size: 18)
                label("简谱 · 1 = \(project.key) · 4/4 · \(Int(project.bpm)) BPM", x: 42, y: 76, size: 12)
                label(String(track.name.prefix(60)) + " · " + track.instrument.name, x: 42, y: 98, size: 11)
                label(project.freeRhythm ? "自由哼唱：保留实际时间；每格下方为开始秒数 / 持续秒数。" : "数字上下点表示八度；每格下方为开始拍数 / 持续拍数。", x: 42, y: 122, size: 9)
                label("Star Music · \(page)", x: 42, y: 804, size: 10, color: .darkGray)
            }
            for track in project.tracks {
                begin(track)
                let notes = track.notes.sorted { $0.start < $1.start }
                if notes.isEmpty { label("此轨暂无音符", x: 42, y: 170, size: 12) }
                for (index, note) in notes.enumerated() {
                    if Task.isCancelled { return }
                    let offset = index % 25
                    if offset == 0 && index > 0 { begin(track) }
                    let x = 42 + CGFloat(offset % 5) * 103, y = 166 + CGFloat(offset / 5) * 124
                    let pitch = NumberedPitch(midi: note.midi, key: project.key), style = NumberedRhythm(duration: note.duration, free: project.freeRhythm)
                    label("\(Int(note.start / 4) + 1)", x: x, y: y, size: 8, color: .gray)
                    label(String(pitch.digit), x: x + 24, y: y + 28, size: 24)
                    if pitch.sharp { label("♯", x: x + 8, y: y + 32, size: 18) }
                    if style.dotted { label("·", x: x + 42, y: y + 30, size: 20) }
                    for dot in 0..<abs(pitch.octave) {
                        let dotY = pitch.octave > 0 ? y + 23 - CGFloat(dot) * 5 : y + 60 + CGFloat(dot) * 5
                        context.cgContext.fillEllipse(in: CGRect(x: x + 30, y: dotY, width: 2.5, height: 2.5))
                    }
                    if !project.freeRhythm {
                        for line in 0..<style.flags { context.cgContext.fill(CGRect(x: x + 24, y: y + 90 + CGFloat(line) * 3, width: 25, height: 0.7)) }
                        if style.dashes > 0 { label(String(repeating: "—", count: style.dashes), x: x + 49, y: y + 36, size: 10) }
                    }
                    if note.tied { label("⌒", x: x + 58, y: y + 12, size: 12) }
                    let timing = project.freeRhythm ? String(format: "%.2f / %.2f s", note.start * 60 / project.bpm, note.duration * 60 / project.bpm) : String(format: "%.3g / %.3g 拍", note.start, note.duration)
                    label(timing, x: x, y: y + 105, size: 8, color: .darkGray)
                }
            }
        }
        if Task.isCancelled { try? FileManager.default.removeItem(at: url); throw CancellationError() }
    }
}
