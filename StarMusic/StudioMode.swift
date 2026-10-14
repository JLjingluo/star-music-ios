import SwiftUI

enum StudioMode: String, CaseIterable, Identifiable {
    case simple, standard, professional
    var id: String { rawValue }
    var title: String { switch self { case .simple: "简洁"; case .standard: "普通"; case .professional: "专业" } }
    var detail: String { switch self {
    case .simple: "只留下录唱、试听和换调，其他工具需要时再打开。"
    case .standard: "用直白说明修改旋律、添加声音，无需先懂乐理。"
    case .professional: "展开多轨、来源音频、时间定位和识别引擎。"
    } }
}

struct StudioModeMenu: View {
    @AppStorage("studioMode") private var rawMode = StudioMode.standard.rawValue
    var body: some View {
        Menu {
            Picker("创作模式", selection: $rawMode) {
                ForEach(StudioMode.allCases) { mode in Text(mode.title + "模式").tag(mode.rawValue) }
            }
            Text("切换模式保留音符、音轨与原始录音。")
        } label: {
            HStack(spacing: 5) { Text((StudioMode(rawValue: rawMode) ?? .standard).title + "模式"); Image(systemName: "chevron.down").font(.caption2) }
                .font(.caption).frame(minHeight: 44)
        }.accessibilityIdentifier("studio.modeMenu")
    }
}
