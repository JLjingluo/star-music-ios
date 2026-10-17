# Star Music v0.7 · 原生验证记录

目标为 v0.7.0 / build 9，iOS 17 起，使用 Xcode 26.2 构建。当前尚未完成新版 IPA 验证，不将 v0.6 的通过结果当成本轮结果。

## 本轮执行

- `174bca2` / [38994489109](https://github.com/JLjingluo/star-music-ios/actions/runs/38994489109)：新增密集谱测试数据的一条复合表达式导致 Swift 编译器类型检查超时，已拆成明确的循环与局部变量。
- `b519c04` / [38994790325](https://github.com/JLjingluo/star-music-ios/actions/runs/38994790325)：应用源码编译通过；UI 测试编译发现应使用 XCUIDevice 的方向控制而非 UIDevice 的只读属性，已更正。未把未执行的测试计为通过。
- `4fec603` / 38994951252：后续安全边界修复触发新提交，旧运行自动取消。
- `eff24bc` / [38995085354](https://github.com/JLjingluo/star-music-ios/actions/runs/38995085354)：完整原生回归已实际成功：53 项单元测试、11 条 iPhone UI 流程、iPad 密集谱流程及两条 Release UI 捕获均通过，Release 模拟器与 arm64 iPhoneOS 构建通过。日志归档为 native-v7-initial-passing-logs.zip。已查看真实密集谱、底部不重叠及大字号截图；字形存在、短音不再成团。此为中间验证，不作为最终 IPA。

修复清单、源码判断及限制见 [审查回应](AUDIT-RESPONSE-v0.7.md)。字体源与许可见 Resources/FONT-MANIFEST.json / Bravura-LICENSE.txt；完整 CREPE 模型仍保留。

## 尚不能声称的结果

尚未在真实最低支持设备测得极限内存，未实际验证麦克风、蓝牙、来电或用户自配模型服务；旧 JSON 备份的极限内存路径仍有边界。谱面为编辑参考，并非完整出版雕版。没有 Apple 签名凭据，后续产物仍应明确为未签名；安装需要用户自己的有效 Apple 签名。

## 最终补充回归待执行

追加了按字体基线的字形绘制、自由哼唱无符干显示、小节线避让、长空段显示折叠、v3 原声 SHA-256 校验、旧包与 MIDI 导入前内存预算，以及全新 Release 预览设备。用户继续要求增加上下音符避让与简谱：每个起音/同时音保留 96pt，小节处 120pt，新增同源简谱编辑与 PDF/文本导出。最终目标 56 项单元测试和 13 条 iPhone UI 流程，另执行 iPad 与 Release 捕获；这些新增修改尚未通过本机无法执行的 Xcode 验证。最终以实际 Actions 日志和下载包核验为准。

- `05241c8` / [39015397369](https://github.com/JLjingluo/star-music-ios/actions/runs/39015397369)：含简谱/PDF 的应用源码完成原生编译；新增 PDF 单测的复合 map 表达式触发类型检查超时，测试未执行。已拆分为明确循环与局部类型，保留所有验证断言。
