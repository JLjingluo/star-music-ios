import SwiftUI
import CoreText

/// Display spacing is independent of musical time. At most 32 notes are drawn in
/// one page, so a dense or very long project never creates a giant backing canvas.
struct ScoreLayout {
    let notes: [MusicNote]
    let firstBeat: Double
    let lastBeat: Double
    let width: CGFloat
    let hasCollapsedGaps: Bool
    private let anchors: [(beat: Double, x: CGFloat)]
    private let positions: [UUID: CGFloat]
    static func pages(_ notes: [MusicNote]) -> [[MusicNote]] {
        let ordered = notes.sorted { $0.start == $1.start ? $0.id.uuidString < $1.id.uuidString : $0.start < $1.start }
        if ordered.isEmpty { return [[]] }
        return stride(from: 0, to: ordered.count, by: 32).map { Array(ordered[$0..<min($0 + 32, ordered.count)]) }
    }
    init(notes: [MusicNote]) {
        self.notes = notes
        firstBeat = floor((notes.map(\.start).min() ?? 0) / 4) * 4
        lastBeat = max(firstBeat + 4, ceil((notes.map { $0.start + $0.duration }.max() ?? 4) / 4) * 4)
        var points: [UUID: CGFloat] = [:], values: [(Double, CGFloat)] = [], cursor: CGFloat = 132
        var previous = firstBeat
        for onset in Set(notes.map(\.start)).sorted() {
            let minimum: CGFloat = values.isEmpty ? 0 : floor(onset / 4) > floor(previous / 4) ? 84 : 60
            cursor += max(minimum, min(240, CGFloat(onset - previous) * 44))
            values.append((onset, cursor))
            // Even exact simultaneous/duplicated notes get distinct hit targets.
            let chord = notes.filter { $0.start == onset }.sorted { $0.staffPosition < $1.staffPosition }
            for (i, note) in chord.enumerated() { points[note.id] = cursor + CGFloat(i) * 44 }
            cursor += CGFloat(max(0, chord.count - 1)) * 44
            previous = onset
        }
        anchors = values; positions = points
        let longGap = zip(values, values.dropFirst()).contains { pair in pair.1.0 - pair.0.0 > 240.0 / 44.0 }
        hasCollapsedGaps = longGap || lastBeat - (values.last?.0 ?? firstBeat) > 240.0 / 44.0
        width = max(640, cursor + max(80, min(240, CGFloat(lastBeat - previous) * 44)))
    }
    func x(_ note: MusicNote) -> CGFloat { positions[note.id] ?? 132 }
    func barX(beat: Double) -> CGFloat {
        guard let first = anchors.first else { return 103 + CGFloat(beat - firstBeat) * 44 }
        if beat <= first.beat { return first.x - 29 }
        let before = notes.filter { $0.start < beat }.map { x($0) }.max() ?? first.x
        if let after = notes.filter({ $0.start >= beat }).map({ x($0) }).min() { return (before + after) / 2 }
        return min(width - 20, before + max(48, min(220, CGFloat(beat - (anchors.last?.beat ?? firstBeat)) * 44)))
    }
    func x(beat: Double) -> CGFloat {
        guard let first = anchors.first else { return 132 + CGFloat(beat - firstBeat) * 44 }
        if beat <= first.beat { return first.x - min(36, CGFloat(first.beat - beat) * 44) }
        for pair in zip(anchors, anchors.dropFirst()) where beat < pair.1.beat {
            return pair.0.x + CGFloat((beat - pair.0.beat) / (pair.1.beat - pair.0.beat)) * (pair.1.x - pair.0.x)
        }
        let last = anchors.last!; return last.x + CGFloat(beat - last.beat) * 44
    }
    func beat(x: CGFloat) -> Double {
        guard let first = anchors.first else { return max(firstBeat, firstBeat + Double(x - 132) / 44) }
        if x <= first.x { return max(firstBeat, first.beat + Double(x - first.x) / 44) }
        for pair in zip(anchors, anchors.dropFirst()) where x < pair.1.x {
            return pair.0.beat + Double((x - pair.0.x) / (pair.1.x - pair.0.x)) * (pair.1.beat - pair.0.beat)
        }
        let last = anchors.last!; return last.beat + Double(x - last.x) / 44
    }
}

