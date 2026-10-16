# Star Music v0.6 · 原生界面审查与重构

基于已有 v0.5 源码落实用户提供的七页 iOS 26 原生重构要求，并进一步收简布局。保留统一工程模型、完整 CREPE、YIN、离线草稿、原始录音、逐轨创作、用户模型配置与项目包。本轮界面及稳定性修复不代表新增了行业级识谱准确率。

## 页面审查与最终结构

| 页面 | 删除或调整的旧实现 | 最终原生实现及原因 |
| --- | --- | --- |
| 四大板块 | ZStack 页面容器、HStack 悬浮导航与自绘选中指示 | 一个 `TabView`，四个 SF Symbols 标签，每个板块一个 `NavigationStack`。系统管理选中态、安全区、材质与独立返回历史。 |
| 创作首页 | 手写品牌导航、装饰性五线谱、大渐变卡、自定义按压及瀑布入场 | 系统大标题；`List` / `Section` 仅保留创作、导入及最近草稿。空白乐谱、乐器库及帮助收进原生工具栏 `Menu`，减少同屏信息。原创品牌图标保留。 |
| 创作选择 | 自绘关闭按钮、卡片堆叠、强制弹层圆角 | 系统 `sheet`、三条明确入口、取消工具栏与中/大 detent。抽屉关闭后才执行选择。 |
| 草稿箱 | 假搜索框展开动画、自定义布局容器及筛选栏 | `.searchable`、原生 `List`、显式切换的 `LazyVGrid`、工具栏 `Menu` / `Picker`。辅助功能大字号使用列表。保留默认返回与侧滑。 |
| 草稿操作 | 原有可用的系统菜单继续保留 | 原生重命名 `alert`、可恢复删除 `confirmationDialog`、独立试听与系统分享。操作目标明确，删除进入最近删除。 |
| 编辑器 | 嵌套导航、手写返回箭头、工具卡网格、整行换调、内联校正面板 | 原生 push、系统返回与侧滑；顶部为模式及工程菜单，底部工具栏为撤销、重做与分享。播放和换调在同一组玻璃控件中；低频工具用 `Menu`；点音符打开系统校正 `sheet`。工作区隐藏系统 tab bar。 |
| 旋律与五线谱 | 保留真正的音乐内容绘制 | SwiftUI 没有可编辑谱面或旋律高低图的标准替代物，因此保留画布。前后顺序从左到右，音高上下排列；主要音乐内容采用 24–28 pt 连续圆角和语义背景，谱面后面不堆玻璃。 |
| 各个声音/多轨 | 大量同时展开的音量、静音、独奏及来源控件 | 圆角音乐分组、原生玻璃按钮、`Toggle` / `Slider` / `Picker` / `Menu`。普通模式把混音收进 `DisclosureGroup`；编辑、逐轨录唱及导入仍有明确入口。原声历史及撤销继续可用。 |
| 录音 | 装饰英文标题、自绘返回、重复长说明 | 独立 `fullScreenCover`、系统导航与取消、真实计时/波形/状态、原生玻璃录音按钮。提示使用 `DisclosureGroup`。已有录音时保留退出确认与原声保存，不伪造录制数据。 |
| 分析、导入及导出 | 黑色遮罩与手画处理面板 | 系统非交互关闭的 `sheet`、`ProgressView` 与真实阶段文字；支持取消的任务才展示取消。不自绘蒙层、不显示虚假百分比。 |
| 换调 | 大段标题/说明及卡片内多个重复主按钮 | 原生 `Form`，升高/降低、独立试听、恢复原高度；应用和取消放在系统工具栏，简短解释置于 Section footer。保留节奏、相对音程、原声、越界检查及撤销。 |
| 乐器 | 保留已有系统实现 | `List` / `.searchable` / 系统 `sheet`，明确试听、应用与配器范围。不显示虚假下载。普通模式使用“整段旋律”“选中的声音”等易懂文字。 |
| 社区及详情 | 卡片信息流、点赞爆炸、详情假模态层级 | 原生列表、分段 Picker、系统搜索、详情 push、评论系统 sheet。持续标明演示状态；喜欢/收藏仅为本机记录。 |
| 消息 | 设置项式卡片堆叠 | 原生列表与 `ContentUnavailableView`，明确未接入线上消息，不模拟成功通知。 |
| 我的与设置 | 混入自绘开关 | `Form` / `Section`、原生 `Toggle` / `Picker` / `NavigationLink`。模型配置保持真实表单及安全输入，密钥仅在设备 Keychain。草稿入口仍共用同一数据源。 |
| 帮助、空态、加载与错误 | 自定义空态卡及部分遮罩 | 系统列表、`ContentUnavailableView`、`ProgressView`、`alert` / `confirmationDialog`。保存状态反映真正写盘；失败后有效编辑在内存保留，可返回草稿重开、重试或紧急导出。 |

