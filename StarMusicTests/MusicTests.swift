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
    func testBundledFullNeuralModelPredictsRealSamples() throws {
        let detector = try NeuralPitchDetector()
        for (frequency, midi) in [(130.8128, 48), (220.0, 57), (440.0, 69)] {
            let data = (0..<1024).map { Float(0.3 * sin(2 * Double.pi * frequency * Double($0) / 16000)) }
            let prediction = try XCTUnwrap(detector.detect(data[...]))
            XCTAssertEqual(Int(prediction.midi.rounded()), midi)
            XCTAssertGreaterThan(prediction.confidence, 0.45)
        }
        XCTAssertNil(try detector.detect(Array(repeating: Float(0), count: 1024)[...]))
    }
    func testYINQuietNotesAndStrongHarmonicsAvoidOctaveErrors() throws {
        for midi in stride(from: 45, through: 81, by: 3) {
            for thirdAmplitude in [0.0, 0.02] {
            let frequency = 440 * pow(2, Double(midi - 69) / 12)
            let signal = (0..<2048).map { i -> Float in
                let phase = 2 * Double.pi * frequency * Double(i) / 16000
                return Float(0.007 * sin(phase) + 0.05 * sin(2 * phase) + thirdAmplitude * sin(3 * phase))
            }
            let prediction = try XCTUnwrap(PitchAnalyzer.detect(signal[...], rate: 16000))
            XCTAssertEqual(prediction.midi, midi, "Strong harmonics at MIDI \(midi)")
            }
        }
    }
    func testVibratoDoesNotFragmentNotesAndSilenceBecomesRest() throws {
        var phase = 0.0
        let signal = (0..<32000).map { i -> Float in
            let time = Double(i) / 16000
            if time >= 0.85 && time < 1.1 { return 0 }
            let frequency = (time < 1.1 ? 440.0 : 659.255) * pow(2, 0.3 * sin(2 * Double.pi * 5 * time) / 12)
            phase += 2 * Double.pi * frequency / 16000
            return Float(0.2 * sin(phase))
        }
        let notes = try PitchAnalyzer.analyze(signal, sampleRate: 16000, bpm: 120, free: true)
        XCTAssertEqual(notes.compactMap(\.midi), [69, 76])
        XCTAssertTrue(notes.contains { $0.midi == nil && $0.duration > 0.1 })
    }
    func testHighQualityResamplerPreservesDurationAndPitch() throws {
        let source = (0..<44100).map { Float(0.2 * sin(2 * Double.pi * 440 * Double($0) / 44100)) }
        let converted = try AudioController.resample(source, from: 44100, to: 16000)
        XCTAssertLessThanOrEqual(abs(converted.count - 16000), 64)
        XCTAssertEqual(PitchAnalyzer.detect(converted[2000..<4048], rate: 16000)?.midi, 69)
    }
    func testRecognitionServiceAnalyzesTrimmedFileAndCancellationRetainsOriginal() async throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".wav")
        defer { try? FileManager.default.removeItem(at: url) }
        let signal = (0..<44100).map { Float(0.2 * sin(2 * Double.pi * 440 * Double($0) / 44100)) }
        let bytes = AudioRenderer.pcmWAV(signal, rate: 44100); try bytes.write(to: url)
        var settings = RecognitionSettings(); settings.engine = .neural
        let result = try await RecognitionService.analyze(url: url, bpm: 120, free: true, start: 0.25, end: 0.75, settings: settings)
        XCTAssertEqual(result.notes.compactMap(\.midi), [69])
        XCTAssertEqual(try XCTUnwrap(result.notes.first?.rawStart), 0.25, accuracy: 0.04)
        XCTAssertEqual(try Data(contentsOf: url), bytes)
        let task = Task { try await RecognitionService.analyze(url: url, bpm: 120, free: true, settings: settings) }
        task.cancel()
        do { _ = try await task.value; XCTFail("Cancelled analysis must not produce applied notes") } catch is CancellationError {}
        XCTAssertEqual(try Data(contentsOf: url), bytes)
    }
    func testCloudEndpointAndCandidateValidation() throws {
        var settings = RecognitionSettings(); settings.baseURL = "https://example.test"
        XCTAssertEqual(try settings.endpoint().absoluteString, "https://example.test/chat/completions")
        settings.baseURL = "http://example.test/v1"; XCTAssertThrowsError(try settings.endpoint())
        settings.baseURL = "https://secret@example.test/v1"; XCTAssertThrowsError(try settings.endpoint())
        let valid = "{\"notes\":[{\"midi\":60,\"startSeconds\":0.1,\"durationSeconds\":0.5,\"confidence\":1}],\"transcript\":\"\"}"
        let result = try CloudRecognitionClient.decode(valid, duration: 1, bpm: 120, free: true)
        XCTAssertEqual(result.notes.first?.start, 0.2)
        XCTAssertEqual(result.notes.first?.duration, 1)
        XCTAssertLessThan(result.notes.first?.confidence ?? 1, 0.8)
        XCTAssertThrowsError(try CloudRecognitionClient.decode(valid.replacingOccurrences(of: "60", with: "900"), duration: 1, bpm: 120, free: true))
        XCTAssertThrowsError(try CloudRecognitionClient.decode("{\"notes\":[]}", duration: 1, bpm: 120, free: true))
        XCTAssertThrowsError(try CloudRecognitionClient.decode(valid, duration: 0.2, bpm: 120, free: true))
    }
    func testDeviceKeychainRoundTripAndRemoval() throws {
        let previous = try ModelKeychain.read()
        defer { try? ModelKeychain.save(previous) }
        let fixture = "native-test-" + UUID().uuidString
        try ModelKeychain.save(fixture)
        XCTAssertEqual(try ModelKeychain.read(), fixture)
        try ModelKeychain.save("")
        XCTAssertEqual(try ModelKeychain.read(), "")
    }
    @MainActor func testAllTrackOriginalsAndHistorySurviveCopyAndPackage() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        let store = ProjectStore(root: root)
        let bytes = AudioRenderer.pcmWAV([0, 0.1, -0.1], rate: 44100)
        for file in ["first.wav", "second.wav", "history.wav"] { try bytes.write(to: store.recordingDirectory.appendingPathComponent(file)) }
        var p = MusicProject(); p.name = "Multi source"
        p.tracks[0].recordingFile = "first.wav"; p.tracks[0].sourceHistory = ["history.wav"]
        var second = MusicTrack(name: "second"); second.recordingFile = "second.wav"; p.tracks.append(second)
        try store.save(p); try store.duplicate(p)
        let copy = try XCTUnwrap(store.projects.first { $0.name == "Multi source · 副本" })
        XCTAssertNotEqual(copy.tracks[0].recordingFile, p.tracks[0].recordingFile)
        XCTAssertNotEqual(copy.tracks[1].recordingFile, p.tracks[1].recordingFile)
        XCTAssertNotEqual(copy.tracks[0].sourceHistory, p.tracks[0].sourceHistory)
        let pack = try store.package(p); defer { try? FileManager.default.removeItem(at: pack) }
        let imported = try store.importPackage(Data(contentsOf: pack))
        XCTAssertEqual(imported.tracks.count, 2)
        for track in imported.tracks {
            let url = try XCTUnwrap(store.recordingURL(imported, trackID: track.id))
            XCTAssertEqual(try Data(contentsOf: url), bytes)
        }
        XCTAssertNotEqual(imported.tracks[0].sourceHistory, p.tracks[0].sourceHistory)
        XCTAssertNil(store.recordingURL(MusicProject(), trackID: UUID()))
    }
    @MainActor func testLegacyProjectPackageAndOptionalTrackFieldsMigrate() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        let store = ProjectStore(root: root)
        var project = MusicProject(); project.recordingFile = "old.wav"
        var pack = ProjectPackage(project: project, recording: AudioRenderer.pcmWAV([0, 0.2], rate: 44100)); pack.version = 1
        let restored = try store.importPackage(JSONEncoder().encode(pack))
        XCTAssertNotNil(restored.recordingFile)
        let data = try JSONEncoder().encode(MusicTrack())
        let decoded = try JSONDecoder().decode(MusicTrack.self, from: data)
        XCTAssertNil(decoded.recordingFile)
        var unsafe = MusicProject(); unsafe.tracks[0].recordingFile = ".."
        XCTAssertThrowsError(try unsafe.validate())
    }
    func testSourceAudioUsesSharedTimelineMuteAndTrim() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let source = AudioRenderer.pcmWAV(Array(repeating: Float(0.2), count: 44100), rate: 44100)
        try source.write(to: root.appendingPathComponent("clip.wav"))
        var project = MusicProject(); project.bpm = 60
        project.tracks[0].recordingFile = "clip.wav"; project.tracks[0].recordingSeconds = 1; project.tracks[0].useOriginalAudio = true
        project.tracks[0].sourceStartBeat = 1; project.tracks[0].trimStart = 0.2; project.tracks[0].trimEnd = 0.7
        func value(_ data: Data, _ frame: Int) -> Int16 { let offset = 44 + frame * 2; return Int16(bitPattern: UInt16(data[offset]) | UInt16(data[offset + 1]) << 8) }
        let output = try AudioRenderer.wav(project, recordingDirectory: root)
        XCTAssertEqual(value(output, 22050), 0)
        XCTAssertGreaterThan(value(output, 50000), 1000)
        XCTAssertEqual(value(output, 70000), 0)
        project.tracks[0].muted = true
        XCTAssertEqual(value(try AudioRenderer.wav(project, recordingDirectory: root), 50000), 0)
    }
    func testCloudRequestSendsAudioAndHTTPFailureIsNotSuccess() async throws {
        let configuration = URLSessionConfiguration.ephemeral; configuration.protocolClasses = [AudioAPIStub.self]
        let session = URLSession(configuration: configuration)
        defer { session.invalidateAndCancel(); AudioAPIStub.handler = nil }
        var settings = RecognitionSettings(); settings.model = "test-audio-model"; settings.baseURL = "https://example.test/v1"
        let wav = AudioRenderer.pcmWAV([0, 0.1], rate: 16000)
        AudioAPIStub.handler = { request in
            XCTAssertEqual(request.url?.path, "/v1/chat/completions")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer test-only")
            var bodyData = request.httpBody ?? Data()
            if bodyData.isEmpty, let stream = request.httpBodyStream {
                stream.open(); defer { stream.close() }
                var buffer = [UInt8](repeating: 0, count: 4096)
                while stream.hasBytesAvailable { let count = stream.read(&buffer, maxLength: buffer.count); if count <= 0 { break }; bodyData.append(contentsOf: buffer.prefix(count)) }
            }
            let body = try JSONSerialization.jsonObject(with: bodyData) as! [String: Any]
            let messages = body["messages"] as! [[String: Any]], content = messages[0]["content"] as! [[String: Any]]
            let audio = content[1]["input_audio"] as! [String: String]
            XCTAssertEqual(Data(base64Encoded: audio["data"]!), wav); XCTAssertEqual(audio["format"], "wav")
            let result = "{\"notes\":[{\"midi\":69,\"startSeconds\":0,\"durationSeconds\":0.5}]}"
            return (200, try JSONSerialization.data(withJSONObject: ["choices": [["message": ["content": result]]]]))
        }
        let result = try await CloudRecognitionClient.analyze(wav: wav, duration: 1, bpm: 120, free: true, settings: settings, key: "test-only", session: session)
        XCTAssertEqual(result.notes.first?.midi, 69)
        AudioAPIStub.handler = { _ in (401, Data()) }
        do { _ = try await CloudRecognitionClient.analyze(wav: wav, duration: 1, bpm: 120, free: true, settings: settings, key: "test-only", session: session); XCTFail("HTTP failure must throw") }
        catch RecognitionError.service(let status) { XCTAssertEqual(status, 401) }
    }

    func testSequenceDecoderRejectsBriefOctaveMistakeButKeepsRealLeap() throws {
        let frames = (0..<30).map { i in PitchFrame(time: Double(i) * 0.02, candidates: i == 8 ? [PitchCandidate(midi: 81, confidence: 0.95), PitchCandidate(midi: 69, confidence: 0.50)] : [PitchCandidate(midi: i >= 20 ? 81 : 69, confidence: 0.9)], energy: 0.1) }
        let result = try PitchSequenceDecoder.decode(frames)
        XCTAssertEqual(result[8]?.midi, 69)
        XCTAssertEqual(result[25]?.midi, 81)
    }
    func testTuningOffsetOnlyCorrectsConsistentSmallDetuning() {
        let stable = (0..<40).map { PitchCandidate(midi: Double(60 + $0 % 5) + 0.22, confidence: 0.9) as PitchCandidate? }
        XCTAssertEqual(PitchSequenceDecoder.tuningOffset(stable), 0.22, accuracy: 0.001)
        XCTAssertEqual(PitchSequenceDecoder.tuningOffset([PitchCandidate(midi: 60.2, confidence: 0.9)]), 0)
    }
    func testRepeatedSamePitchIsSeparatedByBreath() throws {
        let signal = (0..<24000).map { i -> Float in
            let t = Double(i) / 16000
            if t >= 0.70 && t < 0.75 { return 0 }
            return Float(0.2 * sin(2 * Double.pi * 440 * t))
        }
        let notes = try PitchAnalyzer.analyze(signal, sampleRate: 16000, bpm: 120, free: true)
        XCTAssertEqual(notes.compactMap(\.midi), [69, 69])
    }
    @MainActor func testWholeSongKeyShiftPreservesIntervalsTimingOriginalAndUndo() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        let store = ProjectStore(root: root)
        var p = MusicProject(); p.tracks[0].notes = [MusicNote(midi: 60, start: 0.13, duration: 0.8), MusicNote(midi: 67, start: 1.1, duration: 0.7), MusicNote(midi: nil, start: 1.8, duration: 0.2)]
        p.tracks[0].recordingFile = "original.wav"; p.tracks[0].useOriginalAudio = true
        p.tracks.append(MusicTrack(name: "Bass", notes: [MusicNote(midi: 48, start: 0, duration: 2)]))
        let shifted = try MelodyTransform.shifted(p, steps: 3)
        XCTAssertEqual(shifted.tracks[0].notes.map(\.midi), [63, 70, nil]); XCTAssertEqual(shifted.tracks[1].notes.first?.midi, 51)
        XCTAssertEqual(shifted.tracks[0].notes.map(\.start), p.tracks[0].notes.map(\.start)); XCTAssertEqual(shifted.tracks[0].notes.map(\.duration), p.tracks[0].notes.map(\.duration)); XCTAssertEqual(shifted.tracks[0].recordingFile, p.tracks[0].recordingFile)
        XCTAssertEqual(shifted.bpm, p.bpm); XCTAssertEqual(shifted.tracks[0].useOriginalAudio, false)
        let session = EditorSession(p, store: store); session.edit { $0 = shifted }; session.undo(); XCTAssertEqual(session.project.tracks, p.tracks)
        session.redo(); XCTAssertEqual(session.project.tracks, shifted.tracks)
    }
    func testKeyShiftRejectsOutOfRangeInsteadOfClippingIntervals() throws {
        var p = MusicProject(); p.tracks[0].notes = [MusicNote(midi: 126, start: 0, duration: 1)]
        XCTAssertThrowsError(try MelodyTransform.shifted(p, steps: 3))
        XCTAssertEqual(try MelodyTransform.shifted(p, steps: -2).tracks[0].notes.first?.midi, 124)
    }

    func testRealHummingValidationSubsetReportsBaselineAndCurrent() throws {
        struct Manifest: Decodable { struct Item: Decodable { var key: String; var audio: String; var midi: String }; var cases: [Item] }
        let bundle = Bundle(for: MusicTests.self)
        let manifestURL = try XCTUnwrap(bundle.url(forResource: "humtrans-cases", withExtension: "json"), "Prepare benchmark resources before XcodeGen")
        let manifest = try JSONDecoder().decode(Manifest.self, from: Data(contentsOf: manifestURL))
        var report: [[String: Any]] = []; var oldCorrect = 0, newCorrect = 0, total = 0
        for item in manifest.cases {
            let audioURL = try XCTUnwrap(bundle.url(forResource: item.audio, withExtension: nil))
            let midiURL = try XCTUnwrap(bundle.url(forResource: item.midi, withExtension: nil))
            let source = try AudioController.samples(from: audioURL)
            let clip = Array(source.samples.prefix(Int(source.sampleRate * 6)))
            let samples = try AudioController.resample(clip, from: source.sampleRate, to: 16000)
            let truth = try MIDI.parse(Data(contentsOf: midiURL))
            let baseline = try LegacyPitchBenchmark.analyze(samples, sampleRate: 16000, bpm: truth.bpm, free: true, engine: .neural)
            let current = try PitchAnalyzer.analyze(samples, sampleRate: 16000, bpm: truth.bpm, free: true, engine: .neural)
            let reference = truth.tracks.flatMap(\.notes).filter { $0.midi != nil }
            func pitch(_ notes: [MusicNote], _ time: Double) -> Int? { notes.first { ($0.rawStart ?? $0.start * 60 / truth.bpm) <= time && ($0.rawStart ?? $0.start * 60 / truth.bpm) + ($0.rawDuration ?? $0.duration * 60 / truth.bpm) > time }?.midi }
            var before = 0, after = 0, count = 0
            for frame in 0..<300 {
                let time = Double(frame) * 0.02
                guard let expected = pitch(reference, time) else { continue }
                count += 1; if pitch(baseline, time) == expected { before += 1 }; if pitch(current, time) == expected { after += 1 }
            }
            oldCorrect += before; newCorrect += after; total += count
            report.append(["key": item.key,"voicedReferenceFrames":count,"baselineCorrect":before,"currentCorrect":after,"baselineNotes":baseline.filter { $0.midi != nil }.count,"currentNotes":current.filter { $0.midi != nil }.count])
        }
        XCTAssertGreaterThan(total, 100)
        // This is a regression comparison on a fixed four-recording subset, not an industry ranking.
        XCTAssertGreaterThanOrEqual(Double(newCorrect) / Double(total), Double(oldCorrect) / Double(total))
        let json: [String: Any] = ["dataset":"HumTrans validation, fixed four singers, first 6 seconds each","source":"https://github.com/shansongliu/HumTrans","baseline":"v0.4.0 max-bin and local segmentation","current":"candidate sequence and energy segmentation","baselinePitchAccuracy":Double(oldCorrect) / Double(total),"currentPitchAccuracy":Double(newCorrect) / Double(total),"referenceVoicedFrames":total,"cases":report,"limits":"Small validation subset; no claim of parity with commercial products. Annotation timing can affect scores."]
        let attachment = XCTAttachment(data: try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted,.sortedKeys]), uniformTypeIdentifier: "public.json")
        attachment.name = "Humming-Accuracy"; attachment.lifetime = .keepAlways; add(attachment)
        print("HUMMING_BENCHMARK baseline=\(oldCorrect)/\(total) current=\(newCorrect)/\(total)")
    }

}

