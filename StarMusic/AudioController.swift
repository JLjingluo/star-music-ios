import Foundation
@preconcurrency import AVFoundation
import Combine
import UIKit

@MainActor final class AudioController: NSObject, ObservableObject, AVAudioPlayerDelegate {
    enum RecordingState: Equatable { case ready, recording, paused, finished }
    @Published var recordingState: RecordingState = .ready
    @Published var elapsed: Double = 0
    @Published var levels: [Float] = Array(repeating: 0, count: 64)
    @Published var playingID: UUID?
    @Published var playbackSeconds: Double = 0
    @Published var interruptionMessage: String?
    @Published private(set) var paused = false
    @Published private(set) var renderingID: UUID?
    private var rendering: Task<URL, Error>?
    private var playbackFile: URL?
    var metronomeBPM: Double?
    private var metronome: AVAudioPlayer?
    private var lastBeat = -1
    private var playbackGeneration = 0
    private var recorder: AVAudioRecorder?
    private var requestingRecording = false
    private var player: AVAudioPlayer?
    private var timer: Timer?
    private var observers: [NSObjectProtocol] = []
    override init() {
        super.init()
        observers.append(NotificationCenter.default.addObserver(forName: AVAudioSession.interruptionNotification, object: nil, queue: .main) { [weak self] note in
            let raw = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt
            if raw == AVAudioSession.InterruptionType.began.rawValue {
                Task { @MainActor [weak self] in self?.handleInterruption("音频被中断，录音已暂停，请主动继续。") }
            }
        })
        observers.append(NotificationCenter.default.addObserver(forName: AVAudioSession.routeChangeNotification, object: nil, queue: .main) { [weak self] note in
            let raw = note.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt
            if raw == AVAudioSession.RouteChangeReason.oldDeviceUnavailable.rawValue {
                Task { @MainActor [weak self] in self?.handleInterruption("耳机或麦克风连接已改变，录音已暂停。") }
            }
        })
        timer = Timer.scheduledTimer(withTimeInterval: 0.07, repeats: true) { [weak self] _ in Task { @MainActor [weak self] in self?.tick() } }
    }
    private func tick() {
        if let recorder, recordingState == .recording {
            if !recorder.isRecording { finishRecording(); return }
            recorder.updateMeters(); elapsed = recorder.currentTime
            let amplitude = pow(10, recorder.averagePower(forChannel: 0) / 20)
            if let bpm = metronomeBPM {
                let beat = Int(elapsed * bpm / 60)
                if beat != lastBeat { lastBeat = beat; metronome?.currentTime = 0; metronome?.play() }
            }
            levels.append(max(0.01, min(1, amplitude))); if levels.count > 64 { levels.removeFirst() }
        }
        if let player { playbackSeconds = player.currentTime;  }
    }
    func beginRecording(to url: URL) async throws {
        guard recorder == nil && !requestingRecording else { throw MusicError.operation("录音已经开始，请先完成当前录音") }
        requestingRecording = true; defer { requestingRecording = false }
        stopPlayback()
        let allowed = await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { continuation.resume(returning: $0) }
        }
        guard allowed else { throw MusicError.permission }
        try Task.checkCancellation()
        guard UIApplication.shared.applicationState == .active else { throw MusicError.operation("请回到应用前台后重新开始录音") }
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        try session.setActive(true)
        let settings: [String: Any] = [AVFormatIDKey: kAudioFormatLinearPCM, AVSampleRateKey: 44100.0, AVNumberOfChannelsKey: 1,
                                     AVLinearPCMBitDepthKey: 16, AVLinearPCMIsFloatKey: false, AVLinearPCMIsBigEndianKey: false]
        recorder = try AVAudioRecorder(url: url, settings: settings)
        recorder?.isMeteringEnabled = true
        guard recorder?.record(forDuration: 300) == true else { recorder = nil; throw MusicError.operation("无法启动录音") }
        if metronomeBPM != nil {
            var click = [Float]()
            for sample in 0..<2000 {
                let time = Double(sample) / 44100.0
                let phase = 2.0 * Double.pi * 1600.0 * time
                let envelope = exp(-Double(sample) / 300.0)
                click.append(Float(sin(phase) * envelope * 0.15))
            }
            metronome = try? AVAudioPlayer(data: AudioRenderer.pcmWAV(click, rate: 44100)); metronome?.prepareToPlay()
        }
        lastBeat = -1; elapsed = 0; levels = Array(repeating: 0, count: 64); recordingState = .recording
    }
    func pauseRecording() { guard recordingState == .recording else { return }; elapsed = max(elapsed, recorder?.currentTime ?? 0); recorder?.pause(); metronome?.stop(); recordingState = .paused }
    func resumeRecording() throws {
        try AVAudioSession.sharedInstance().setActive(true)
        guard recordingState == .paused, elapsed < 300, recorder?.record(forDuration: 300 - elapsed) == true else { throw MusicError.operation("无法继续录音，请完成并整理这段旋律") }; recordingState = .recording
    }
    func finishRecording() { elapsed = max(elapsed, recorder?.currentTime ?? 0); recorder?.stop(); recorder = nil; metronome?.stop(); metronome = nil; recordingState = .finished; try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation) }
    func resetRecording() { finishRecording(); elapsed = 0; recordingState = .ready }
    func handleInterruption(_ message: String) { pauseRecording(); stopPlayback(); interruptionMessage = message }
    func play(_ project: MusicProject, recordingDirectory: URL? = nil, loop: Bool = false) async throws {
        if playingID == project.id, let player {
            if paused { guard player.play() else { throw MusicError.operation("无法继续试听") }; paused = false }
            else { player.pause(); paused = true }
            return
        }
        if renderingID == project.id { stopPlayback(); return }
        stopPlayback()
        let generation = playbackGeneration
        guard project.seconds <= 600 else { throw MusicError.tooLarge }
        let worker = Task { try await AudioRenderer.renderFile(project, recordingDirectory: recordingDirectory) }
        rendering = worker; renderingID = project.id
        defer { if generation == playbackGeneration { rendering = nil; renderingID = nil } }
        let file: URL
        do { file = try await withTaskCancellationHandler(operation: { try await worker.value }, onCancel: { worker.cancel() }) }
        catch is CancellationError { return }
        guard generation == playbackGeneration else { try? FileManager.default.removeItem(at: file); return }
        try configurePlayback()
        playbackFile = file
        player = try AVAudioPlayer(contentsOf: file); player?.delegate = self; player?.numberOfLoops = loop ? -1 : 0
        guard player?.play() == true else { throw MusicError.operation("无法启动试听") }; playingID = project.id; playbackSeconds = 0; paused = false
    }
    nonisolated static func previewProject(_ instrument: Instrument, midi: Int? = nil) throws -> MusicProject {
        var p = MusicProject(); p.tracks[0].instrument = instrument; p.bpm = 120
        if let midi {
            guard (0...127).contains(midi) else { throw MusicError.invalidProject }
            p.tracks[0].notes = [MusicNote(midi: midi, start: 0, duration: 1)]
        } else { p.tracks[0].notes = [64, 68, 71].enumerated().map { MusicNote(midi: $0.element, start: Double($0.offset) * 0.5, duration: 1) } }
        return p
    }
    func preview(_ instrument: Instrument, midi: Int? = nil) async throws { try await play(Self.previewProject(instrument, midi: midi)) }
    var isLooping: Bool { player?.numberOfLoops == -1 }
    func playOriginal(_ url: URL, from start: Double = 0, length: Double? = nil) throws {
        guard start.isFinite, start >= 0, length.map({ $0.isFinite && $0 > 0 }) ?? true else { throw MusicError.invalidProject }
        stopPlayback(); try configurePlayback()
        let source = try AVAudioPlayer(contentsOf: url)
        guard start < source.duration else { throw MusicError.operation("这段音符对应的录音位置超出原声范围，请重新校正") }
        source.delegate = self; source.currentTime = start
        guard source.play() else { throw MusicError.operation("无法启动原声试听，请稍后重试") }
        player = source
        let generation = playbackGeneration
        if let length { Task { [weak self] in try? await Task.sleep(for: .seconds(length)); if self?.playbackGeneration == generation { self?.stopPlayback() } } }
    }
    func seek(to seconds: Double) { player?.currentTime = max(0, min(seconds, player?.duration ?? 0)); playbackSeconds = player?.currentTime ?? 0 }
    func stopPlayback() { playbackGeneration += 1; rendering?.cancel(); rendering = nil; renderingID = nil; player?.stop(); player = nil; if let playbackFile { try? FileManager.default.removeItem(at: playbackFile) }; playbackFile = nil; playingID = nil; playbackSeconds = 0; paused = false }
    func configurePlayback() throws { try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default); try AVAudioSession.sharedInstance().setActive(true) }
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) { Task { @MainActor [weak self] in self?.playingID = nil; self?.paused = false; self?.playbackSeconds = 0 } }
    /// Decode bounded chunks directly into mono at the requested analysis/mix rate.
    /// Never allocate a whole file at its native sample rate or channel count.
    nonisolated static func samples(from url: URL, start: Double = 0, end: Double = .infinity, outputRate: Double = 16000, maximumDuration: Double = 300) throws -> (samples: [Float], sampleRate: Double) {
        try Task.checkCancellation()
        guard start.isFinite, start >= 0, !end.isNaN, end > start, outputRate.isFinite, (8000...48000).contains(outputRate), maximumDuration.isFinite, maximumDuration > 0, maximumDuration <= 600 else { throw MusicError.invalidProject }
        let file = try AVAudioFile(forReading: url, commonFormat: .pcmFormatFloat32, interleaved: false)
        let format = file.processingFormat, rate = format.sampleRate, channels = Int(format.channelCount)
        guard rate.isFinite, (8000...384000).contains(rate), (1...32).contains(channels), file.length > 0 else { throw MusicError.invalidProject }
        let duration = Double(file.length) / rate
        // A selected excerpt of a long file is legal. A tiny timer overshoot is clipped.
        if !end.isFinite && duration - start > maximumDuration + 1 { throw MusicError.tooLarge }
        let stop = min(duration, end.isFinite ? end : start + maximumDuration)
        guard stop > start, stop - start <= maximumDuration + 0.001 else { throw MusicError.tooLarge }
        let maximumFrames = Int(ceil((stop - start) * outputRate))
        guard maximumFrames <= 28_800_000 else { throw MusicError.tooLarge }
        let chunk: AVAudioFrameCount = 4096
        guard let outputFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: outputRate, channels: 1, interleaved: false),
              let monoFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: rate, channels: 1, interleaved: false),
              let converter = AVAudioConverter(from: monoFormat, to: outputFormat),
              let reading = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: chunk),
              let input = AVAudioPCMBuffer(pcmFormat: monoFormat, frameCapacity: chunk),
              let output = AVAudioPCMBuffer(pcmFormat: outputFormat, frameCapacity: chunk) else { throw MusicError.invalidProject }
        converter.sampleRateConverterQuality = AVAudioQuality.max.rawValue
        file.framePosition = min(file.length, AVAudioFramePosition(start * rate))
        var remaining = min(file.length, AVAudioFramePosition(stop * rate)) - file.framePosition
        var result = [Float](); result.reserveCapacity(maximumFrames)
        var readError: Error?
        while true {
            try Task.checkCancellation()
            output.frameLength = 0
            var conversionError: NSError?
            let status = converter.convert(to: output, error: &conversionError) { requested, state in
                guard remaining > 0, readError == nil else { state.pointee = .endOfStream; return nil }
                do {
                    try Task.checkCancellation()
                    let count = min(chunk, requested, AVAudioFrameCount(min(remaining, AVAudioFramePosition(chunk))))
                    try file.read(into: reading, frameCount: count)
                    remaining -= AVAudioFramePosition(reading.frameLength)
                    guard reading.frameLength > 0, let data = reading.floatChannelData, let mono = input.floatChannelData else { remaining = 0; state.pointee = .endOfStream; return nil }
                    input.frameLength = reading.frameLength
                    for frame in 0..<Int(reading.frameLength) {
                        var sum: Float = 0
                        for channel in 0..<channels { sum += data[channel][frame] / Float(channels) }
                        mono[0][frame] = sum
                    }
                    state.pointee = .haveData; return input
                } catch { readError = error; state.pointee = .endOfStream; return nil }
            }
            if let readError { throw readError }
            if let conversionError { throw conversionError }
            guard status != .error, let data = output.floatChannelData else { throw MusicError.invalidProject }
            let count = min(Int(output.frameLength), maximumFrames - result.count)
            if count > 0 { result.append(contentsOf: UnsafeBufferPointer(start: data[0], count: count)) }
            if status == .endOfStream || result.count >= maximumFrames { break }
        }
        return (result, outputRate)
    }
    nonisolated static func resample(_ source: [Float], from inputRate: Double, to outputRate: Double) throws -> [Float] {
        guard inputRate.isFinite, outputRate.isFinite, inputRate > 0, outputRate > 0 else { throw MusicError.invalidProject }
        if abs(inputRate - outputRate) < 1 { return source }
        guard !source.isEmpty else { return [] }
        guard let inputFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: inputRate, channels: 1, interleaved: false),
              let outputFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: outputRate, channels: 1, interleaved: false),
              let input = AVAudioPCMBuffer(pcmFormat: inputFormat, frameCapacity: AVAudioFrameCount(source.count)),
              let output = AVAudioPCMBuffer(pcmFormat: outputFormat, frameCapacity: AVAudioFrameCount(ceil(Double(source.count) * outputRate / inputRate)) + 64),
              let converter = AVAudioConverter(from: inputFormat, to: outputFormat), let channels = input.floatChannelData else { throw MusicError.invalidProject }
        input.frameLength = AVAudioFrameCount(source.count)
        source.withUnsafeBufferPointer { buffer in if let base = buffer.baseAddress { channels[0].update(from: base, count: source.count) } }
        converter.sampleRateConverterQuality = AVAudioQuality.max.rawValue
        var supplied = false, error: NSError?
        let status = converter.convert(to: output, error: &error) { _, state in
            if supplied { state.pointee = .endOfStream; return nil }
            supplied = true; state.pointee = .haveData; return input
        }
        if let error { throw error }
        guard status != .error, let result = output.floatChannelData else { throw MusicError.invalidProject }
        return Array(UnsafeBufferPointer(start: result[0], count: Int(output.frameLength)))
    }
}

