import Foundation

struct MusicNote: Codable, Identifiable, Equatable, Sendable {
    var id = UUID()
    var midi: Int?
    var start: Double
    var duration: Double
    var confidence: Double = 1
    var rawStart: Double?
    var rawDuration: Double?
    var tied: Bool = false
    var sourceFile: String?
    var pitchName: String {
        guard let midi else { return "休止符" }
        return ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"][midi % 12] + String(midi / 12 - 1)
    }
    var staffPosition: Int { (midi ?? 64) / 12 * 7 + [0, 0, 1, 1, 2, 3, 3, 4, 4, 5, 5, 6][(midi ?? 64) % 12] }
}

enum Instrument: String, Codable, CaseIterable, Identifiable, Sendable {
    case piano, guitar, synth
    var id: String { rawValue }
    var name: String { switch self { case .piano: "柔和钢琴"; case .guitar: "原声木吉他"; case .synth: "星空合成器" } }
    var symbol: String { switch self { case .piano: "pianokeys"; case .guitar: "guitars"; case .synth: "sparkles" } }
    var category: String { switch self { case .piano: "键盘"; case .guitar: "吉他"; case .synth: "电子" } }
}

struct MusicTrack: Codable, Identifiable, Equatable, Sendable {
    var id = UUID()
    var name = "主旋律"
    var instrument: Instrument = .piano
    var volume: Double = 0.7
    var muted = false
    var solo = false
    var notes: [MusicNote] = []
    var assignment: String?
    var recordingFile: String?
    var recordingSeconds: Double?
    var useOriginalAudio: Bool?
    var sourceStartBeat: Double?
    var trimStart: Double?
    var trimEnd: Double?
    var transcript: String?
    var recognitionSource: String?
    var sourceHistory: [String]?
    var sourceDuration: Double { max(0, (trimEnd ?? recordingSeconds ?? 0) - (trimStart ?? 0)) }
}

struct MusicProject: Codable, Identifiable, Equatable, Sendable {
    static func validRecordingName(_ file: String) -> Bool { !file.isEmpty && file.count <= 240 && file != "." && file != ".." && !file.contains("/") && !file.contains("\\") && !file.contains("\0") }
    var id = UUID()
    var name = "未命名的旋律"
    var bpm: Double = 96
    var key = "C"
    var created = Date()
    var updated = Date()
    var favorite = false
    var folder = "未分类"
    var deleted = false
    var sample = false
    var freeRhythm = false
    var revision: Int?
    var recordingFile: String?
    var recordingSeconds: Double?
    var source: String?
    var tracks = [MusicTrack()]
    var audioFiles: Set<String> { Set(tracks.flatMap { ($0.sourceHistory ?? []) + [$0.recordingFile].compactMap { $0 } + $0.notes.compactMap(\.sourceFile) } + [recordingFile].compactMap { $0 }) }
    var beats: Double {
        let notes = tracks.flatMap(\.notes).map { $0.start + $0.duration }.max() ?? 4
        let clips = tracks.filter { $0.recordingFile != nil && $0.useOriginalAudio == true }.map { ($0.sourceStartBeat ?? 0) + $0.sourceDuration * bpm / 60 }.max() ?? 0
        return max(max(4, notes), clips)
    }
    var seconds: Double {
        let solo = tracks.contains { $0.solo }
        let ends = tracks.filter { !$0.muted && (!solo || $0.solo) }.map { track -> Double in
            if track.useOriginalAudio == true { return (track.sourceStartBeat ?? 0) + track.sourceDuration * bpm / 60 }
            return track.notes.filter { $0.midi != nil }.map { $0.start + $0.duration }.max() ?? 0
        }
        return max(4, ends.max() ?? 0) * 60 / bpm
    }
    // Legacy root fields migrate only at document boundaries, never by track position during playback.
    func migratingLegacyRecording() -> MusicProject {
        var p = self
        guard !p.tracks.isEmpty else { return p }
        if let file = p.recordingFile {
            if p.tracks[0].recordingFile == nil { p.tracks[0].recordingFile = file }
            if p.tracks[0].recordingFile == file, p.tracks[0].recordingSeconds == nil { p.tracks[0].recordingSeconds = p.recordingSeconds }
        }
        p.syncLegacyRecording(); return p
    }
    mutating func syncLegacyRecording() {
        recordingFile = tracks.first?.recordingFile; recordingSeconds = tracks.first?.recordingSeconds
    }
    static func projectName(_ value: String, suffix: String = "") -> String {
        let clean = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return String((clean.isEmpty ? "未命名的旋律" : clean).prefix(max(1, 120 - suffix.count))) + suffix
    }
    var bars: Int { max(1, Int(ceil(beats / 4))) }
    static func example(_ index: Int) -> MusicProject {
        let names = ["晚风的形状", "周末即兴", "雨落之前"]
        let tunes = [[64, 67, 71, 69, 67, 64, 62, 64, 67, 69, 71, 72, 71, 67, 64, 62], [60, 64, 67, 64, 62, 65, 69, 65, 64, 67, 71, 67], [60, 67, 72, 74, 71, 67, 64, 67, 72, 76, 74, 72, 71, 67, 64, 60]]
        var p = MusicProject(); p.name = names[index % 3]; p.sample = true; p.bpm = 84
        p.tracks[0].instrument = Instrument.allCases[index % 3]
        p.tracks[0].notes = tunes[index % 3].enumerated().map { MusicNote(midi: $0.element, start: Double($0.offset), duration: 1) }
        return p
    }
    func validate() throws {
        guard (1...128).contains(tracks.count), tracks.reduce(0, { $0 + $1.notes.count }) <= 20000 else { throw MusicError.projectCapacity }
        guard !name.isEmpty, name.count <= 120, bpm.isFinite, (30...300).contains(bpm) else { throw MusicError.invalidProject }
        guard recordingFile.map(Self.validRecordingName) ?? true, recordingSeconds.map({ $0.isFinite && $0 >= 0 && $0 <= 100000 }) ?? true else { throw MusicError.invalidProject }
        var count = 0
        for track in tracks {
            guard track.volume.isFinite, (0...1).contains(track.volume) else { throw MusicError.invalidProject }
            guard track.recordingFile.map(Self.validRecordingName) ?? true else { throw MusicError.invalidProject }
            for file in track.sourceHistory ?? [] { guard Self.validRecordingName(file) else { throw MusicError.invalidProject } }
            for value in [track.recordingSeconds, track.sourceStartBeat, track.trimStart, track.trimEnd].compactMap({ $0 }) { guard value.isFinite, value >= 0, value <= 100000 else { throw MusicError.invalidProject } }
            guard (track.trimEnd ?? track.recordingSeconds ?? 0) >= (track.trimStart ?? 0) else { throw MusicError.invalidProject }
            if let length = track.recordingSeconds, let end = track.trimEnd { guard end <= length + 0.01 else { throw MusicError.invalidProject } }
            for note in track.notes {
                count += 1
                guard note.sourceFile.map(Self.validRecordingName) ?? true else { throw MusicError.invalidProject }
                guard count <= 20000, note.start.isFinite, note.start >= 0, note.duration.isFinite, note.duration > 0, note.start + note.duration <= 100000,
                      note.midi == nil || (0...127).contains(note.midi!), note.confidence.isFinite, (0...1).contains(note.confidence) else { throw MusicError.invalidProject }
                for value in [note.rawStart, note.rawDuration].compactMap({ $0 }) { guard value.isFinite, value >= 0, value <= 100000 else { throw MusicError.invalidProject } }
            }
        }
    }
}