final class AudioAPIStub: URLProtocol {
    static var handler: ((URLRequest) throws -> (Int, Data))?
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        do {
            let (status, data) = try Self.handler!(request)
            let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: "HTTP/1.1", headerFields: ["Content-Type": "application/json"])!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data); client?.urlProtocolDidFinishLoading(self)
        } catch { client?.urlProtocol(self, didFailWithError: error) }
    }
    override func stopLoading() {}
}

private enum LegacyPitchBenchmark {
    private struct Frame {
        var time: Double
        var midi: Double?
        var confidence: Double
    }
    static func analyze(_ data: [Float], sampleRate: Double, bpm: Double, free: Bool, engine: RecognitionEngine = .yin) throws -> [MusicNote] {
        guard data.count >= 512, sampleRate.isFinite, sampleRate > 0, bpm.isFinite, (30...300).contains(bpm) else { throw MusicError.noNotes }
        let neural = engine == .neural ? try NeuralPitchDetector() : nil
        guard neural == nil || abs(sampleRate - 16000) < 1 else { throw RecognitionError.configuration("本地 AI 需要 16 kHz 输入。") }
        let size = neural == nil ? max(1024, Int(sampleRate * 0.096)) : 1024
        let hop = max(1, Int(sampleRate * 0.02)), half = size / 2
        let padded = [Float](repeating: 0, count: half) + data + [Float](repeating: 0, count: size - half)
        let total = Double(data.count) / sampleRate
        var frames: [Frame] = []
        for i in stride(from: 0, to: data.count, by: hop) {
            try Task.checkCancellation()
            let window = padded[i..<(i + size)]
            let pitch = try neural?.detect(window) ?? (neural == nil ? PitchAnalyzer.estimate(window, rate: sampleRate) : nil)
            frames.append(Frame(time: Double(i) / sampleRate, midi: pitch?.midi, confidence: pitch?.confidence ?? 0))
        }
        // Reject isolated semitone/octave spikes without smoothing away real sustained changes.
        let original = frames
        if frames.count > 2 {
            for i in 1..<(frames.count - 1) {
                if let a = original[i - 1].midi, let b = original[i + 1].midi, abs(a - b) < 0.45,
                   let current = original[i].midi, abs(current - (a + b) / 2) > 0.65 {
                    frames[i].midi = (a + b) / 2; frames[i].confidence = min(min(original[i - 1].confidence, original[i + 1].confidence), 0.79)
                }
            }
        }
        var result: [MusicNote] = []
        var active: (midi: Int, start: Double, end: Double, confidence: Double)?
        var pending: (midi: Int, start: Double, confidence: Double, count: Int)?
        func flush() {
            guard let note = active, note.end - note.start >= 0.06 else { return }
            let start = note.start * bpm / 60, duration = (note.end - note.start) * bpm / 60
            result.append(MusicNote(midi: note.midi, start: free ? start : (start * 4).rounded() / 4, duration: free ? duration : max(0.25, (duration * 4).rounded() / 4), confidence: note.confidence, rawStart: note.start, rawDuration: note.end - note.start))
        }
        for frame in frames {
            let end = min(total, frame.time + Double(hop) / sampleRate)
            guard let pitch = frame.midi else { flush(); active = nil; pending = nil; continue }
            let midi = Int(pitch.rounded())
            if let note = active, abs(pitch - Double(note.midi)) <= 0.65 {
                active?.end = end; active?.confidence = min(note.confidence, frame.confidence); pending = nil
            } else if active == nil {
                active = (midi, frame.time, end, frame.confidence); pending = nil
            } else {
                if var candidate = pending, candidate.midi == midi { candidate.count += 1; candidate.confidence = min(candidate.confidence, frame.confidence); pending = candidate }
                else { pending = (midi, frame.time, frame.confidence, 1) }
                if let candidate = pending, candidate.count >= 2 {
                    active?.end = candidate.start; flush(); active = (candidate.midi, candidate.start, end, candidate.confidence); pending = nil
                }
            }
        }
        flush(); guard !result.isEmpty else { throw MusicError.noNotes }
        // Preserve meaningful silence as actual rests, leaving free timing unquantized.
        var withRests: [MusicNote] = []
        for note in result {
            if let previous = withRests.last {
                let gapStart = previous.start + previous.duration, gap = note.start - gapStart
                if gap * 60 / bpm >= 0.09 { withRests.append(MusicNote(midi: nil, start: gapStart, duration: gap, rawStart: gapStart * 60 / bpm, rawDuration: gap * 60 / bpm)) }
            }
            withRests.append(note)
        }
        return withRests
    }
}