private actor AudioRenderQueue {
    static let shared = AudioRenderQueue()
    func render(_ project: MusicProject, recordingDirectory: URL?) throws -> Data {
        try Task.checkCancellation()
        return try AudioRenderer.wav(project, recordingDirectory: recordingDirectory)
    }
    func renderFile(_ project: MusicProject, recordingDirectory: URL?) throws -> URL {
        try AudioRenderer.file(project, recordingDirectory: recordingDirectory)
    }
}

enum AudioRenderer {
    static func renderFile(_ project: MusicProject, recordingDirectory: URL? = nil) async throws -> URL {
        try await AudioRenderQueue.shared.renderFile(project, recordingDirectory: recordingDirectory)
    }
    static func render(_ project: MusicProject, recordingDirectory: URL? = nil) async throws -> Data {
        try await AudioRenderQueue.shared.render(project, recordingDirectory: recordingDirectory)
    }
    static func wav(_ project: MusicProject, recordingDirectory: URL? = nil) throws -> Data {
        let url = try file(project, recordingDirectory: recordingDirectory)
        defer { try? FileManager.default.removeItem(at: url) }
        return try Data(contentsOf: url)
    }
    static func file(_ project: MusicProject, recordingDirectory: URL? = nil) throws -> URL {
        try Task.checkCancellation(); try project.validate()
        guard project.seconds <= 600 else { throw MusicError.tooLarge }
        let rate = 44100.0, count = Int((project.seconds + 0.4) * rate)
        let solo = project.tracks.contains { $0.solo }
        let tracks = project.tracks.filter { !$0.muted && (!solo || $0.solo) }
        let root = recordingDirectory ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("StarMusic/Recordings", isDirectory: true)
        for track in tracks where track.useOriginalAudio == true {
            guard let name = track.recordingFile, FileManager.default.fileExists(atPath: root.appendingPathComponent(name).path) else { throw MusicError.missingAudio(track.recordingFile ?? track.name) }
            let asset = try AVAudioFile(forReading: root.appendingPathComponent(name))
            guard asset.length > 0, track.sourceDuration > 0 else { throw MusicError.operation("原声为空或未能完整结束，请保留文件并重新录制或恢复备份") }
        }
        let output = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".wav")
        FileManager.default.createFile(atPath: output.path, contents: nil)
        var complete = false; defer { if !complete { try? FileManager.default.removeItem(at: output) } }
        let handle = try FileHandle(forWritingTo: output); defer { try? handle.close() }
        var header = pcmWAV([], rate: 44100)
        func set32(_ value: UInt32, _ at: Int) { var little = value.littleEndian; withUnsafeBytes(of: &little) { header.replaceSubrange(at..<(at + 4), with: $0) } }
        set32(UInt32(36 + count * 2), 4); set32(UInt32(count * 2), 40); try handle.write(contentsOf: header)
        // One second of mono Float32 plus its PCM output, independent of song length.
        for first in stride(from: 0, to: count, by: 44100) {
            try Task.checkCancellation()
            let end = min(count, first + 44100)
            var mix = [Float](repeating: 0, count: end - first)
            for track in tracks {
                if track.useOriginalAudio == true, let file = track.recordingFile {
                    let offset = Int((track.sourceStartBeat ?? 0) * 60 / project.bpm * rate)
                    let sourceLength = Int(track.sourceDuration * rate)
                    let start = max(first, offset), stop = min(end, offset + sourceLength)
                    guard stop > start else { continue }
                    let from = (track.trimStart ?? 0) + Double(start - offset) / rate
                    let to = min(track.trimEnd ?? track.recordingSeconds ?? .infinity, from + Double(stop - start) / rate)
                    let source = try AudioController.samples(from: root.appendingPathComponent(file), start: from, end: to, outputRate: rate, maximumDuration: 600).samples
                    for i in 0..<min(source.count, stop - start) { mix[start - first + i] += source[i] * Float(track.volume) }
                    continue
                }
                for note in track.notes {
                    guard let midi = note.midi else { continue }
                    let start = Int(note.start * 60 / project.bpm * rate), length = Int(note.duration * 60 / project.bpm * rate)
                    let low = max(first, start), high = min(end, start + length + 6000)
                    guard low < high else { continue }
                    let frequency = 440 * pow(2, Double(midi - 69) / 12)
                    for frame in low..<high {
                        if frame % 16384 == 0 { try Task.checkCancellation() }
                        let t = Double(frame - start) / rate, phase = 2 * Double.pi * frequency * t
                        let attack = min(1, t / 0.012), tail = frame - start > length ? exp(-Double(frame - start - length) / 1000) : 1
                        let sound: Double
                        switch track.instrument {
                        case .piano: sound = (sin(phase) + 0.25 * sin(phase * 2) + 0.08 * sin(phase * 3)) * exp(-t * 2.3)
                        case .guitar: sound = (sin(phase) + 0.32 * sin(phase * 2) + 0.17 * sin(phase * 3) + 0.1 * sin(phase * 4)) * exp(-t * 5)
                        case .synth: sound = (sin(phase) + 0.45 * sin(phase * 1.004) + 0.1 * sin(phase * 2)) * 0.55
                        }
                        mix[frame - first] += Float(sound * attack * tail * track.volume * 0.28)
                    }
                }
            }
            let pcm = try encodePCM(mix, rate: 44100, cancellable: true)
            try handle.write(contentsOf: pcm.dropFirst(44))
        }
        try handle.synchronize(); try handle.close(); try Task.checkCancellation(); complete = true; return output
    }
    static func pcmWAV(_ samples: [Float], rate: UInt32) -> Data {
        // Encoding small analysis/metronome buffers has no asynchronous job to cancel.
        (try? encodePCM(samples, rate: rate, cancellable: false)) ?? Data()
    }
    private static func encodePCM(_ samples: [Float], rate: UInt32, cancellable: Bool) throws -> Data {
        var data = Data(); data.reserveCapacity(44 + samples.count * 2)
        func text(_ value: String) { data.append(contentsOf: value.utf8) }
        func u16(_ n: UInt16) { var x = n.littleEndian; withUnsafeBytes(of: &x) { data.append(contentsOf: $0) } }
        func u32(_ n: UInt32) { var x = n.littleEndian; withUnsafeBytes(of: &x) { data.append(contentsOf: $0) } }
        text("RIFF"); u32(UInt32(36 + samples.count * 2)); text("WAVEfmt "); u32(16); u16(1); u16(1); u32(rate); u32(rate * 2); u16(2); u16(16); text("data"); u32(UInt32(samples.count * 2))
        for (index, sample) in samples.enumerated() { if cancellable && index % 16384 == 0 { try Task.checkCancellation() }; let clamped = sample.isFinite ? max(-1, min(1, sample)) : 0; u16(UInt16(bitPattern: Int16(clamped * 32767))) }
        return data
    }
}
