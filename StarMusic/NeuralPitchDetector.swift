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
        guard samples.count == 1024 else { return nil }
        let data = Array(samples), mean = data.reduce(0.0) { $0 + Double($1) } / 1024
        let variance = data.reduce(0.0) { $0 + pow(Double($1) - mean, 2) } / 1024
        let deviation = sqrt(variance)
        guard deviation > 0.0025 else { return nil }
        let input = try MLMultiArray(shape: [1, 1024], dataType: .float32)
        for index in data.indices { input[index] = NSNumber(value: (Double(data[index]) - mean) / deviation) }
        let provider = try MLDictionaryFeatureProvider(dictionary: [inputName: input])
        let prediction = try model.prediction(from: provider)
        guard let salience = prediction.featureValue(for: outputName)?.multiArrayValue, salience.count == 360 else { throw RecognitionError.modelMissing }
        var center = 0, confidence = 0.0
        for bin in 0..<360 { let value = salience[bin].doubleValue; if value > confidence { confidence = value; center = bin } }
        guard confidence >= 0.45 else { return nil }
        var sum = 0.0, weight = 0.0
        for bin in max(0, center - 4)...min(359, center + 4) {
            let value = salience[bin].doubleValue
            sum += value * (1997.3794084376191 + Double(bin) * 20); weight += value
        }
        guard weight > 0 else { return nil }
        let hz = 10 * pow(2, sum / weight / 1200)
        return (69 + 12 * log2(hz / 440), confidence)
    }
}
