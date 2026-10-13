import XCTest
@testable import StarMusic

final class MusicTests: XCTestCase {
    func testPitchDetectionUsesActualSamples() {
        let rate = 44100.0
        let data = (0..<2048).map { Float(0.3 * sin(2 * Double.pi * 440 * Double($0) / rate)) }
        let pitch = PitchAnalyzer.detect(data[...], rate: rate)
        XCTAssertEqual(pitch?.midi, 69)
        XCTAssertNil(PitchAnalyzer.detect(Array(repeating: Float(0), count: 2048)[...], rate: rate))
    }
    func testPitchAnalysisPreservesUnquantizedTiming() throws {
        let rate = 22050.0
        let data = (0..<22050).map { i -> Float in i < 4410 ? 0 : Float(0.3 * sin(2 * Double.pi * 440 * Double(i) / rate)) }
        let notes = try PitchAnalyzer.analyze(data, sampleRate: rate, bpm: 120, free: true)
        XCTAssertEqual(notes.first?.midi, 69)
        XCTAssertGreaterThan(notes.first?.rawStart ?? 0, 0.14)
        XCTAssertLessThan(notes.first?.rawStart ?? 1, 0.25)
        XCTAssertGreaterThan(notes.first?.rawDuration ?? 0, 0.6)
    }
    func testMIDIRoundTrip() throws {
        var p = MusicProject(); p.bpm = 123
        p.tracks = [MusicTrack(instrument: .guitar, notes: [MusicNote(midi: 60, start: 0, duration: 1), MusicNote(midi: 64, start: 1, duration: 0.5), MusicNote(midi: nil, start: 1.5, duration: 0.5), MusicNote(midi: 67, start: 2, duration: 2)])]
        let parsed = try MIDI.parse(MIDI.export(p))
        XCTAssertEqual(parsed.bpm, p.bpm, accuracy: 0.01)
        XCTAssertEqual(parsed.tracks[0].instrument, .guitar)
        XCTAssertEqual(parsed.tracks[0].notes.map(\.midi), [60, 64, 67])
        XCTAssertEqual(parsed.tracks[0].notes.map(\.start), [0, 1, 2])
        XCTAssertEqual(parsed.tracks[0].notes.map(\.duration), [1, 0.5, 2])
    }
    func testMIDIPolyphonicRepeatedNotesAndMalformedInput() throws {
        var p = MusicProject(); p.tracks[0].notes = [MusicNote(midi: 60, start: 0, duration: 2), MusicNote(midi: 60, start: 1, duration: 2)]
        let parsed = try MIDI.parse(MIDI.export(p))
        XCTAssertEqual(parsed.tracks[0].notes.count, 2)
        XCTAssertThrowsError(try MIDI.parse(Data([1, 2, 3])))
    }
    func testWAVHasConsistentPCMHeader() {
        let data = AudioRenderer.pcmWAV([0, 0.5, -0.5], rate: 44100)
        XCTAssertEqual(data.count, 50)
        XCTAssertEqual(String(decoding: data.prefix(4), as: UTF8.self), "RIFF")
        XCTAssertEqual(Array(data[40..<44]), [6, 0, 0, 0])
        XCTAssertEqual(Array(data[46..<48]), [255, 63])
    }
    func testInvalidProjectsRejectUnsafeData() {
        var p = MusicProject(); p.recordingFile = "../private.wav"; XCTAssertThrowsError(try p.validate())
        p.recordingFile = nil; p.tracks[0].notes = [MusicNote(midi: 60, start: 0, duration: -1)]; XCTAssertThrowsError(try p.validate())
        p.tracks[0].notes = []; p.bpm = .infinity; XCTAssertThrowsError(try p.validate())
    }
    @MainActor func testAtomicSaveIndependentCopyAndRecovery() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        let store = ProjectStore(root: root); var p = MusicProject(); p.name = "我的旋律"
        p.tracks[0].notes = [MusicNote(midi: 69, start: 0, duration: 1)]
        try store.save(p); try store.duplicate(p)
        let copy = try XCTUnwrap(store.projects.first { $0.name == "我的旋律 · 副本" })
        XCTAssertNotEqual(copy.id, p.id); XCTAssertNotEqual(copy.tracks[0].id, p.tracks[0].id)
        p.deleted = true; try store.save(p)
        let reopened = ProjectStore(root: root)
        XCTAssertTrue(try XCTUnwrap(reopened.projects.first { $0.id == p.id }).deleted)
        XCTAssertFalse(try XCTUnwrap(reopened.projects.first { $0.id == copy.id }).deleted)
        store.update(p) { $0.deleted = false }
        XCTAssertFalse(try XCTUnwrap(store.projects.first { $0.id == p.id }).deleted)
    }
    @MainActor func testProjectPackageRetainsOriginalRecording() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        let store = ProjectStore(root: root); var p = MusicProject(); p.recordingFile = "original.wav"
        let audio = AudioRenderer.pcmWAV([0, 0.1, -0.1], rate: 44100)
        try audio.write(to: store.recordingDirectory.appendingPathComponent("original.wav"))
        try store.save(p); let url = try store.package(p)
        defer { try? FileManager.default.removeItem(at: url) }
        let imported = try store.importPackage(Data(contentsOf: url))
        XCTAssertNotEqual(imported.id, p.id); XCTAssertNotEqual(imported.recordingFile, p.recordingFile)
        let recordingURL = try XCTUnwrap(store.recordingURL(imported))
        XCTAssertEqual(try Data(contentsOf: recordingURL), audio)
    }
    @MainActor func testUndoRedoRestoreRealMusicalContent() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        let store = ProjectStore(root: root), session = EditorSession(MusicProject(), store: store)
        session.addNote(midi: 69, start: 0)
        XCTAssertEqual(session.track.notes.count, 1)
        session.undo(); XCTAssertTrue(session.track.notes.isEmpty)
        session.redo(); XCTAssertEqual(session.track.notes.first?.midi, 69)
        XCTAssertEqual(session.saveStatus, "已保存到本地")
    }
}
