import Foundation
import Accelerate

enum PitchAnalyzer {
    /// YIN difference function, cumulative normalization and sub-sample interpolation.
    static func estimate(_ samples: ArraySlice<Float>, rate: Double) -> (midi: Double, confidence: Double)? {
        guard samples.count >= 512, rate.isFinite, rate > 0 else { return nil }
        let data = Array(samples)
        let mean = data.reduce(0.0) { $0 + Double($1) } / Double(data.count)
        let variance = data.reduce(0.0) { $0 + pow(Double($1) - mean, 2) } / Double(data.count)
        guard sqrt(variance) > 0.0025 else { return nil }
        let minimum = max(2, Int(rate / 1100)), maximum = min(Int(rate / 55), data.count / 2 - 1)
        guard maximum > minimum else { return nil }
        var difference = [Double](repeating: 0, count: maximum + 1)
        let length = data.count - maximum
        data.withUnsafeBufferPointer { buffer in
            guard let base = buffer.baseAddress else { return }
            for lag in 1...maximum {
                var distance: Float = 0
                vDSP_distancesq(base, 1, base.advanced(by: lag), 1, &distance, vDSP_Length(length))
                difference[lag] = Double(distance)
            }
        }
        var normalized = [Double](repeating: 1, count: maximum + 1), running = 0.0
        for lag in 1...maximum { running += difference[lag]; normalized[lag] = running > 0 ? difference[lag] * Double(lag) / running : 1 }
        var selected = 0
        for lag in minimum..<maximum where normalized[lag] < 0.14 && normalized[lag] <= normalized[lag - 1] && normalized[lag] < normalized[lag + 1] { selected = lag; break }
        if selected == 0 { selected = (minimum...maximum).min(by: { normalized[$0] < normalized[$1] }) ?? 0 }
        guard selected > 0, normalized[selected] < 0.3 else { return nil }
        // A substantially better whole-period minimum resolves a weak fundamental / strong second harmonic.
        let initial = selected
        for multiple in 2...3 {
            let target = initial * multiple
            guard target < maximum - 2 else { continue }
            let candidate = (max(minimum, target - 3)...min(maximum, target + 3)).min(by: { normalized[$0] < normalized[$1] }) ?? selected
            if normalized[candidate] < normalized[selected] * 0.35 && normalized[selected] - normalized[candidate] > 0.01 { selected = candidate }
        }
        let left = normalized[max(0, selected - 1)], middle = normalized[selected], right = normalized[min(maximum, selected + 1)]
        let denominator = 2 * (left + right - 2 * middle)
        let correction = abs(denominator) > 0.000001 ? max(-1, min(1, (left - right) / denominator)) : 0
        let frequency = rate / (Double(selected) + correction), midi = 69 + 12 * log2(frequency / 440)
        guard midi.isFinite, (0...127).contains(midi) else { return nil }
        return (midi, max(0, min(1, 1 - middle)))
    }
    static func detect(_ samples: ArraySlice<Float>, rate: Double) -> (midi: Int, confidence: Double)? {
        estimate(samples, rate: rate).map { (Int($0.midi.rounded()), $0.confidence) }
    }
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
            let pitch = try neural?.detect(window) ?? (neural == nil ? estimate(window, rate: sampleRate) : nil)
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
