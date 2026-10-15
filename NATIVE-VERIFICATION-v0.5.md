# Native verification · v0.5.0 build 6

Ordinary and simple creation now show pitch height over time without requiring notation knowledge. The visible key-shift action previews the whole song higher or lower, preserves intervals and rhythm, retains original recordings and supports undo. Professional mode keeps musical parameters and notation.

- Source: `6743a3765ff195950dfa583fdd7985de61984d9e`.
- [Xcode build and tests](https://github.com/JLjingluo/star-music-ios/actions/runs/38657962915): **27 XCTest and 5 native UI tests passed**; Release simulator and arm64 iPhoneOS builds succeeded.
- [Public raw delivery](https://github.com/JLjingluo/star-music-ios/actions/runs/38659848248) succeeded. Anonymous HTTP download was verified, without a GitHub token or login.
- IPA **42,356,591 bytes**, SHA-256 `1eb2617fd2900e60101840996e3032778ff755cfeafada54eb7e1485b986e97a`, matching the release digest and checksum asset.
- Downloaded IPA checked: genuine arm64 iPhoneOS, version/build, ZIP integrity, no LC_CODE_SIGNATURE or bundle signature, full compiled CREPE **44,529,122 bytes**, no benchmark audio or test bundle, no GitHub credential markers.

[Raw unsigned IPA](https://github.com/JLjingluo/star-music-ios/releases/download/ios-v0.5.0-unsigned-build-38657962915/StarMusic-Unsigned.ipa) · [Checksum](https://github.com/JLjingluo/star-music-ios/releases/download/ios-v0.5.0-unsigned-build-38657962915/IPA-CHECKSUM.txt) · [Actual startup video](https://github.com/JLjingluo/star-music-ios/releases/download/ios-v0.5.0-unsigned-build-38657962915/StarMusic-Entrance.mp4)

## Recognition evaluation

Same full pretrained model, four fixed HumTrans validation singers, first six seconds each, 1,176 reference-voiced 20 ms points. This is a small validation comparison with v0.4.0, not a held-out full-dataset evaluation or a commercial-product ranking. Singer register, timing differences and reference annotation limitations affect alignment metrics. All results are retained below, including the metric that worsened.

| Measure | v0.4.0 | v0.5.0 |
| --- | ---: | ---: |
| Pitch-class sequence edit distance, ignoring timing (lower better) | 17 | 13 |
| Exact pitch match at reference times | 204 / 1176 (17.35%) | 207 / 1176 (17.60%) |
| Pitch-class match at reference times | 304 / 1176 (25.85%) | 289 / 1176 (24.57%) |
| First recorded excerpt, gain 0.01 and 16-bit quantization: recognized voiced duration | 0.14 s | 5.06 s |

Sequence structure and low-volume recovery improved in these cases. Timed pitch-class matching regressed. These data do **not** establish reliable general accuracy or parity with leading products. Do not reinterpret the edit-distance change as a universal accuracy percentage. Real iPhone microphone behavior, interruptions and generalization to other singers/rooms remain unverified.

Implementation adds multiple candidate peaks, phrase sequence decoding, periodicity support, conservative breath rejection, stable note-level pitch estimation and bounded gain on analysis copies. Source audio remains unchanged. Synthetic tests also check octave mistakes versus real leaps, repeated pitch separated by breath, quiet tones, silence and preserved timing.

[HumTrans source](https://github.com/shansongliu/HumTrans); recording license CC-BY-NC-4.0. Four evaluation files are fetched into ignored test resources and are absent from the app. Complete CREPE weights remain MIT licensed.

## Native preview review

Actual XCTest captures reviewed: simple/ordinary melody editing, plain-language key-shift sheet and professional tracks. Actual Release home dark/light and launch video are captured after restarting CoreSimulator; startup was reviewed across the brand screen and finite home cascade. The ordinary-mode capture catches its mode menu closing; it is an actual frame rather than a fabricated mockup.

- [Humming-Accuracy](https://github.com/JLjingluo/star-music-ios/releases/download/ios-v0.5.0-unsigned-build-38657962915/UI-A301D541-4331-4D6E-B0A4-F5A610C16824.json)
- [Melody-Standard](https://github.com/JLjingluo/star-music-ios/releases/download/ios-v0.5.0-unsigned-build-38657962915/UI-0BD130FC-680C-42C1-B474-688951736A11.png)
- [Melody-Simple](https://github.com/JLjingluo/star-music-ios/releases/download/ios-v0.5.0-unsigned-build-38657962915/UI-1E244285-DF15-43AC-B3D5-BB0F9130BCF1.png)
- [Key-Shift-Plain](https://github.com/JLjingluo/star-music-ios/releases/download/ios-v0.5.0-unsigned-build-38657962915/UI-15F03023-9EF1-4D2D-8818-38AC603FCF2D.png)
- [Tracks-Professional](https://github.com/JLjingluo/star-music-ios/releases/download/ios-v0.5.0-unsigned-build-38657962915/UI-62EE742F-05E5-4196-B17A-74FFD6C49C58.png)

Key-shift tests cover all tracks, preserved timing and intervals, source references, undo/redo and rejection of range overflow. UI tests actually add a note, preview/apply a higher key, switch simple/ordinary/professional modes and check hidden professional controls. Cloud contracts and Keychain are tested, but a real user-supplied cloud service was not exercised.

## Delivery and build storage

The repository was made public at the user’s request. Standard hosted build runtime is free under GitHub’s public-repository rules; artifact storage has a separate quota. Approximately 207 MiB of generated duplicate artifacts from releases already containing the IPA and previews were removed. Release files remain available. The IPA is explicitly unsigned and requires valid Apple signing to install.
