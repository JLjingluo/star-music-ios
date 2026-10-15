# Star Music v0.4.0 interaction reference

All three supplied Xiaohongshu videos were obtained through 33tool.com and reviewed across their full timelines using extracted frames and voice-over transcription. Media stays outside this repository; no creator assets or complete prompt text are reused.

- 西瓜同学🍉 — [10 interaction components](https://xhslink.cn/o/AQ41UpHd0tM): component identity, inline search expansion, continuous list/grid transitions and reversible state changes. Applied to the draft collection and search field.
- 林逸AIGC — [4 tactile button prompts](https://xhslink.cn/o/AiNvTx1ajSe): press/rebound, like burst, submission states and toggle motion. Applied to shared press feedback, local likes and settings. Audio processing uses real stage/loading state; there is no timed fake success or percentage.
- 叨叨AI — [3 interface Skills](https://xhslink.cn/o/ZtTGXs9kuk): define hierarchy and visual direction, refine existing content, audit typography/spacing/contrast before decoration. Applied to a restrained paper-and-staff visual system, consistent corners and quieter metadata. No external skill installation or approval handshake is required for this authorized redesign.

Home entrance is a finite 65 ms stagger with a small spring rise. Reduce Motion and VoiceOver display content immediately. Essential buttons have at least 44 pt hit regions. Dynamic Type accessibility sizes force one draft column. The system continues to distinguish demo community content and local likes from online services. Delete remains recoverable and requires confirmation.

Native verification: Xcode compilation and the music/storage XCTest suite run in GitHub Actions. Preview captures include dark/light home, the creation sheet, editor and launch motion. Microphone behavior still requires an iPhone; simulator screenshots do not establish device recording quality.

## Native studio expansion

Simple, standard and professional modes retain one project model. Professional controls expose actual per-track source trimming, beat offsets and engine configuration. Original audio and editable notes are distinct playback choices. Track recording/import use explicit creation controls; all analysis failures retain originals. Keychain configuration is separate from musical projects and exports. Model inference, network contracts and preview layouts require native verification.

Native cold launch now uses a static original brand storyboard on the app background, without an artificial delay. The OS transitions into the finite home cascade. Build 5 actual simulator video was reviewed frame by frame; the previous white launch was removed. Xcode simulator builds use ad-hoc signing and simulator-only Keychain entitlements so real key storage can be verified; the arm64 IPA remains explicitly unsigned. All three mode previews and model configuration were inspected from XCTest captures.

For v0.5, simple mode retains melody, playback, sound choice and a visible key-shift action. Ordinary mode uses plain explanations and hides BPM, time signature, quantization and MIDI pitch values. Both use a chronological pitch-height view: time proceeds left to right, pitch low to high. Notes are never sorted by pitch in a way that changes the melody. Professional mode retains explicit musical controls. Key shift previews a complete independent candidate before applying and remains undoable.


## v0.6 · System navigation and controls take precedence

The user's new native-iOS brief supersedes the earlier custom floating tab bar, custom press/rebound, burst likes, custom switch, expanding search and cascade entrance. Remove these implementations rather than imitating Liquid Glass with blur layers. Use one TabView with a NavigationStack per section, standard system back/edge-swipe, toolbar actions, List/Form/Section, searchable, Menu/Picker/Toggle and ContentUnavailableView. Workspace grouping uses native GroupBox. Recording stays a fullScreenCover with cancellation and data-protection confirmation; creation/instruments/key shift/progress use system sheets. No custom modal dimming or fake percentage.

Build with Xcode 26.2 and run iOS 26.2 simulator previews to obtain the real system material. iOS 17 remains the minimum; older systems use their own standard appearance. Keep brand yellow, the original app icon and static launch screen. Use semantic backgrounds and an adaptive ochre accent in light appearance for legibility. Do not tint every content surface or add glass to notation. SF Symbols supply functional icons. Only the actual notation, chronological pitch drawing, track timeline, preview thumbnail and microphone waveform remain custom because SwiftUI has no equivalent editable music controls.

Navigation push/pop, sheet motion and selection feedback belong to the OS. No root cascade or custom tab indicator remains. Failure to write a project retains its latest valid state in ProjectStore memory across a native pop and supports emergency package export and later retry; it is never marked saved until the disk write succeeds. Tests must verify this failure path as well as native tabs, native search, real switches, per-tab history, edge-swipe and modal cancellation.

Page/component audit, replacement reasons, source changes and official Apple references are recorded in NATIVE-REFACTOR-v0.6.md. Native UI screenshots are required before delivery; source parsing is insufficient.
