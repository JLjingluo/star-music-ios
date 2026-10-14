import CoreML
import Foundation

/// Complete pretrained CREPE model; no network requests, demo predictions or fabricated model outputs.
final class NeuralPitchDetector {
    private let model: MLModel
    private let inputName: String
    private let outputName: String
    init() throws {
        guard let url = Bundle.main.url(forResource: "PitchCREPE", withExtension: "mlmodelc") else { throw RecognitionError.modelMissing }
        let configuration = MLModelConfiguration(); configuration.computeUnits = .all
        model = try MLModel(contentsOf: url, configuration: configuration)
        guard let input = model.modelDescription.inputDescriptionsByName.first(where: { $0.value.type == .multiArray })?.key,
              let output = model.modelDescription.outputDescriptionsByName.first(where: { $0.value.type == .multiArray })?.key else { throw RecognitionError.modelMissing }
        inputName = input; outputName = output
    }
    func detect(_ samples: ArraySlice<Float>) throws -> (midi: Double, confidence: Double)? {
        guard let first = try candidates(samples).first, first.confidence >= 0.45 else { return nil }
        return (first.midi, first.confidence)
    }
    func candidates(_ samples: ArraySlice<Float>) throws -> [PitchCandidate] {
        try autoreleasepool { try infer(samples) }
    }
    private func infer(_ samples: ArraySlice<Float>) throws -> [PitchCandidate] {
        guard samples.count == 1024 else { return [] }
        let data = Array(samples), mean = data.reduce(0.0) { $0 + Double($1) } / 1024
        let variance = data.reduce(0.0) { $0 + pow(Double($1) - mean, 2) } / 1024
        let deviation = sqrt(variance)
        guard deviation > 0.0025 else { return [] }
        let input = try MLMultiArray(shape: [1, 1024], dataType: .float32)
        for index in data.indices { input[index] = NSNumber(value: (Double(data[index]) - mean) / deviation) }
        let provider = try MLDictionaryFeatureProvider(dictionary: [inputName: input])
        let prediction = try model.prediction(from: provider)
        guard let salience = prediction.featureValue(for: outputName)?.multiArrayValue, salience.count == 360 else { throw RecognitionError.modelMissing }
        let values = (0..<360).map { salience[$0].doubleValue }
        let peaks = (0..<360).filter { bin in values[bin] >= 0.08 && (bin == 0 || values[bin] >= values[bin - 1]) && (bin == 359 || values[bin] > values[bin + 1]) }.sorted { values[$0] > values[$1] }
        guard let first = peaks.first, values[first] >= 0.35 else { return [] }
        var result: [PitchCandidate] = []
        for center in peaks {
            var sum = 0.0, weight = 0.0
            for bin in max(0, center - 4)...min(359, center + 4) { sum += values[bin] * (1997.3794084376191 + Double(bin) * 20); weight += values[bin] }
            guard weight > 0 else { continue }
            let midi = 69 + 12 * log2(10 * pow(2, sum / weight / 1200) / 440)
            if !result.contains(where: { abs($0.midi - midi) < 0.65 }) { result.append(PitchCandidate(midi: midi, confidence: values[center])) }
            if result.count == 6 { break }
        }
        return result
    }
}
