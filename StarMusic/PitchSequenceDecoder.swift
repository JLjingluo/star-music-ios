import Foundation

struct PitchCandidate {
    var midi: Double
    var confidence: Double
}
struct PitchFrame {
    var time: Double
    var candidates: [PitchCandidate]
    var energy: Double
}

/// Original sequence decoder: silence separates phrases; sustained real leaps remain possible.
enum PitchSequenceDecoder {
    static func decode(_ frames: [PitchFrame]) throws -> [PitchCandidate?] {
        var output = [PitchCandidate?](repeating: nil, count: frames.count)
        var start = 0
        while start < frames.count {
            try Task.checkCancellation()
            if frames[start].candidates.isEmpty { start += 1; continue }
            var end = start + 1
            while end < frames.count && !frames[end].candidates.isEmpty { end += 1 }
            var costs = frames[start].candidates.map { -log(max(0.001, $0.confidence)) }
            var back: [[Int]] = [Array(repeating: 0, count: costs.count)]
            if end > start + 1 {
                for index in (start + 1)..<end {
                    try Task.checkCancellation()
                    let previous = frames[index - 1].candidates, current = frames[index].candidates
                    var next = [Double](repeating: .infinity, count: current.count), links = [Int](repeating: 0, count: current.count)
                    for j in current.indices {
                        for k in previous.indices {
                            let distance = abs(current[j].midi - previous[k].midi)
                            let transition = 0.10 * min(distance, 12) + (distance > 7 ? 0.65 : 0) + (distance > 0.7 ? 0.12 : 0)
                            let value = costs[k] + transition - log(max(0.001, current[j].confidence))
                            if value < next[j] { next[j] = value; links[j] = k }
                        }
                    }
                    let minimum = next.min() ?? 0
                    costs = next.map { $0 - minimum }; back.append(links)
                }
            }
            var chosen = costs.indices.min(by: { costs[$0] < costs[$1] }) ?? 0
            for index in stride(from: end - 1, through: start, by: -1) {
                output[index] = frames[index].candidates[chosen]
                if index > start { chosen = back[index - start][chosen] }
            }
            start = end
        }
        return output
    }
    static func tuningOffset(_ pitches: [PitchCandidate?]) -> Double {
        var sine = 0.0, cosine = 0.0, weight = 0.0
        for pitch in pitches.compactMap({ $0 }) where pitch.confidence >= 0.6 {
            sine += sin(pitch.midi * 2 * .pi) * pitch.confidence
            cosine += cos(pitch.midi * 2 * .pi) * pitch.confidence; weight += pitch.confidence
        }
        guard weight > 4, hypot(sine, cosine) / weight > 0.75 else { return 0 }
        let offset = atan2(sine, cosine) / (2 * .pi)
        return abs(offset) <= 0.35 ? offset : 0
    }
}
