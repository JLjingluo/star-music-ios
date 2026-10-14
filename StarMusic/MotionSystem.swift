import SwiftUI
import UIKit

/// Finite entrance transitions, independent from actual loading and save state.
struct CascadeEntrance: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOver
    @State private var appeared = false
    var order: Int
    func body(content: Content) -> some View {
        content.opacity(appeared ? 1 : 0)
            .offset(y: appeared || reduceMotion || voiceOver ? 0 : 16)
            .blur(radius: appeared || reduceMotion || voiceOver ? 0 : 2)
            .task {
                guard !appeared else { return }
                if reduceMotion || voiceOver {
                    var transaction = Transaction(); transaction.disablesAnimations = true
                    withTransaction(transaction) { appeared = true }
                } else {
                    let delay = Double(min(max(order, 0), 8)) * 0.065
                    withAnimation(.spring(duration: 0.56, bounce: 0.08).delay(delay)) { appeared = true }
                }
            }
    }
}
struct MusicPressStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isEnabled) private var enabled
    @AppStorage("hapticsEnabled") private var haptics = true
    var scale: CGFloat = 0.975
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.scaleEffect(configuration.isPressed && !reduceMotion ? scale : 1)
            .opacity(enabled ? (configuration.isPressed ? 0.87 : 1) : 0.4)
            .animation(reduceMotion ? nil : .spring(response: 0.25, dampingFraction: 0.76), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed && enabled && haptics { UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.45) }
            }
    }
}
extension View { func cascade(_ order: Int) -> some View { modifier(CascadeEntrance(order: order)) } }
struct MusicTabBar: View {
    @Binding var selection: Int
    @Environment(\.colorScheme) private var scheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Namespace private var indicator
    private let titles = ["创作", "社区", "消息", "我的"]
    private let symbols = ["waveform.path", "square.stack", "bubble.left.and.bubble.right", "person.crop.circle"]
    private let identifiers = ["tab.create", "tab.community", "tab.messages", "tab.profile"]
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<4, id: \.self) { index in
                Button {
                    if reduceMotion { selection = index }
                    else { withAnimation(.spring(response: 0.36, dampingFraction: 0.82)) { selection = index } }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: symbols[index]).font(.system(size: 19, weight: selection == index ? .semibold : .regular))
                            .foregroundStyle(selection == index ? Palette.gold : Color.secondary)
                        Text(titles[index]).font(.caption2.weight(selection == index ? .semibold : .regular))
                            .foregroundStyle(selection == index ? Color.primary : Color.secondary)
                    }.frame(maxWidth: .infinity).frame(minHeight: 52)
                        .background {
                            if selection == index {
                                RoundedRectangle(cornerRadius: 18).fill(Palette.gold.opacity(scheme == .dark ? 0.09 : 0.19))
                                    .matchedGeometryEffect(id: "activeTab", in: indicator)
                            }
                        }
                }.buttonStyle(MusicPressStyle(scale: 0.95)).accessibilityIdentifier(identifiers[index])
                    .accessibilityLabel(titles[index]).accessibilityAddTraits(selection == index ? .isSelected : [])
            }
        }.padding(7).background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 25))
            .overlay(RoundedRectangle(cornerRadius: 25).stroke(.primary.opacity(0.065), lineWidth: 0.7))
            .shadow(color: .black.opacity(scheme == .dark ? 0.22 : 0.07), radius: 18, x: 0, y: 7)
            .padding(.horizontal, 20).padding(.top, 8).padding(.bottom, 5)
    }
}

/// The item views stay alive while their positions and widths change.
struct DraftCollectionLayout: Layout {
    var columns: Int
    var spacing: CGFloat = 12
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 340
        let itemWidth = (width - CGFloat(columns - 1) * spacing) / CGFloat(columns)
        var height: CGFloat = 0
        for first in stride(from: 0, to: subviews.count, by: columns) {
            let rowHeight = (first..<min(first + columns, subviews.count)).map { subviews[$0].sizeThatFits(.init(width: itemWidth, height: nil)).height }.max() ?? 0
            height += rowHeight + (first == 0 ? 0 : spacing)
        }
        return CGSize(width: width, height: height)
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let itemWidth = (bounds.width - CGFloat(columns - 1) * spacing) / CGFloat(columns)
        var y = bounds.minY
        for first in stride(from: 0, to: subviews.count, by: columns) {
            let end = min(first + columns, subviews.count)
            let rowHeight = (first..<end).map { subviews[$0].sizeThatFits(.init(width: itemWidth, height: nil)).height }.max() ?? 0
            for index in first..<end {
                subviews[index].place(at: CGPoint(x: bounds.minX + CGFloat(index - first) * (itemWidth + spacing), y: y), anchor: .topLeading, proposal: .init(width: itemWidth, height: rowHeight))
            }
            y += rowHeight + spacing
        }
    }
}

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

struct LikeBurstButton: View {
    var selected: Bool
    var action: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var burst = false
    @State private var release: Task<Void, Never>?
    var body: some View {
        Button {
            action()
            guard !selected, !reduceMotion else { return }
            release?.cancel(); burst = false
            withAnimation(.spring(response: 0.4, dampingFraction: 0.52)) { burst = true }
            release = Task { try? await Task.sleep(for: .milliseconds(550)); guard !Task.isCancelled else { return }; withAnimation(.easeOut(duration: 0.2)) { burst = false } }
        } label: {
            HStack(spacing: 6) {
                ZStack {
                    ForEach(0..<8, id: \.self) { i in
                        Circle().fill(Palette.gold).frame(width: 3, height: 3)
                            .offset(x: burst ? cos(Double(i) * .pi / 4) * 18 : 0, y: burst ? sin(Double(i) * .pi / 4) * 18 : 0)
                            .opacity(burst ? 0.7 : 0).accessibilityHidden(true)
                    }
                    Image(systemName: selected ? "heart.fill" : "heart").foregroundStyle(selected ? Palette.gold : Color.secondary)
                        .scaleEffect(burst ? 1.12 : 1)
                        .contentTransition(.symbolEffect(.replace))
                }.frame(width: 26, height: 26)
                Text(selected ? "已喜欢" : "喜欢").font(.caption)
            }.frame(minHeight: 44)
        }.buttonStyle(MusicPressStyle()).accessibilityLabel(selected ? "取消本地喜欢" : "在本地喜欢")
            .accessibilityValue(selected ? "已喜欢" : "未喜欢").transaction { if reduceMotion { $0.disablesAnimations = true } }.onDisappear { release?.cancel() }
    }
}

struct JellyToggleStyle: ToggleStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer(minLength: 16)
            Button {
                withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.68)) { configuration.isOn.toggle() }
            } label: {
                RoundedRectangle(cornerRadius: 18).fill(configuration.isOn ? Palette.gold : Color.secondary.opacity(0.24))
                    .frame(width: 50, height: 30)
                    .overlay {
                        Circle().fill(.white).frame(width: 24, height: 24).shadow(color: .black.opacity(0.13), radius: 2, y: 1).offset(x: configuration.isOn ? 10 : -10)
                    }.frame(width: 50, height: 44)
            }.buttonStyle(MusicPressStyle(scale: 0.94)).accessibilityLabel(Text("轻触反馈"))
                .accessibilityValue(configuration.isOn ? "开启" : "关闭")
        }
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
