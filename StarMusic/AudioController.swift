import Foundation
import AVFoundation
import Combine

@MainActor final class AudioController: NSObject, ObservableObject, AVAudioPlayerDelegate {
    enum RecordingState: Equatable { case ready, recording, paused, finished }
    @Published var recordingState: RecordingState = .ready
    @Published var elapsed: Double = 0
    @Published var levels: [Float] = Array(repeating: 0, count: 64)
    @Published var playingID: UUID?
    @Published var playbackSeconds: Double = 0
    @Published var interruptionMessage: String?
    var loop = false
    var metronomeBPM: Double?
    private var metronome: AVAudioPlayer?
    private var lastBeat = -1
    private var playbackGeneration = 0
    private var recorder: AVAudioRecorder?
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
            recorder.updateMeters(); elapsed = recorder.currentTime
            let amplitude = pow(10, recorder.averagePower(forChannel: 0) / 20)
            if let bpm = metronomeBPM {
                let beat = Int(elapsed * bpm / 60)
                if beat != lastBeat { lastBeat = beat; metronome?.currentTime = 0; metronome?.play() }
            }
            levels.append(max(0.01, min(1, amplitude))); if levels.count > 64 { levels.removeFirst() }
        }
        if let player { playbackSeconds = player.currentTime; if !player.isPlaying { playingID = nil } }
    }
    func beginRecording(to url: URL) async throws {
        stopPlayback()
        let allowed = await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { continuation.resume(returning: $0) }
        }
        guard allowed else { throw MusicError.permission }
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        try session.setActive(true)
        let settings: [String: Any] = [AVFormatIDKey: kAudioFormatLinearPCM, AVSampleRateKey: 44100.0, AVNumberOfChannelsKey: 1,
                                     AVLinearPCMBitDepthKey: 16, AVLinearPCMIsFloatKey: false, AVLinearPCMIsBigEndianKey: false]
        recorder = try AVAudioRecorder(url: url, settings: settings)
        recorder?.isMeteringEnabled = true
        guard recorder?.record() == true else { throw MusicError.save("无法启动录音") }
        if metronomeBPM != nil {
            let click = (0..<2000).map { Float(sin(2 * Double.pi * 1600 * Double($0) / 44100) * exp(-Double($0) / 300) * 0.15) }
            metronome = try? AVAudioPlayer(data: AudioRenderer.pcmWAV(click, rate: 44100)); metronome?.prepareToPlay()
        }
        lastBeat = -1; elapsed = 0; levels = Array(repeating: 0, count: 64); recordingState = .recording
    }
    func pauseRecording() { guard recordingState == .recording else { return }; recorder?.pause(); metronome?.stop(); recordingState = .paused }
    func resumeRecording() throws {
        try AVAudioSession.sharedInstance().setActive(true)
        guard recorder?.record() == true else { throw MusicError.save("无法继续录音") }; recordingState = .recording
    }
    func finishRecording() { elapsed = max(elapsed, recorder?.currentTime ?? 0); recorder?.stop(); recorder = nil; metronome?.stop(); metronome = nil; recordingState = .finished; try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation) }
    func resetRecording() { finishRecording(); elapsed = 0; recordingState = .ready }
    func handleInterruption(_ message: String) { pauseRecording(); stopPlayback(); interruptionMessage = message }
    func play(_ project: MusicProject) async throws {
        if playingID == project.id { stopPlayback(); return }
        stopPlayback()
        let generation = playbackGeneration
        guard project.seconds <= 600 else { throw MusicError.tooLarge }
        let data = try await Task.detached(priority: .userInitiated) { try AudioRenderer.wav(project) }.value
        guard generation == playbackGeneration else { return }
        try configurePlayback()
        player = try AVAudioPlayer(data: data); player?.delegate = self; player?.numberOfLoops = loop ? -1 : 0
        guard player?.play() == true else { throw MusicError.save("无法启动试听") }; playingID = project.id; playbackSeconds = 0
    }
    func preview(_ instrument: Instrument, midi: Int = 64) async throws {
        var p = MusicProject(); p.tracks[0].instrument = instrument; p.bpm = 120
        p.tracks[0].notes = [0, 4, 7].enumerated().map { MusicNote(midi: midi + $0.element, start: Double($0.offset) * 0.5, duration: 1) }
        try await play(p)
    }
    func playOriginal(_ url: URL, from start: Double = 0, length: Double? = nil) throws {
        stopPlayback(); try configurePlayback(); player = try AVAudioPlayer(contentsOf: url); player?.delegate = self; player?.currentTime = start; player?.play()
        let generation = playbackGeneration
        if let length { Task { [weak self] in try? await Task.sleep(for: .seconds(length)); if self?.playbackGeneration == generation { self?.stopPlayback() } } }
    }
    func seek(to seconds: Double) { player?.currentTime = max(0, min(seconds, player?.duration ?? 0)); playbackSeconds = player?.currentTime ?? 0 }
    func stopPlayback() { playbackGeneration += 1; player?.stop(); player = nil; playingID = nil; playbackSeconds = 0 }
    func configurePlayback() throws { try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default); try AVAudioSession.sharedInstance().setActive(true) }
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) { Task { @MainActor [weak self] in self?.playingID = nil } }
    nonisolated static func samples(from url: URL) throws -> (samples: [Float], sampleRate: Double) {
        let file = try AVAudioFile(forReading: url)
        guard file.length <= AVAudioFramePosition(file.processingFormat.sampleRate * 300),
              let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length)) else { throw MusicError.tooLarge }
        try file.read(into: buffer)
        guard let channels = buffer.floatChannelData else { throw MusicError.invalidProject }
        let frames = Int(buffer.frameLength), count = Int(buffer.format.channelCount)
        var data = [Float](repeating: 0, count: frames)
        for channel in 0..<count { for frame in 0..<frames { data[frame] += channels[channel][frame] / Float(count) } }
        return (data, buffer.format.sampleRate)
    }
}

