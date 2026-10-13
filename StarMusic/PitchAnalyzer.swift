import Foundation

enum PitchAnalyzer {
    static func detect(_ samples: ArraySlice<Float>, rate: Double) -> (midi: Int, confidence: Double)? {
        guard samples.count >= 2048 else { return nil }
        let data = Array(samples), rms = sqrt(data.reduce(0) { $0 + Double($1 * $1) } / Double(data.count))
        guard rms > 0.015 else { return nil }
        let minimum = max(1, Int(rate / 1000)), maximum = min(Int(rate / 75), data.count / 2)
        guard minimum < maximum else { return nil }
        var best = 0.0, bestLag = 0
        for lag in minimum...maximum {
            var sum = 0.0, left = 0.0, right = 0.0
            for i in stride(from: 0, to: data.count - maximum, by: 2) {
                let a = Double(data[i]), b = Double(data[i + lag]); sum += a * b; left += a * a; right += b * b
            }
            let correlation = sum / sqrt(max(0.000001, left * right))
            if correlation > best { best = correlation; bestLag = lag }
            if best > 0.88 && correlation < best - 0.025 && lag > bestLag + 3 { break }
        }
        guard best > 0.65, bestLag > 0 else { return nil }
        let midi = Int((69 + 12 * log2(rate / Double(bestLag) / 440)).rounded())
        guard (0...127).contains(midi) else { return nil }
        return (midi, best)
    }
    static func analyze(_ data: [Float], sampleRate: Double, bpm: Double, free: Bool) throws -> [MusicNote] {
        guard data.count >= 2048 else { throw MusicError.noNotes }
        let hop = max(1, Int((sampleRate * 0.035).rounded())); var result: [MusicNote] = []
        var active: (midi: Int, start: Double, end: Double, confidence: Double)?
        func appendActive() {
            guard let active, active.end - active.start > 0.085 else { return }
            let start = active.start * bpm / 60, duration = (active.end - active.start) * bpm / 60
            result.append(MusicNote(midi: active.midi, start: free ? start : (start * 4).rounded() / 4,
                                    duration: free ? duration : max(0.25, (duration * 4).rounded() / 4), confidence: active.confidence,
                                    rawStart: active.start, rawDuration: active.end - active.start))
        }
        for i in stride(from: 0, through: data.count - 2048, by: hop) {
            try Task.checkCancellation()
            let pitch = detect(data[i..<(i + 2048)], rate: sampleRate)
            // A pitch belongs to the center of its analysis window, not to the
            // leading edge, which can still contain silence before an onset.
            let time = (Double(i) + 1024.0) / sampleRate
            let frameEnd = min(Double(data.count) / sampleRate, time + Double(hop) / sampleRate)
            if let pitch, pitch.midi == active?.midi { let confidence = min(active?.confidence ?? 1, pitch.confidence); active?.end = frameEnd; active?.confidence = confidence }
            else { appendActive(); active = pitch.map { ($0.midi, time, frameEnd, $0.confidence) } }
        }
        appendActive(); guard !result.isEmpty else { throw MusicError.noNotes }; return result
    }
}
