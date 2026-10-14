# Star Music iOS · v0.4.0

原生 SwiftUI + AVFoundation，支持 iOS 17 及以上 iPhone / iPad。离线录音、乐谱编辑、逐轨编曲与草稿保存使用同一份项目数据。

## 本轮实现

- 简洁、普通、专业模式共用工程和撤销历史，改变工具密度；专业模式开放识谱引擎和逐轨原声裁剪、时间偏移等控制。
- 随 App 安装完整 CREPE Core ML 模型（22,244,328 参数，FLOAT16），不下载模型即可识谱；独立 YIN 分析加入谐波校正、插值、颤音稳定和静音分段。目标仍是清晰单声部，复杂歌曲不保证准确。
- 录唱、音频导入与重新分析统一经过 RecognitionService 和高质量重采样。失败或取消保留原声；重新分析确认后才替换所选轨音符，可撤销。
- 用户可配置 HTTPS API 地址、支持音频的模型/接入点 ID 和设备 Keychain 密钥。支持方舟兼容的 Chat Completions `input_audio` WAV/Base64；不假定任何特定豆包型号具有音频能力。文字识别与音乐识谱分开，前者不替换音符。
- 每轨可命名、编辑音符、单独录唱、导入音频/MIDI、静音、独奏及调音量。原声与乐器播放可切换；所有轨道共享 PCM 时间线，历史原声可回听。
- v2 项目包保留所有轨道、原声、历史原声、配器和识谱修订，并兼容旧包。独立复制项目会复制原声文件；密钥不进入草稿或项目包。
- 首页仅一个底部导航，工作区隐藏；深浅色、有限的分层入场、按压反馈、搜索展开和草稿网格切换尊重动态字号、VoiceOver 与减少动态效果。

音频导入最多 256 MB，项目包最多 512 MB（原声合计 256 MB），识谱最多 5 分钟，导出最多 10 分钟；项目最多 128 轨。BPM 改变音符播放节奏，但不自动拉伸原声音频。内置钢琴、木吉他和合成器为实际合成音色，不是假装下载的采样库。

社区和消息明确标注演示/未接入；不会显示虚假发布或发送成功。复杂调号布局、PDF、MusicXML、鼓网格和自动伴奏仍待实现。

## 验证与交付

本轮代码附带模型推理、YIN 谐波/颤音分段、重采样、云端请求与失败处理、多轨原声复制/项目包迁移、共享音频时间线、撤销以及原生 UI 流程测试。必须以当前提交的 GitHub Actions 结果为准；源码语法检查不代表 Xcode 编译通过。

历史 v0.3.1 已完成 Xcode 构建。v0.4.0 的实际编译、测试、原生截图和原始 IPA 由本轮工作流生成，发布前核对。没有用户自配服务密钥时，云端仅验证模拟 HTTP 契约；真实麦克风、耳机切换和来电仍需 iPhone 验证。

私有仓库：https://github.com/JLjingluo/star-music-ios 。Direct IPA Download 工作流在成功构建后直接发布 `.ipa`，没有额外 ZIP 包装。未签名包需有效 Apple 签名才能安装。

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