enum AudioRenderer {
    static func wav(_ project: MusicProject) throws -> Data {
        try project.validate()
        guard project.seconds <= 600 else { throw MusicError.tooLarge }
        let sr = 44100.0, count = Int((project.seconds + 0.4) * sr)
        var samples = [Float](repeating: 0, count: count)
        let solo = project.tracks.contains { $0.solo }
        for track in project.tracks where !track.muted && (!solo || track.solo) {
            for note in track.notes {
                guard let midi = note.midi else { continue }
                let start = Int(note.start * 60 / project.bpm * sr), length = Int(note.duration * 60 / project.bpm * sr)
                let frequency = 440 * pow(2, Double(midi - 69) / 12)
                let end = min(count, start + length + 6000)
                guard start < end else { continue }
                for frame in start..<end {
                    let t = Double(frame - start) / sr, phase = 2 * Double.pi * frequency * t
                    let attack = min(1, t / 0.012), tail = frame - start > length ? exp(-Double(frame - start - length) / 1000) : 1
                    let sound: Double
                    switch track.instrument {
                    case .piano: sound = (sin(phase) + 0.25 * sin(phase * 2) + 0.08 * sin(phase * 3)) * exp(-t * 2.3)
                    case .guitar: sound = (sin(phase) + 0.32 * sin(phase * 2) + 0.17 * sin(phase * 3) + 0.1 * sin(phase * 4)) * exp(-t * 5)
                    case .synth: sound = (sin(phase) + 0.45 * sin(phase * 1.004) + 0.1 * sin(phase * 2)) * 0.55
                    }
                    samples[frame] += Float(sound * attack * tail * track.volume * 0.28)
                }
            }
        }
        return pcmWAV(samples, rate: 44100)
    }
    static func pcmWAV(_ samples: [Float], rate: UInt32) -> Data {
        var data = Data()
        func text(_ value: String) { data.append(contentsOf: value.utf8) }
        func u16(_ n: UInt16) { var x = n.littleEndian; withUnsafeBytes(of: &x) { data.append(contentsOf: $0) } }
        func u32(_ n: UInt32) { var x = n.littleEndian; withUnsafeBytes(of: &x) { data.append(contentsOf: $0) } }
        text("RIFF"); u32(UInt32(36 + samples.count * 2)); text("WAVEfmt "); u32(16); u16(1); u16(1); u32(rate); u32(rate * 2); u16(2); u16(16); text("data"); u32(UInt32(samples.count * 2))
        for sample in samples { let clamped = sample.isFinite ? max(-1, min(1, sample)) : 0; u16(UInt16(bitPattern: Int16(clamped * 32767))) }
        return data
    }
}
