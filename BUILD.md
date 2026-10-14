# iOS 构建交付

构建提交：16789e6264a7c3051e76b05a5037bbdafb9bbde2

成功构建：https://github.com/JLjingluo/star-music-ios/actions/runs/38422764650

状态：Xcode 16.4 编译成功；9 项 XCTest 通过；Release 模拟器应用成功启动并截取首页；Release arm64 iPhoneOS 应用打包为未签名 IPA。

## 获取文件

登录 GitHub 账号 JLjingluo，打开成功构建页面底部的 Artifacts：

1. 下载 **StarMusic-iOS-Unsigned**，解压得到 `StarMusic-Unsigned.ipa`。
2. 若在 Mac 模拟器上体验，下载 **StarMusic-Simulator**，其中有模拟器 `.app` ZIP 和首页 PNG。
3. 测试结果在 **StarMusic-TestResults**。

Artifact 保留 14 天（测试结果 7 天），请下载保存。未签名 IPA 需要先使用有效的 Apple ID / 开发者证书签名；App Store Connect 的签名包也不能直接侧载到真机。付费开发者可按 README 配置签名工作流。当前源代码依然支持在 Mac 的 Xcode 中直接打开、选择个人 Team 并运行到真机。

## 已验证范围

音高与静音识别、自由节奏时间定位、MIDI 往返与重复音符、无效导入数据校验、WAV PCM 编码、草稿原子保存/独立复制/恢复、项目包原录音保留、撤销重做。实际麦克风和音频中断行为未作真机测试。

## IPA 直链

[直接下载 StarMusic-Unsigned.ipa](https://github.com/JLjingluo/star-music-ios/releases/download/ios-v0.3.0-unsigned-build-38422764650/StarMusic-Unsigned.ipa)

没有额外 ZIP 包装。仓库保持私有，下载需有访问权限的 GitHub 登录。该包未签名，安装到 iPhone 前需要有效的 Apple 签名。已验证包内为 arm64 iPhoneOS 应用，并提供 SHA-256 校验附件。