struct ScoreCanvas: View {
    var notes: [MusicNote]; var bars: Int; var freeRhythm: Bool
    var selected: UUID?; var addMode: Bool
    var onSelect: (UUID) -> Void; var onAdd: (Int, Double) -> Void; var onMove: (UUID, Int) -> Void
    @State private var page = 0
    private var pages: [[MusicNote]] { ScoreLayout.pages(notes) }
    private var visibleNotes: [MusicNote] { pages[min(page, pages.count - 1)] }
    var body: some View {
        VStack(spacing: 8) {
            if pages.count > 1 {
                HStack {
                    Button("上一页", systemImage: "chevron.left") { page = max(0, page - 1) }.labelStyle(.iconOnly).frame(width: 44, height: 44).disabled(page == 0).accessibilityIdentifier("score.previous")
                    Spacer(); Text("参考谱 · \(page + 1) / \(pages.count)").font(.caption).monospacedDigit(); Spacer()
                    Button("下一页", systemImage: "chevron.right") { page = min(pages.count - 1, page + 1) }.labelStyle(.iconOnly).frame(width: 44, height: 44).disabled(page >= pages.count - 1).accessibilityIdentifier("score.next")
                }.frame(minHeight: 44).padding(.horizontal, 12)
            }
            if ScoreLayout(notes: visibleNotes).hasCollapsedGaps { Text("长空段已折叠 · 实际播放时间不变").font(.caption).foregroundStyle(.secondary) }
            score(visibleNotes).id(page)
        }.background(Color(red: 0.94, green: 0.93, blue: 0.89), in: RoundedRectangle(cornerRadius: 24))
            .clipShape(RoundedRectangle(cornerRadius: 24)).accessibilityElement(children: .contain).accessibilityIdentifier("editor.score")
            .onChange(of: notes.count) { _, _ in page = min(page, pages.count - 1) }
    }
    private func score(_ notes: [MusicNote]) -> some View {
        let layout = ScoreLayout(notes: notes), geometry = ScoreGeometry(notes: notes)
        return ScrollView(.horizontal, showsIndicators: true) {
            ZStack(alignment: .topLeading) {
                Canvas { context, size in
                    context.translateBy(x: 0, y: geometry.offset)
                    drawStaff(context: context, size: size, layout: layout)
                    var currentBar = -1, altered: [Int: Bool] = [:]
                    for note in notes {
                        let bar = Int(note.start / 4); if currentBar != bar { currentBar = bar; altered = [:] }
                        let sharp = [1, 3, 6, 8, 10].contains((note.midi ?? 0) % 12)
                        let accidental: String? = note.midi != nil && sharp != altered[note.staffPosition, default: false] ? (sharp ? "\u{E262}" : "\u{E261}") : nil
                        altered[note.staffPosition] = sharp
                        draw(note, at: CGPoint(x: layout.x(note), y: note.midi == nil ? 104 : ScoreGeometry.rawY(note)), accidental: accidental, context: context)
                    }
                }.allowsHitTesting(false)
                if addMode {
                    Color.clear.contentShape(Rectangle()).gesture(SpatialTapGesture().onEnded { value in
                        let beat = max(0, (layout.beat(x: value.location.x) * 4).rounded() / 4)
                        let position = max(0, min(74, Int(((128 + geometry.offset - value.location.y) / 6).rounded()) + 37))
                        onAdd(min(127, position / 7 * 12 + [0, 2, 4, 5, 7, 9, 11][position % 7]), beat)
                    })
                }
                ForEach(notes) { note in
                    Button { onSelect(note.id) } label: { Color.clear.frame(width: 44, height: 44).contentShape(Rectangle()) }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(note.pitchName)，第 \(Int(note.start / 4) + 1) 小节，\(note.duration.formatted()) 拍" + (note.confidence < 0.8 ? "，建议校正" : ""))
                        .accessibilitySortPriority(-note.start)
                        .accessibilityAdjustableAction { direction in onMove(note.id, direction == .increment ? 1 : -1) }
                        .simultaneousGesture(DragGesture(minimumDistance: 16).onEnded { value in
                            guard abs(value.translation.height) > abs(value.translation.width) * 1.5 else { return }
                            let steps = Int((-value.translation.height / 6).rounded()); if steps != 0 { onMove(note.id, steps) }
                        })
                        .position(x: layout.x(note), y: (note.midi == nil ? 104 : ScoreGeometry.rawY(note)) + geometry.offset)
                }
            }.frame(width: layout.width, height: geometry.height).padding(.vertical, 12)
        }
    }
    private func drawStaff(context: GraphicsContext, size: CGSize, layout: ScoreLayout) {
        var lines = Path()
        for i in 0..<5 { let y = CGFloat(80 + i * 12); lines.move(to: CGPoint(x: 16, y: y)); lines.addLine(to: CGPoint(x: size.width - 16, y: y)) }
        context.stroke(lines, with: .color(.gray.opacity(0.7)), lineWidth: 0.8)
        drawGlyph(0xE050, size: 48, baseline: CGPoint(x: 43, y: 116), color: Palette.ink, context: context)
        context.draw(Text("4\n4").font(.system(size: 20, weight: .semibold)).foregroundStyle(Palette.ink), at: CGPoint(x: 82, y: 103))
        let first = Int(layout.firstBeat / 4)
        var boundaries = Set(layout.notes.map { Int($0.start / 4) })
        boundaries.insert(first); boundaries.insert(Int(layout.lastBeat / 4))
        for bar in boundaries.sorted() {
            let x = layout.barX(beat: Double(bar) * 4)
            guard x < size.width - 12 else { continue }
            var line = Path(); line.move(to: CGPoint(x: x, y: 80)); line.addLine(to: CGPoint(x: x, y: 128))
            context.stroke(line, with: .color(.gray), lineWidth: 0.7)
            context.draw(Text("\(bar + 1)").font(.system(size: 11)).foregroundStyle(.gray), at: CGPoint(x: x + 8, y: 58))
        }
    }
    private func draw(_ note: MusicNote, at p: CGPoint, accidental: String?, context: GraphicsContext) {
        let color = Palette.ink, appearance = NoteNotation(duration: freeRhythm ? 1 : note.duration)
        if note.midi == nil {
            if freeRhythm {
                var pause = Path(); pause.move(to: CGPoint(x: p.x - 8, y: p.y)); pause.addLine(to: CGPoint(x: p.x + 8, y: p.y))
                context.stroke(pause, with: .color(color.opacity(0.6)), style: StrokeStyle(lineWidth: 2, lineCap: .round))
            } else {
                let glyph = [0: "\u{E4E5}", 1: "\u{E4E6}", 2: "\u{E4E7}", 3: "\u{E4E8}", 4: "\u{E4E9}"][appearance.flags] ?? "\u{E4E5}"
                let rest = !appearance.filled ? (appearance.stem ? "\u{E4E4}" : "\u{E4E3}") : glyph
                drawGlyph(rest.utf16.first!, size: 48, baseline: p, color: color, context: context)
            }
        } else {
            if p.y > 128 { for y in stride(from: CGFloat(140), through: p.y + 2, by: 12) { ledger(x: p.x, y: y, color: color, context: context) } }
            if p.y < 80 { for y in stride(from: CGFloat(68), through: p.y - 2, by: -12) { ledger(x: p.x, y: y, color: color, context: context) } }
            let head = Path(ellipseIn: CGRect(x: p.x - 7, y: p.y - 5, width: 14, height: 10))
            if appearance.filled { context.fill(head, with: .color(color)) } else { context.stroke(head, with: .color(color), lineWidth: 1.7) }
            let down = p.y < 104
            if appearance.stem && !freeRhythm {
                let x = p.x + (down ? -6 : 6), end = p.y + (down ? 32 : -32)
                var stem = Path(); stem.move(to: CGPoint(x: x, y: p.y)); stem.addLine(to: CGPoint(x: x, y: end)); context.stroke(stem, with: .color(color), lineWidth: 1.5)
                for level in 0..<appearance.flags {
                    let top = end + CGFloat(level) * (down ? -7 : 7)
                    var flag = Path(); flag.move(to: CGPoint(x: x, y: top)); flag.addQuadCurve(to: CGPoint(x: x + 2, y: top + (down ? -20 : 20)), control: CGPoint(x: x + 17, y: top + (down ? -10 : 10)))
                    context.stroke(flag, with: .color(color), lineWidth: 1.7)
                }
            }
            if let accidental { drawGlyph(accidental.utf16.first!, size: 40, baseline: CGPoint(x: p.x - 22, y: p.y), color: color, context: context) }
        }
        if appearance.dotted { context.fill(Path(ellipseIn: CGRect(x: p.x + 12, y: p.y - 4, width: 4, height: 4)), with: .color(color)) }
        if note.id == selected { context.stroke(Path(roundedRect: CGRect(x: p.x - 20, y: p.y - 18, width: 40, height: 36), cornerRadius: 8), with: .color(.blue), lineWidth: 2) }
        if note.confidence < 0.8 { context.draw(Text(Image(systemName: "questionmark.circle.fill")).font(.system(size: 13)).foregroundStyle(Color(red: 0.54, green: 0.38, blue: 0.02)), at: CGPoint(x: p.x, y: p.y - 50)) }
        if note.tied { var tie = Path(); tie.move(to: CGPoint(x: p.x + 8, y: p.y + 12)); tie.addQuadCurve(to: CGPoint(x: p.x + 38, y: p.y + 12), control: CGPoint(x: p.x + 23, y: p.y + 26)); context.stroke(tie, with: .color(color), lineWidth: 1.4) }
    }
    private func ledger(x: CGFloat, y: CGFloat, color: Color, context: GraphicsContext) {
        var path = Path(); path.move(to: CGPoint(x: x - 12, y: y)); path.addLine(to: CGPoint(x: x + 12, y: y)); context.stroke(path, with: .color(color), lineWidth: 1)
    }
    private func drawGlyph(_ code: UniChar, size: CGFloat, baseline: CGPoint, color: Color, context: GraphicsContext) {
        let font = CTFontCreateWithName("Bravura" as CFString, size, nil)
        var character = code, glyph: CGGlyph = 0, advance = CGSize.zero
        guard CTFontGetGlyphsForCharacters(font, &character, &glyph, 1), glyph != 0 else { return }
        CTFontGetAdvancesForGlyphs(font, .horizontal, &glyph, &advance, 1)
        var position = CGPoint(x: -advance.width / 2, y: 0)
        var painter = context
        painter.withCGContext { cg in
            cg.saveGState(); cg.translateBy(x: baseline.x, y: baseline.y); cg.scaleBy(x: 1, y: -1)
            cg.setFillColor(UIColor(color).cgColor); cg.setTextDrawingMode(.fill)
            CTFontDrawGlyphs(font, &glyph, &position, 1, cg); cg.restoreGState()
        }
    }
}
