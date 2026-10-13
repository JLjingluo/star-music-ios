import Foundation

// Bridges a single exported project from the earlier browser implementation.
// Web drafts are not read remotely; users export the file and import it on iOS.
enum WebProjectImport {
    private struct Package: Decodable { var format: String; var version: Int; var project: Project; var recording: String? }
    private struct Project: Decodable {
        var name: String; var bpm: Double; var key: String?; var free: Bool?; var favorite: Bool?; var folder: String?; var source: Source?; var tracks: [Track]
    }
    private struct Source: Decodable { var title: String?; var author: String?; var version: Int? }
    private struct Track: Decodable { var name: String; var instrument: String; var volume: Double; var mute: Bool?; var solo: Bool?; var notes: [Note]; var assignment: Assignment? }
    private struct Assignment: Decodable { var scope: String?; var startBar: Int?; var endBar: Int? }
    private struct Note: Decodable { var midi: Int?; var start: Double; var duration: Double; var confidence: Double?; var rawStart: Double?; var rawDuration: Double?; var tie: Bool? }
    static func decode(_ data: Data) throws -> ProjectPackage {
        let pack = try JSONDecoder().decode(Package.self, from: data)
        guard pack.format == "StarMusic", pack.version == 1 else { throw MusicError.invalidProject }
        var p = MusicProject(); p.name = pack.project.name; p.bpm = pack.project.bpm; p.key = pack.project.key ?? "C"; p.freeRhythm = pack.project.free ?? false; p.favorite = pack.project.favorite ?? false; p.folder = pack.project.folder ?? "未分类"
        p.tracks = try pack.project.tracks.map { track in
            guard let instrument = Instrument(rawValue: track.instrument) else { throw MusicError.invalidProject }
            var t = MusicTrack(name: track.name, instrument: instrument, volume: track.volume, muted: track.mute ?? false, solo: track.solo ?? false)
            t.notes = track.notes.map { MusicNote(midi: $0.midi, start: $0.start, duration: $0.duration, confidence: $0.confidence ?? 1, rawStart: $0.rawStart, rawDuration: $0.rawDuration, tied: $0.tie ?? false) }
            if let a = track.assignment { t.assignment = "\(a.scope ?? "track") · 第 \(a.startBar ?? 1)–\(a.endBar ?? 1) 小节" }
            return t
        }
        if let source = pack.project.source { p.source = "来源：\(source.title ?? "示例")，作者：\(source.author ?? "内置示例")，版本 \(source.version ?? 1)" }
        var recording: Data?
        if let raw = pack.recording {
            guard raw.hasPrefix("data:audio/"), let marker = raw.range(of: ";base64,"), let bytes = Data(base64Encoded: String(raw[marker.upperBound...])) else { throw MusicError.invalidProject }
            guard bytes.count <= 32 * 1024 * 1024 else { throw MusicError.tooLarge }
            // Actual audio format is resolved by AVAudioFile, independent of extension.
            recording = bytes; p.recordingFile = "imported.wav"
        }
        try p.validate(); return ProjectPackage(project: p, recording: recording)
    }
}
