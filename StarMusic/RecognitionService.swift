import Foundation

/// One pipeline for recording, import and re-analysis. Originals are never modified here.
enum RecognitionService {
    static func analyze(url: URL, bpm: Double, free: Bool, start: Double = 0, end: Double = .infinity, settings: RecognitionSettings = .load(), speechOnly: Bool = false) async throws -> RecognitionResult {
        guard start.isFinite, start >= 0, !end.isNaN, end >= start else { throw MusicError.noNotes }
        let reading = Task.detached(priority: .userInitiated) { try AudioController.samples(from: url) }
        let data = try await withTaskCancellationHandler(operation: { try await reading.value }, onCancel: { reading.cancel() })
        try Task.checkCancellation()
        let duration = Double(data.samples.count) / data.sampleRate
        let low = min(data.samples.count, Int(min(start, duration) * data.sampleRate))
        let high = end.isFinite ? min(data.samples.count, max(low, Int(min(end, duration) * data.sampleRate))) : data.samples.count
        let source = Array(data.samples[low..<high])
        guard !source.isEmpty else { throw MusicError.noNotes }
        let converting = Task.detached(priority: .userInitiated) { try AudioController.resample(source, from: data.sampleRate, to: 16000) }
        let samples = try await withTaskCancellationHandler(operation: { try await converting.value }, onCancel: { converting.cancel() })
        try Task.checkCancellation()
        var result: RecognitionResult
        if settings.engine == .cloud || speechOnly {
            let wav = AudioRenderer.pcmWAV(samples, rate: 16000)
            result = try await CloudRecognitionClient.analyze(wav: wav, duration: Double(samples.count) / 16000, bpm: bpm, free: free, settings: settings, key: try ModelKeychain.read(), speechOnly: speechOnly)
        } else {
            let worker = Task.detached(priority: .userInitiated) { try PitchAnalyzer.analyze(samples, sampleRate: 16000, bpm: bpm, free: free, engine: settings.engine) }
            let notes = try await withTaskCancellationHandler(operation: { try await worker.value }, onCancel: { worker.cancel() })
            result = RecognitionResult(notes: notes)
        }
        try Task.checkCancellation()
        for i in result.notes.indices { result.notes[i].rawStart = (result.notes[i].rawStart ?? 0) + Double(low) / data.sampleRate }
        return result
    }
}
