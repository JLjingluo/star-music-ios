import Foundation

enum MusicEdits {
    static func sameMusic(_ a: [MusicNote], _ b: [MusicNote]) -> Bool {
        a.count == b.count && zip(a, b).allSatisfy { $0.id == $1.id && $0.midi == $1.midi && $0.start == $1.start && $0.duration == $1.duration && $0.tied == $1.tied }
    }
    static func attachOriginal(_ track: inout MusicTrack, file: String, duration: Double) {
        if let old = track.recordingFile {
            for i in track.notes.indices where track.notes[i].sourceFile == nil { track.notes[i].sourceFile = old }
            track.sourceHistory = Array(Set((track.sourceHistory ?? []) + [old])).sorted()
        }
        track.recordingFile = file; track.recordingSeconds = duration; track.trimStart = nil; track.trimEnd = nil; track.useOriginalAudio = true
    }
    static func split(_ note: MusicNote) -> (MusicNote, MusicNote) {
        var first = note, second = note; second.id = UUID()
        first.duration = note.duration / 2; second.start += first.duration; second.duration = note.duration - first.duration
        if let raw = note.rawDuration { first.rawDuration = raw / 2; second.rawStart = (note.rawStart ?? 0) + raw / 2; second.rawDuration = raw - raw / 2 }
        return (first, second)
    }
    static func merged(_ first: MusicNote, _ second: MusicNote) throws -> MusicNote {
        guard first.sourceFile == second.sourceFile else { throw MusicError.save("不同录音的声音不能直接合并，请分别编辑") }
        var note = first
        note.start = min(first.start, second.start)
        note.duration = max(first.start + first.duration, second.start + second.duration) - note.start
        if let a = first.rawStart, let al = first.rawDuration, let b = second.rawStart, let bl = second.rawDuration {
            note.rawStart = min(a, b); note.rawDuration = max(a + al, b + bl) - min(a, b)
        } else { note.rawStart = nil; note.rawDuration = nil }
        note.confidence = min(first.confidence, second.confidence)
        return note
    }
    static func offset(_ track: MusicTrack, to newStart: Double) throws -> MusicTrack {
        let delta = newStart - (track.sourceStartBeat ?? 0)
        guard newStart >= 0, track.notes.allSatisfy({ $0.start + delta >= 0 }) else { throw MusicError.save("这次移动会把旋律推到起点之前，请少移动一点") }
        var result = track; result.sourceStartBeat = newStart
        for i in result.notes.indices { result.notes[i].start += delta }
        return result
    }
    static func partition(_ track: MusicTrack, ids: Set<UUID>, name: String) -> (MusicTrack, MusicTrack) {
        var original = track, part = track
        original.notes.removeAll { ids.contains($0.id) }; original.useOriginalAudio = false
        part.id = UUID(); part.name = MusicProject.projectName(name); part.notes = track.notes.filter { ids.contains($0.id) }; part.useOriginalAudio = false
        return (original, part)
    }
    static func originalStart(_ note: MusicNote, track: MusicTrack, bpm: Double) -> Double {
        note.rawStart ?? max(0, note.start - (track.sourceStartBeat ?? 0)) * 60 / bpm
    }
}

struct PreparedAudio {
    var url: URL
    var duration: Double
    var name: String { url.lastPathComponent }
    func discard() { try? FileManager.default.removeItem(at: url) }
}
enum AudioImport {
    /// Files remain staged and unreferenced until both copying and bounded decoding succeed.
    static func prepare(_ source: URL, directory: URL) async throws -> PreparedAudio {
        let name = UUID().uuidString + "." + source.pathExtension.lowercased()
        let target = directory.appendingPathComponent(name)
        var valid = false; defer { if !valid { try? FileManager.default.removeItem(at: target) } }
        try FileManager.default.copyItem(at: source, to: target)
        let decoding = Task.detached(priority: .userInitiated) { try AudioController.samples(from: target) }
        let decoded = try await withTaskCancellationHandler(operation: { try await decoding.value }, onCancel: { decoding.cancel() })
        try Task.checkCancellation()
        guard !decoded.samples.isEmpty else { throw MusicError.noNotes }
        valid = true
        return PreparedAudio(url: target, duration: Double(decoded.samples.count) / decoded.sampleRate)
    }
}

struct NoteNotation {
    var flags: Int
    var dotted: Bool
    var filled: Bool
    var stem: Bool
    var rest: String
    init(duration: Double) {
        let powers = [0.0625, 0.125, 0.25, 0.5, 1, 2, 4, 8]
        let dotBase = powers.first { abs(duration - $0 * 1.5) < 0.00001 }
        let base = dotBase ?? powers.min(by: { abs($0 - duration) < abs($1 - duration) }) ?? 1
        dotted = dotBase != nil; filled = base < 2; stem = base < 4
        flags = base < 1 ? min(4, max(0, Int((-log2(base)).rounded()))) : 0
        rest = base >= 4 ? "𝄻" : base >= 2 ? "𝄼" : base >= 1 ? "𝄽" : base >= 0.5 ? "𝄾" : base >= 0.25 ? "𝄿" : "𝅀"
    }
}

// All music creation also has a coordinate-free path for VoiceOver and keyboard users.

struct ScoreGeometry {
    var offset: CGFloat
    var height: CGFloat
    static func rawY(_ note: MusicNote) -> CGFloat { 128 - CGFloat(note.staffPosition - 37) * 6 }
    init(notes: [MusicNote]) {
        offset = max(0, 30 - (notes.map(Self.rawY).min() ?? 80))
        height = max(235, (notes.map(Self.rawY).max() ?? 128) + offset + 40)
    }
    func y(_ note: MusicNote) -> CGFloat { Self.rawY(note) + offset }
}
