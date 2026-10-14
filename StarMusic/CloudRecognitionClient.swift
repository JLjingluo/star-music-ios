import Foundation

struct RecognitionResult {
    var notes: [MusicNote]
    var transcript: String?
}
enum CloudRecognitionClient {
    static func request(settings: RecognitionSettings, key: String, messages: [[String: Any]]) throws -> URLRequest {
        guard !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, !settings.model.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw RecognitionError.configuration("请先配置模型 ID 和设备密钥。") }
        var request = URLRequest(url: try settings.endpoint()); request.httpMethod = "POST"; request.timeoutInterval = 180
        request.setValue("Bearer " + key, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: ["model": settings.model, "messages": messages, "stream": false, "max_tokens": 8192])
        return request
    }
    private static func response(_ request: URLRequest, session: URLSession) async throws -> String {
        let (data, response) = try await session.data(for: request)
        try Task.checkCancellation()
        guard let http = response as? HTTPURLResponse else { throw RecognitionError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else { throw RecognitionError.service(http.statusCode) }
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]], let message = choices.first?["message"] as? [String: Any],
              let text = message["content"] as? String, !text.isEmpty else { throw RecognitionError.invalidResponse }
        return text
    }
    static func check(settings: RecognitionSettings, key: String, session: URLSession = .shared) async throws {
        let req = try request(settings: settings, key: key, messages: [["role": "user", "content": "请只回复 OK，用于检查 API 连接。"]])
        _ = try await response(req, session: session)
    }
    static func analyze(wav: Data, duration: Double, bpm: Double, free: Bool, settings: RecognitionSettings, key: String, speechOnly: Bool = false, session: URLSession = .shared) async throws -> RecognitionResult {
        guard wav.count <= 25 * 1024 * 1024 else { throw RecognitionError.audioTooLarge }
        let instruction = speechOnly
            ? "识别音频中的歌词或口述文字，不要编造没有听清的内容。只输出 JSON：{\"transcript\":\"文字\",\"notes\":[]}。纯哼唱没有歌词时返回空 transcript。"
            : "分析上传的单声部哼唱旋律，输出用于人工校正的候选音符。不要把普通语音转文字当成旋律，不要根据描述编造音符。只输出 JSON：{\"notes\":[{\"midi\":60,\"startSeconds\":0.2,\"durationSeconds\":0.5,\"confidence\":0.6}],\"transcript\":\"若有清晰歌词可填写，否则空字符串\"}。音符时间从本音频开头计时，单位是秒，不是拍。midi 是 0 到 127 的整数；休止符可用 null。不确定的音必须低置信度；无法分析旋律时返回 notes 空数组。音频长度 \(duration) 秒。"
        let content: [[String: Any]] = [["type": "text", "text": instruction], ["type": "input_audio", "input_audio": ["data": wav.base64EncodedString(), "format": "wav"]]]
        let req = try request(settings: settings, key: key, messages: [["role": "user", "content": content]])
        let text = try await response(req, session: session)
        return try decode(text, duration: duration, bpm: bpm, free: free, speechOnly: speechOnly)
    }
    private struct Payload: Decodable {
        struct Note: Decodable { var midi: Int?; var startSeconds: Double; var durationSeconds: Double; var confidence: Double? }
        var notes: [Note]?
        var transcript: String?
    }
    static func decode(_ text: String, duration: Double, bpm: Double, free: Bool, speechOnly: Bool = false) throws -> RecognitionResult {
        guard duration.isFinite, duration > 0, bpm.isFinite, (30...300).contains(bpm), let first = text.firstIndex(of: "{"), let last = text.lastIndex(of: "}") else { throw RecognitionError.invalidResponse }
        guard let payload = try? JSONDecoder().decode(Payload.self, from: Data(text[first...last].utf8)), (payload.notes?.count ?? 0) <= 20000 else { throw RecognitionError.invalidResponse }
        var notes: [MusicNote] = []
        for note in payload.notes ?? [] {
            guard note.startSeconds.isFinite, note.durationSeconds.isFinite, note.startSeconds >= 0, note.durationSeconds > 0,
                  note.startSeconds < duration, note.startSeconds + note.durationSeconds <= duration + 0.15,
                  note.midi == nil || (0...127).contains(note.midi!), note.confidence == nil || (note.confidence!.isFinite && (0...1).contains(note.confidence!)) else { throw RecognitionError.invalidResponse }
            let start = note.startSeconds * bpm / 60, length = min(note.durationSeconds, duration - note.startSeconds), beats = length * bpm / 60
            notes.append(MusicNote(midi: note.midi, start: free ? start : (start * 4).rounded() / 4, duration: free ? beats : max(0.25, (beats * 4).rounded() / 4), confidence: min(0.75, note.confidence ?? 0.55), rawStart: note.startSeconds, rawDuration: length))
        }
        guard speechOnly || !notes.isEmpty else { throw RecognitionError.invalidResponse }
        return RecognitionResult(notes: notes.sorted { $0.start < $1.start }, transcript: payload.transcript.map { String($0.prefix(20000)) })
    }
}
