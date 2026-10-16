# Star Music v0.6 · 原生验证记录

## 当前验证状态

构建目标为 v0.6.0 build 8。完整测试 [38900876191](https://github.com/JLjingluo/star-music-ios/actions/runs/38900876191) 在源码 `b4cd39465cde4a36d699c55e711f9a9b739ebc22` 上实际通过 **43/43 单元测试、9/9 原生 UI 流程**（Xcode 26.2 / iOS 26.2 / iPhone 17 Pro）。包括此前失败的双轨模式切换、模型配置与点按音符打开校正面板。实际日志含 `** TEST SUCCEEDED **`。原生截图及完整结果包归档于 [诊断预发布](https://github.com/JLjingluo/star-music-ios/releases/tag/diagnostic-ui-38900876191)。

该 run 后续独立 `simctl` 预览捕获超时，整体结论为失败，不能当作最终交付成功。后续恢复只修改捕获、工作流及文档：`verify-native-test-run.py` 会核实原 run 的完整测试步骤成功，并对所有 App、模型、资源、测试及工程生成输入进行 git 比较；必须完全相同才能复用该测试证据。正常推送仍执行完整测试。最终成功构建 [38908242325](https://github.com/JLjingluo/star-music-ios/actions/runs/38908242325) 的源码为 `233eac597160832690371e2213df04849ed97423`。该 run 已实际通过：

- 相同 App / 模型 / 测试 / 工程输入核验，以及上述完整 43 + 9 测试结果恢复；来源证明随 Release 附件保存为 `UI-Native-Test-Provenance.json`。
- Release 模拟器构建及 arm64 iPhoneOS 构建，生成原始 `StarMusic-Unsigned.ipa`。
- 额外两条实际 Release UI 流程：创作面板 → 编辑器 → 原生返回与底栏恢复；浅色主页 → 系统设置开关。两条均通过，日志含 `** TEST SUCCEEDED **`。
- 真实 Release 深浅色主页 PNG，以及系统 XCTest 自动录制、未经剪接的启动与创作流程 MP4。不是效果图或合成视频。

独立 simctl 在此前恢复构建中出现安装、启动甚至空模拟器截图服务超时；最终由 XCTest 管理启动并捕获 Release 实际画面。捕获方案不改变 App、模型、测试源码或音乐数据。


## 最终交付与本机核验

[原始 IPA 直链](https://github.com/JLjingluo/star-music-ios/releases/download/ios-v0.6.0-unsigned-build-38908242325/StarMusic-Unsigned.ipa) · [Release 与实际预览](https://github.com/JLjingluo/star-music-ios/releases/tag/ios-v0.6.0-unsigned-build-38908242325) · [交付工作流 38909603017](https://github.com/JLjingluo/star-music-ios/actions/runs/38909603017)。2026-10-16 实际匿名 HEAD 返回 **200**，内容长度与下载核验一致，无需额外 ZIP 包装。

| 项目 | 实际核验 |
| --- | --- |
| 版本 / Build | 0.6.0 / 8 |
| 原始 IPA 字节数 | 42,325,372 |
| SHA-256 | `a748ac1cb1aafdd7113b68122d95ff144b7daec7ea3ece92ae26e4df76fa7075` |
| 平台 / 架构 | `iphoneos` / Mach-O `arm64`，SDK `iphoneos26.2`，最低 iOS 17.0 |
| 完整编译模型 | `PitchCREPE.mlmodelc` 合计 44,529,122 字节，附 CREPE 许可 |
| 签名 | **未签名**：无 `_CodeSignature`、无 Mach-O `LC_CODE_SIGNATURE`；安装需有效 Apple 签名 |
| 内容检查 | ZIP CRC 全部通过；无基准录音、测试包、签名凭据或令牌标记；校验值与 Release checksum 及 GitHub digest 相同 |

已实际下载并查看本次 Release 的深浅色主页、空白旋律编辑器；也查看完整测试中的音符校正面板、双轨普通/专业模式和模型配置截图。系统玻璃用于操作与导航，音乐内容保留连续圆角与清晰谱面；普通模式默认折叠混音，单音校正在选中后打开系统面板。原生 UI 断言验证单一底栏、工作区隐藏底栏、系统返回与侧滑、三种模式及显式添加/编辑入口。

`StarMusic-Entrance.mp4` 为未经剪接的系统原始录屏，H.264 / 1206×2622 / 109.103 秒，包含较长的模拟器及自动化等待。已提取并查看全过程与局部帧；运行器录屏帧时间不稳定，不能据此证明真机启动速度或动画流畅度。页面布局与交互以实际截图和上述 UI 断言为证据；真实设备的启动、动态字号、iPad 与音频中断体验仍需进一步验证。

## 修复过程中的失败记录

早期失败记录：第一次 build 8 原生测试：[38869645382](https://github.com/JLjingluo/star-music-ios/actions/runs/38869645382)，源码 `5141c11c95253edc44b749de1a354a29f8c5b244`，macOS 15 / Xcode 26.2 / iOS 26.2 iPhone 17 Pro。实际完成编译，43 项单元测试全部通过（14 项审查回归、28 项音乐/存储/模型、1 项全音域谱面几何），9 条 UI 流程通过 8 条。双音轨简洁模式展开工具的断言失败，故没有执行 Release 真机打包。此问题已修正并在上述 9/9 原生 UI 流程中通过；不把早期失败构建当作可交付 IPA。

43 项中实际验证：损坏音频导入回滚、正在渲染时停止并快速取消、八声道高采样率流式解码、五分钟计时溢出与片段读取、128 轨 MIDI 状态/音色往返、变速 format 0、音符拆合与源时间、来源所有权/撤销、项目包失败清理、保存失败的内存恢复、Keychain 读写删除及云端模拟 HTTP 契约。

## 哼唱基准边界

CI 实际准备并分析 HumTrans validation 固定四位演唱者的前 6 秒，共 1,176 个有参考音高的采样帧；素材仅进入测试资源，不进入应用。当前精确音高 207/1176，对照 204/1176；按时间音级匹配 289/1176，对照 304/1176（退步）；音级序列编辑距离 13，对照 17。该小样本不能支持商业级或行业领先准确率主张，本轮 UI/稳定性修复也没有改变识谱算法。

完整 CREPE 模型、YIN 与统一 RecognitionService 均保留。上述单元及少量基准不等于真实 iPhone 麦克风验证；蓝牙/来电/耳机切换、设备内存压力和用户自配模型服务尚未实机验证。没有用户云模型密钥，网络验证采用本地模拟 HTTP 响应。

第二次 build 8 复核：[38872243390](https://github.com/JLjingluo/star-music-ios/actions/runs/38872243390)，源码 `d40f2e8ae33d55d6ccdc901ccb1102c36889fa08`。43 项单元测试再次全部通过，双音轨简洁/普通/专业模式及模型配置流程通过。新增音符校正面板测试失败：实际辅助功能快照把一个音符报告为 `{{51, 301}, {310, 170}}`，即整个旋律图，导致点击定位错误。修复把辅助功能标签与拖动放在定位修饰器之前，音符有明确 44pt 矩形触控范围，空白添加手势仅在背景层启用。保留原失败测试，已在 `b4cd394` 的完整原生运行中验证通过；没有删除断言。

两次失败的完整 `.xcresult` 已分别归档至明确标注的诊断预发布 `diagnostic-ui-38869645382` / `diagnostic-ui-38872243390`，文件名 `Native-TestResults.zip`；本机下载并通过全部 ZIP CRC、Info.plist 与 Data 目录检查后，才移除 Actions 中同一份重复附件，保留证据并为后续产物腾出空间。公开诊断不表示有成功的 IPA。
