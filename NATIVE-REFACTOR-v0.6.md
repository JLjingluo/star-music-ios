# Star Music v0.6 · Native iOS audit and refactor

This implementation applies the supplied seven-page native-iOS brief to the existing v0.5 source. Music recognition, the full CREPE model, offline drafts, original recordings, per-track editing, cloud configuration and package data remain on the existing shared model. This is a UI/navigation refactor, not a new accuracy claim.

## Page audit and final structure

| Page / flow | Previous implementation | Native replacement and reason |
| --- | --- | --- |
| Four main sections | Four ZStack surfaces and an HStack floating bar, custom selected indicator | A single `TabView`, four SF Symbol tab items and one `NavigationStack` per section. The OS supplies selection, safe areas, material and separate navigation histories. |
| Creation home | Hand-written brand header, hidden navigation bar, oversized gradient hero, custom press/cascade | Standard large navigation title and help toolbar; `List` / `Section` organize one prominent system creation button, import, optional tools and recent drafts. The actual app icon remains original. |
| Creation chooser | Card stack, custom close glyph and forced corner radius | System `sheet`, native list of three actions, cancellation toolbar and medium/large detents. Choices run after dismissal. |
| Drafts | Expanding fake search field, custom layout container and filter row | `.searchable`, native `List`, standard `LazyVGrid` only for explicit grid display, toolbar `Menu` / `Picker`. Dynamic Type accessibility sizes force list display. Standard back and edge swipe remain intact. |
| Draft actions | Mostly native menus/alerts already | Retain native `Menu`, text-field `alert`, recoverable-delete `confirmationDialog`, independent playback button and system share sheet. No destructive immediate removal. |
| Editor | Fullscreen editor with nested stack and custom chevron back | Push onto the current section's system navigation stack; retain standard back button and interactive edge swipe. Project rename/save and mode live in native toolbars. The tab bar hides only in the music workspace, as required by the creation brief. |
| Melody / notation | Genuine editable custom music canvas | Retain content-specific drawing; there is no standard SwiftUI musical notation/pitch editor. Standard buttons surround the canvas; native `GroupBox` supplies inspector grouping. Time remains left-to-right, pitch remains vertical. |
| Track editor | Custom bordered track cards and press animation | Native `GroupBox`, buttons, `Toggle`, `Slider`, `Picker` and `Menu`; timeline remains drawn music content. Per-track record/import, notes, source history and undo remain available. |
| Recording | Custom back chevron, decorative large record disk and card frame | Self-contained `fullScreenCover` with a system navigation title, cancellation toolbar and bordered-prominent recording action. Preserve confirmation when recording exists, real meter/timer, interruptions and original-audio saving. |
| Processing / import / export | Custom black dimming overlay and material panel | Native non-dismissable `sheet` with real stage text / `ProgressView`; explicit cancellation only when supported. No homemade mask, transition or percentage. |
| Key shift | Custom scroll/card sheet | Native `Form`, system controls, higher/lower, independent preview, apply/cancel. Relative intervals, timing, original recordings, overflow checks and undo retained. |
| Instruments | Already uses List/searchable/system sheet | Retain system design, instrument preview/application and scope controls. No fake downloads. |
| Community | Scroll/card feed, custom like burst; detail in sheet | Native list, segmented picker for recommendation/following, native search and pushed detail. Demo state stays explicit; likes/bookmarks are device-local. Comments use a normal dismissable sheet. |
| Messages | Card stack pretending to be settings rows | Native list with labeled status rows and `ContentUnavailableView`. No simulated online activity. |
| Profile / settings | Native list mixed with custom toggle | `Form` / `Section`, native `Toggle`, `Picker` and `NavigationLink`. Model settings remain a real form, including secure entry and Keychain storage. |
| Help / collections | Bespoke scroll text / collection list | Native list sections, standard navigation titles and system close action only when modal. |
| Empty / loading / error | Custom empty-state cards, some overlays | `ContentUnavailableView`, `ProgressView`, native alert/dialog; persisted status reflects real writes. Failed writes survive a system pop in memory and remain exportable/retryable. |

