import SwiftUI
import Security
import CryptoKit

enum RecognitionEngine: String, Codable, CaseIterable, Identifiable {
    case neural, yin, cloud
    var id: String { rawValue }
    var title: String { switch self { case .neural: "本地 AI · CREPE"; case .yin: "本地音高分析 · YIN"; case .cloud: "我的音频大模型" } }
}
enum CloudProvider: String, Codable, CaseIterable, Identifiable {
    case doubao, compatible
    var id: String { rawValue }
    var title: String { self == .doubao ? "豆包 / 火山方舟" : "兼容 Chat Completions 的音频模型" }
}
struct RecognitionSettings: Codable, Equatable {
    var engine: RecognitionEngine = .neural
    var provider: CloudProvider = .doubao
    var baseURL = "https://ark.cn-beijing.volces.com/api/v3"
    var model = ""
    static func load() -> Self {
        guard let data = UserDefaults.standard.data(forKey: "recognitionSettings"), let settings = try? JSONDecoder().decode(Self.self, from: data) else { return Self() }
        return settings
    }
    func save() throws { UserDefaults.standard.set(try JSONEncoder().encode(self), forKey: "recognitionSettings") }
    func endpoint() throws -> URL {
        guard var components = URLComponents(string: baseURL.trimmingCharacters(in: .whitespacesAndNewlines)), components.scheme == "https", components.host != nil,
              components.user == nil, components.password == nil, components.query == nil, components.fragment == nil else { throw RecognitionError.configuration("请输入不带密钥的 HTTPS API 基础地址。") }
        components.host = components.host?.lowercased()
        let path = components.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard !path.contains("chat/completions/") else { throw RecognitionError.configuration("完整端点应以 /chat/completions 结束，不支持额外路径或查询参数。") }
        components.path = path.isEmpty ? "" : "/" + path
        if !components.path.hasSuffix("/chat/completions") { components.path += "/chat/completions" }
        guard let url = components.url else { throw RecognitionError.configuration("API 地址无效。") }
        return url
    }
}
enum RecognitionError: LocalizedError {
    case configuration(String), invalidResponse, modelMissing, service(Int), secret(Int32), audioTooLarge
    var errorDescription: String? { switch self {
    case .configuration(let text): text
    case .invalidResponse: "模型没有返回有效的音符结果。原声和当前编辑均已保留，请换用支持音频的模型或本地识谱。"
    case .modelMissing: "本地 AI 模型无法加载，请切换 YIN 分析。"
    case .service(let code): switch code {
        case 401, 403: "服务拒绝鉴权（HTTP \(code)），请检查此地址的密钥与模型权限。"
        case 404: "没有找到模型或端点（HTTP 404），请检查最终请求地址和模型 ID。"
        case 400, 415, 422: "服务不接受本次音频请求（HTTP \(code)），请确认模型支持 input_audio WAV 输入。"
        case 429: "服务请求过多或额度不足，请检查账户用量后重试。"
        default: "模型服务暂不可用（HTTP \(code)）。原声与编辑仍保留，请稍后重试。"
        }
    case .secret(let status): "无法保存或读取设备密钥（\(status)）。"
    case .audioTooLarge: "发送给音频模型的 WAV 超过 25 MB。请选择较短的原声片段；完整原声仍保留。"
    } }
}
enum ModelKeychain {
    private static let service = "music.star.starmusic.recognition"
    private static let account = "user-model"
    private static var query: [String: Any] { [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service, kSecAttrAccount as String: account] }
    private static func scopedQuery(_ settings: RecognitionSettings) throws -> [String: Any] {
        let endpoint = try settings.endpoint().absoluteString
        let fingerprint = SHA256.hash(data: Data(endpoint.utf8)).map { String(format: "%02x", $0) }.joined()
        var q = query; q[kSecAttrAccount as String] = "endpoint-" + fingerprint; return q
    }
    static func read(for settings: RecognitionSettings) throws -> String {
        let value = try read(query: scopedQuery(settings))
        if !value.isEmpty { return value }
        // Migrate the old single key only to the previously saved endpoint.
        // Changing a hostname can never forward that key to the new service.
        if (try? settings.endpoint()) == (try? RecognitionSettings.load().endpoint()) {
            let old = try read()
            if !old.isEmpty { try save(old, for: settings); try save("") }
            return old
        }
        return ""
    }
    static func save(_ value: String, for settings: RecognitionSettings) throws { try save(value, query: scopedQuery(settings)) }
    static func read() throws -> String { try read(query: query) }
    private static func read(query: [String: Any]) throws -> String {
        var q = query; q[kSecReturnData as String] = true; q[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: CFTypeRef?
        let status = SecItemCopyMatching(q as CFDictionary, &result)
        if status == errSecItemNotFound { return "" }
        guard status == errSecSuccess, let data = result as? Data, let text = String(data: data, encoding: .utf8) else { throw RecognitionError.secret(status) }
        return text
    }
    static func save(_ value: String) throws { try save(value, query: query) }
    private static func save(_ value: String, query: [String: Any]) throws {
        let bytes = Data(value.trimmingCharacters(in: .whitespacesAndNewlines).utf8)
        if bytes.isEmpty { let status = SecItemDelete(query as CFDictionary); guard status == errSecSuccess || status == errSecItemNotFound else { throw RecognitionError.secret(status) }; return }
        let updated = SecItemUpdate(query as CFDictionary, [kSecValueData as String: bytes] as CFDictionary)
        if updated == errSecSuccess { return }
        guard updated == errSecItemNotFound else { throw RecognitionError.secret(updated) }
        var q = query; q[kSecValueData as String] = bytes; q[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        let status = SecItemAdd(q as CFDictionary, nil); guard status == errSecSuccess else { throw RecognitionError.secret(status) }
    }
}

struct RecognitionSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var settings = RecognitionSettings.load()
    @State private var key = ""
    @State private var status = ""
    @State private var checking = false
    var body: some View {
        Form {
            Section("识谱引擎") {
                Picker("引擎", selection: $settings.engine) { ForEach(RecognitionEngine.allCases) { Text($0.title).tag($0) } }
                Text("CREPE 完整预训练模型随 App 安装，离线分析单声部旋律。YIN 提供独立的音高分析，可交叉校正。大模型结果会标记为待校正。").font(.caption).foregroundStyle(.secondary)
            }
            Section("自己的音频模型") {
                Picker("接口类型", selection: $settings.provider) { ForEach(CloudProvider.allCases) { Text($0.title).tag($0) } }
                    .onChange(of: settings.provider) { _, provider in settings.baseURL = provider == .doubao ? "https://ark.cn-beijing.volces.com/api/v3" : "" }
                TextField("HTTPS API 基础地址或完整端点", text: $settings.baseURL).textInputAutocapitalization(.never).autocorrectionDisabled().keyboardType(.URL)
                    .onChange(of: settings.baseURL) { _, _ in key = ""; status = "地址已更改，请填写此服务的密钥或读取该地址已保存的密钥。" }
                if let endpoint = try? settings.endpoint() { Text("请求地址：" + endpoint.absoluteString).font(.caption).textSelection(.enabled) }
                DisclosureGroup("地址示例与音频能力") {
                    Text("基础地址示例：https://api.example.com/v1；完整端点示例：https://api.example.com/v1/chat/completions。请勿在地址中填写密钥、查询参数或用户名。").font(.caption)
                    Text("连接检查只发送文字，验证地址、鉴权与模型访问；音频输入与旋律识别尚未验证。请用自己的短录音主动测试，可能产生服务费用。").font(.caption)
                }
                Button("读取此地址已保存的密钥") { do { key = try ModelKeychain.read(for: settings); status = key.isEmpty ? "此地址尚未保存密钥" : "已读取此地址的设备密钥" } catch { status = error.localizedDescription } }
                TextField("模型 ID / 推理接入点 ID", text: $settings.model).textInputAutocapitalization(.never).autocorrectionDisabled().accessibilityIdentifier("model.identifier")
                SecureField("API Key", text: $key).textInputAutocapitalization(.never).autocorrectionDisabled()
                Text("使用方舟控制台中支持音频输入的模型或接入点 ID；不预设未核验的型号。其他平台须支持 messages 的 input_audio（WAV / Base64）。文字模型无法读取哼唱。").font(.caption).foregroundStyle(.secondary)
                Button(checking ? "正在检查连接…" : "检查连接") { Task { await check() } }.disabled(checking)
                if !status.isEmpty { Text(status).font(.caption).accessibilityLabel(status) }
            }
            Section {
                Text("选择大模型后，只有主动识别才会把所选音频发送到此 API 地址；服务可能按你的账户计费。密钥仅保存在本设备 Keychain，不进入草稿、项目包或源码。检查连接仅验证鉴权和模型访问，不代表音频识谱准确性。").font(.caption).foregroundStyle(.secondary)
                Button("删除设备上的密钥", role: .destructive) { do { try ModelKeychain.save("", for: settings); key = ""; status = "设备密钥已删除" } catch { status = error.localizedDescription } }
            }
        }.navigationTitle("识谱与我的模型")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("保存") { save() }.accessibilityIdentifier("model.save") } }
            .task { do { key = try ModelKeychain.read(for: settings) } catch { status = error.localizedDescription } }
    }
    private func save() {
        do { if settings.engine == .cloud { _ = try settings.endpoint(); guard !settings.model.isEmpty, !key.isEmpty else { throw RecognitionError.configuration("请填写支持音频的模型 ID 和密钥。") } }; if (try? settings.endpoint()) != nil { try ModelKeychain.save(key, for: settings) }; try settings.save(); dismiss() }
        catch { status = error.localizedDescription }
    }
    private func check() async {
        checking = true; defer { checking = false }
        do { try await CloudRecognitionClient.check(settings: settings, key: key); status = "地址、鉴权与模型访问已通过文字请求检查。音频输入：未验证；旋律识别：未验证。" }
        catch { status = error.localizedDescription }
    }
}

struct RecognitionEngineControl: View {
    @State private var settings = RecognitionSettings.load()
    @State private var configure = false
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Picker("识谱方式", selection: $settings.engine) { ForEach(RecognitionEngine.allCases) { Text($0.title).tag($0) } }.pickerStyle(.menu).accessibilityIdentifier("recognition.engine")
                Spacer()
                Button { configure = true } label: { Image(systemName: "slider.horizontal.3").frame(width: 44, height: 44) }.accessibilityLabel("配置识谱和自己的模型")
            }
            if settings.engine == .cloud { Text("主动识别会发送所选原声至 \((try? settings.endpoint().host) ?? "你配置的接口")；结果需要校正。").font(.caption2).foregroundStyle(.secondary) }
        }.onChange(of: settings.engine) { _, _ in try? settings.save() }
            .sheet(isPresented: $configure, onDismiss: { settings = .load() }) { NavigationStack { RecognitionSettingsView() } }
    }
}
