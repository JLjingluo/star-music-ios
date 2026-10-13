# Star Music iOS · v0.3 第一阶段

原生 SwiftUI + AVFoundation 应用，支持 iOS 17 及以上的 iPhone / iPad。没有远程 WebView 依赖，界面、录音、识谱、编辑、合成音色与草稿存储都在设备上运行。

## 当前交付状态

此目录是 **可供 Xcode / GitHub Actions 构建的源码工程**，不是已经编译或签名的 IPA。工程制作环境为 Linux，没有 Xcode；必须在 macOS 或 Actions 的 macOS runner 上完成首次编译并处理任何编译/实机问题。GitHub 仓库连接和 Apple 签名材料尚未提供。不能将源码 ZIP 或模拟器包宣称为可安装到 iPhone 的应用。

## 已写入的第一阶段功能

- 深浅色 / 跟随系统、SwiftUI 动态字号、VoiceOver 语义、四板块导航。
- AVAudioRecorder 原生麦克风录音、真实时长与音量波形、自由哼唱和节拍模式、暂停/继续、权限拒绝后系统设置和空白创作入口。
- 进入后台、音频中断或旧音频设备断开时暂停；由用户主动恢复。原始 WAV 先保存后分析。
- 本地自相关音高识别，面向安静环境下清晰的单声部哼唱。不确定音符标记、原声校正、取消分析保留原录音、截取片段和重试。
- 原生五线谱编辑：点击、谱位拖动、明确添加模式、休止符、附点时值、拆分合并、八度变化、整体移调、复制小节、撤销重做。
- 自由节奏不强制量化；调号、实际移调和 BPM 分开操作。
- 内置钢琴、木吉他、合成器音色；在当前编曲中共享统一 PCM 时间轴。轨道静音/独奏/音量、新增空轨、复制主旋律、分段配器为可见的新声部。
- 应用沙盒 JSON 原子写入；写入成功才显示“已保存”。失败保留编辑内存并提供重试/导出。
- 同一份草稿箱：搜索、排序、文件夹、列表/网格、收藏、独立复制、重命名、可恢复删除。
- 原生项目包（含原录音）、MIDI、WAV 导出；项目包、MIDI 和音频导入。原生项目包格式为 StarMusicNative；兼容此前 Web 版导出的单个 StarMusic 项目包（不直接读取浏览器存储，暂不支持 Web 全量备份包）。
- 社区和消息明确处于演示/未接入状态。喜欢与收藏仅保存在本设备；不模拟线上发布成功。

首版文件导入上限 32 MB，音频识别上限 5 分钟，音频导出上限 10 分钟。需在实际 iPhone 上确认权限、来电、耳机切换和录音恢复行为。音量波形展示真实输入能量包络，不是逐采样波形。跨小节延音保留属性及持续播放，复杂跨行记谱、PDF、MusicXML、鼓网格、自动伴奏、批量管理和真实社区后端尚未实现。谱面调号为项目元数据，复杂调号记谱布局还需完善。

## 在 Mac 上打开

工程包中已包含 StarMusic.xcodeproj，可在 Mac 上用 Xcode 16.4 或更新版本直接打开。需要重新生成时，可以使用 XcodeGen：

```sh
brew install xcodegen
cd star-music-ios
xcodegen generate
open StarMusic.xcodeproj
```

选择 `StarMusic` scheme 和 iPhone 模拟器，运行。真机运行在 Signing & Capabilities 中选择你的 Team，并使用你自己的唯一 Bundle ID。免费 Apple ID 可通过本机 Xcode 做受限的真机开发签名；此云端签名工作流需要有效的证书与描述文件，通常来自付费 Apple Developer 计划。

## GitHub 模拟器构建

将此目录上传到私有 GitHub 仓库的根目录。推送 `main` 分支会触发 **iOS Build and Test**；也可在 Actions 中手动 Run workflow。

构建顺序：生成 Xcode 工程 → 在模拟器上运行音乐/草稿测试 → 编译 Release 模拟器应用及未签名真机 IPA → 上传 `StarMusic-Simulator` artifact 和测试结果。

下载 artifact 后解压 `StarMusic-Simulator.zip`，在 Mac 上安装到运行中的模拟器：

```sh
xcrun simctl install booted StarMusic.app
xcrun simctl launch booted music.star.starmusic
```

另外会生成 `StarMusic-iOS-Unsigned` artifact，内含 arm64 真机应用 `StarMusic-Unsigned.ipa`。此 IPA **尚未签名，不能直接安装**，可用本机 Xcode 或可信的侧载签名工具结合自己的 Apple ID 完成签名；个人开发签名的设备数量、有效期和能力受 Apple 限制。

模拟器 ZIP **不能安装到真实 iPhone**。GitHub macOS runner 可能消耗账户的 Actions 配额。

## 云端签名 IPA

在 Apple Developer 中为唯一 Bundle ID 创建 App ID，生成证书并从钥匙串导出 **包含私钥的 `.p12`**，以及与 Bundle ID、Team 和导出方式匹配的 `.mobileprovision`。

- `release-testing`：Ad Hoc 描述文件，必须包含安装设备的 UDID。
- `debugging`：Development 证书和开发描述文件，必须包含设备 UDID；设备可能需要开启开发者模式。
- `app-store-connect`：Apple Distribution 证书和 App Store 描述文件。输出用于 App Store Connect / TestFlight 上传的 IPA，不能直接侧载到手机。

在仓库 Settings → Secrets and variables → Actions 中配置：

**Secrets**

| 名称 | 内容 |
| --- | --- |
| `APPLE_CERTIFICATE_P12_BASE64` | `.p12` 文件的单行 Base64 |
| `APPLE_CERTIFICATE_PASSWORD` | 导出 `.p12` 时设置的密码，可为空 |
| `APPLE_PROVISION_PROFILE_BASE64` | `.mobileprovision` 文件的单行 Base64 |

**Variables**

| 名称 | 内容 |
| --- | --- |
| `APPLE_TEAM_ID` | Apple Developer Team ID |
| `APP_BUNDLE_ID` | 与描述文件严格一致的 Bundle ID，默认 `music.star.starmusic` |

在 Mac 本地编码文件，不要把证书、私钥或令牌发送到聊天：

```sh
base64 -i certificate.p12 | tr -d '\n' | pbcopy
base64 -i StarMusic.mobileprovision | tr -d '\n' | pbcopy
```

在 Actions 选择 **Signed iOS IPA**，选择匹配的导出方式并运行。脚本会检查 Team、Bundle ID、描述文件有效期和分发类型，创建临时钥匙串并在结束时清理。下载 `StarMusic-IPA-…` artifact。此工作流只打包，不自动提交 App Store 或 TestFlight。

## 安全的 GitHub 授权

推荐通过 GitHub 连接授权。若必须使用 PAT：创建空私有仓库后，在 Settings → Developer settings → Personal access tokens → Fine-grained tokens 中创建短期令牌，只选该仓库，赋予 Contents、Workflows、Actions 的 Read and write 权限；Metadata 默认只读。组织仓库可能需要组织审批。

把令牌配置到任务环境的安全凭据输入中；不要发送到聊天、源码或仓库。已经贴到聊天的令牌应立即撤销。连接所授予的权限不一定包含上传代码或触发 Actions，需以实际验证为准。
