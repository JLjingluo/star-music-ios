import SwiftUI

struct MiniScore: View {
    var notes: [MusicNote]
    var body: some View {
        Canvas { context, size in
            let center = size.height * 0.54
            var lines = Path()
            for row in -2...2 {
                let y = center + CGFloat(row) * 6
                lines.move(to: CGPoint(x: 6, y: y)); lines.addLine(to: CGPoint(x: size.width - 6, y: y))
            }
            context.stroke(lines, with: .color(Palette.ink.opacity(0.2)), lineWidth: 0.6)
            let visible = Array(notes.prefix(size.width > 100 ? 12 : 4))
            for (index, note) in visible.enumerated() {
                let x = 12 + CGFloat(index) * max(6, (size.width - 24) / CGFloat(max(visible.count, 1)))
                let y = center - CGFloat(max(-5, min(5, note.staffPosition - 37))) * 3
                if note.midi == nil { context.draw(Text("𝄽").font(.system(size: 15)).foregroundStyle(Palette.ink), at: CGPoint(x: x, y: center)); continue }
                context.fill(Path(ellipseIn: CGRect(x: x - 3, y: y - 2, width: 6, height: 4)), with: .color(Palette.ink.opacity(0.8)))
                var stem = Path(); stem.move(to: CGPoint(x: x + 2, y: y)); stem.addLine(to: CGPoint(x: x + 2, y: y - 13))
                context.stroke(stem, with: .color(Palette.ink.opacity(0.8)), lineWidth: 0.8)
            }
        }.background(Palette.paper.opacity(0.93), in: RoundedRectangle(cornerRadius: 10)).accessibilityHidden(true)
    }
}

struct PlaybackGlyph: View {
    var playing: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body: some View {
        Image(systemName: playing ? "pause.fill" : "play.fill")
            .contentTransition(reduceMotion ? .identity : .symbolEffect(.replace))
    }
}