struct ProjectPackage: Codable {
    var format = "StarMusicNative"
    var version = 2
    var project: MusicProject
    var recording: Data?
    var recordings: [String: Data]?
}

enum MusicError: LocalizedError {
    case invalidProject, invalidMIDI, noNotes, permission, tooLarge, midiCapacity, save(String), missingAudio(String), staleRevision, operation(String), unsupportedVersion(Int), projectCapacity, importMemory
    var errorDescription: String? {
        switch self {
        case .invalidProject: "项目数据无效或超出支持范围。"
        case .invalidMIDI: "MIDI 文件不完整，或使用了暂不支持的时间格式。"
        case .midiCapacity: "MIDI 转换后的声部超过 128 条，或包含超出支持范围的内容。原工程不会被修改。"
        case .noNotes: "没有识别出清晰的音符，原始录音仍保留在草稿中。"
        case .permission: "麦克风权限被拒绝。可以前往系统设置允许麦克风，或从空白乐谱开始。"
        case .tooLarge: "支持 256 MB 以内音频文件、512 MB 以内项目包；单次音频分析最长 5 分钟，成品导出最长 10 分钟。"
        case .save(let reason): "保存失败：\(reason)。当前编辑仍保留在内存中。"
        case .missingAudio(let file): "缺少原声附件：\(file)。请从完整项目备份恢复；不会用静音代替缺失录音。"
        case .operation(let reason): "操作未完成：\(reason)。原有内容没有被替换。"
        case .unsupportedVersion(let version): "此工程使用较新的格式版本 \(version)，请更新 Star Music 后重新导入。"
        case .projectCapacity: "一个项目最多支持 128 条音轨和 20,000 个音符。请减少内容后重试。"
        case .importMemory: "当前可用内存不足以安全读取此格式，原文件未修改。请释放内存后重试；较大的旧版项目备份可在内存更充足的设备上打开并导出新版备份。"
        case .staleRevision: "项目已有更新版本，本次旧结果未覆盖它。请重新打开最新草稿。"
        }
    }
}

func musicTime(_ seconds: Double) -> String {
    let n = max(0, Int(seconds)); return String(format: "%02d:%02d", n / 60, n % 60)
}