## 组件级替换

删除 `MusicTabBar`、`TabSurface`、`MusicPressStyle`、`JellyToggleStyle`、`LikeBurstButton`、`DraftCollectionLayout`、`CascadeEntrance`、手写顶部导航及装饰性首页容器。删除手写返回箭头、手画模态遮罩和强制 `.presentationCornerRadius`。

`GoldButton` 使用 iOS 26 的 `.glassProminent`；播放、换调、乐器及轨道操作使用 `.glass` / `.glassProminent` 和 `GlassEffectContainer`。主操作固定使用暖黄配深色文字，避免浅色模式变成深褐色；录音有独立红色语义。iOS 17–25 回退到系统 `.bordered` / `.borderedProminent`，不模拟玻璃。

音乐内容分组仅设置连续圆角、内边距及系统语义次级背景；设置、列表与表单仍使用平台容器。没有加入 `UITabBarAppearance`、隐藏系统返回按钮、拦截手势或全屏毛玻璃。顶部和底部导航、弹层、push/pop 动画均由系统负责。切换板块的原生 `sensoryFeedback` 遵循用户的触感开关。

## SwiftUI 实现与模式层级

- 导航入口在 `StarMusicApp.swift`：`TabView` → 各板块 `NavigationStack` → `.navigationDestination(item:)`。编辑工作区只隐藏 `.tabBar`，保留导航栏。
- 原生玻璃兼容层在 `MusicActionStyle`、`MusicGlassGroup`：使用 `if #available(iOS 26.0, *)` 调用新 API，旧系统使用标准按钮。没有自绘玻璃底层。
- `EditorView` 把画布、播放、工具、检查器拆成独立视图，避免庞大 SwiftUI 表达式拖慢类型检查。音符校正、乐器、换调和音符选项使用系统 sheet；菜单及工具栏承载低频动作。
- 简洁模式主要显示旋律、试听、换调及声音选择，更多工具显式展开；普通模式保留简短说明，隐藏 BPM、拍号和量化术语；专业模式提供谱面、速度、调号、识谱引擎和逐轨高级参数。三种模式共用同一工程。
- 切换模式退出临时添加状态并收起扩展工具，不修改任何音乐内容，避免工具隐藏后仍处于添加模式。

## 保留自定义绘制及 UIKit 桥接的理由

可编辑谱面、按时间排列的音高图、音轨时间线、谱面缩略图和真实麦克风波形属于音乐文档内容，没有系统控件可以直接替代。它们不承担通用导航或模态交互。

音频、模型推理及密钥分别使用 AVFoundation、Core ML 和 Security。`UIActivityViewController` 仅桥接系统分享面板，用于生成文件后的程序化分享；`ShareLink` 本身没有这一呈现绑定。麦克风拒绝后的 `UIApplication` 仅打开系统设置 URL。没有 UIKit 自绘导航框架。

## 平台与验证边界

最低系统保持 iOS 17；CI 明确选择 Xcode 26.2、iOS 26.2 和 iPhone 17 Pro 模拟器。目标不可用时失败，不使用旧 SDK 冒充 iOS 26 验证。真机产物使用 arm64 iPhoneOS 编译；未签名 IPA 需要有效 Apple 签名才能安装。

最终编译、测试、实际预览及 IPA 校验以 [原生验证记录](NATIVE-VERIFICATION-v0.6.md) 为准。源码解析不能证明 Xcode 编译成功。模拟器不能证明真实 iPhone 麦克风、来电、蓝牙和设备内存压力行为；没有用户模型密钥时也不宣称真实云端识谱已通过。

本轮已读取的 Apple 官方参考：

- [Adopting Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass)：使用标准控件，审查并移除材质/导航覆盖。
- [Tab bars · HIG](https://developer.apple.com/design/human-interface-guidelines/tab-bars)：一级导航、清楚的标签、SF Symbols 与板块历史。
- [Designing for iOS · HIG](https://developer.apple.com/design/human-interface-guidelines/designing-for-ios)：内容优先，适配外观、方向和动态字号，保留系统手势。
- [Applying Liquid Glass to custom views](https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views)：按需要使用玻璃控件及分组，避免把材质堆在内容背后。