## Components deleted or replaced

Deleted `MusicTabBar`, `TabSurface`, `MusicPressStyle`, `JellyToggleStyle`, `LikeBurstButton`, `DraftCollectionLayout`, `CascadeEntrance`, the fake root brand/navigation header and decorative home stave/gradient container. `CardStyle` is replaced by a thin native `GroupBox` wrapper, not a custom bordered/shadowed card. `GoldButton` delegates to standard `.borderedProminent`; it draws no button background. Removed custom chevron-left controls, manual sheet dimming and `.presentationCornerRadius` overrides.

No `UITabBarAppearance`, custom back-button hiding, gesture interception or app-wide glass simulation is introduced. Brand yellow remains an accent; semantic system backgrounds and primary/secondary text follow appearance, contrast and accessibility. Navigation and modal movement use default system transitions. The existing touch-feedback preference gates SwiftUI selection sensory feedback when changing sections; no custom press style or UIKit impact generator remains. Ordinary mode retains plain explanations, simple mode hides secondary tools, and professional mode retains notation/parameters.

## Retained custom/native bridges

- Musical drawing: editable notation, chronological pitch-height plot, track time grid, draft score thumbnail and real microphone waveform. These are musical document content, not replacements for navigation or generic system controls.
- AVFoundation/Core ML/Security: audio, model inference and Keychain require platform frameworks; they are independent of visual chrome.
- `UIActivityViewController` is a system share sheet, bridged only for programmatically generated exports. SwiftUI has no direct presentation binding for `ShareLink`; this preserves the existing export-then-share flow without a custom sharing interface.
- `UIApplication` opens the system app-settings URL after microphone denial; no UIKit navigation shell is used.

## iOS 26 adoption and compatibility

Minimum deployment stays iOS 17. Native controls built against the iOS 26 SDK automatically adopt the actual iOS 26 design and Liquid Glass navigation layer. No `glassEffect` is needed on ordinary content cards. CI explicitly selects Xcode 26.2 and an iOS 26.2 iPhone 17 Pro simulator, failing if unavailable instead of silently claiming iOS 26 verification on an older SDK. Device compilation is still a genuine arm64 iPhoneOS build; unsigned output requires Apple signing to install.

Official references read for this change:

- [Adopting Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass): standard controls adopt the material; review/remove custom backgrounds and navigation overrides.
- [Tab bars — HIG](https://developer.apple.com/design/human-interface-guidelines/tab-bars): top-level navigation, clear labels, SF Symbols and preserved section history.
- [Designing for iOS — HIG](https://developer.apple.com/design/human-interface-guidelines/designing-for-ios): focus on content, adapt appearance/orientation/Dynamic Type, and preserve familiar system gestures.
- [Applying Liquid Glass to custom views](https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views): use custom material only when needed; avoid excessive effects and containers.

## Verification status

Local Swift parsing/project/plist checks pass; these are not Xcode compilation. Native XCTest, iOS 26 UI flows, actual simulator screenshots and the new IPA must be verified before the delivery record is marked complete. Live iPhone microphone/interruptions and a real user-configured cloud model remain outside simulator verification.

### Build 8 refinement after visual review

Removed the redundant home tools section, editor tool-card grid, full-width key-shift row and inline expanded note inspector. Secondary creation tools use the native toolbar menu; editor tools use a native Menu; note correction uses a standard sheet. Ordinary track mixing uses DisclosureGroup. The music-only surfaces use continuous 24–28 pt corners. Action groups explicitly use iOS 26 GlassEffectContainer and .glass / .glassProminent button styles, with system bordered fallbacks before iOS 26. System List/Form, navigation, sheets and tab bar retain their platform appearance. These changes are subject to fresh Xcode compilation and actual simulator capture; previous build 7 screenshots do not validate build 8.
