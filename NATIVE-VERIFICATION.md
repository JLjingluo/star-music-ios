# Native verification · v0.4.0 build 5

The full offline pitch model, shared recognition service and independently editable tracks are compiled into the native app. Simple, standard and professional modes share musical data. Native review found and fixed high-pitch YIN subharmonic selection, the white cold launch and Keychain access in unsigned simulator testing.

- Source: `8dcb9d2696a50675923aff3b692e4e3b38a817b9`.
- [Successful Xcode build](https://github.com/JLjingluo/star-music-ios/actions/runs/38608702962): macOS 15 / Xcode 16.4, iPhone 16 Pro simulator. **20 unit tests and 4 UI tests passed**. Release simulator and generic iPhoneOS builds succeeded.
- Tests actually load the bundled full Core ML model, predict C3/A3/A4, analyze a trimmed audio file, retain originals on cancellation, check YIN strong harmonics and vibrato/rest segmentation, exercise Keychain read/write/delete, validate audio HTTP payload/failure behavior and round-trip multi-track originals/history through independent copies and project packages.
- [Delivery run](https://github.com/JLjingluo/star-music-ios/actions/runs/38609546688) succeeded. The raw IPA was downloaded here and its ZIP integrity, version, arm64 Mach-O and iPhoneOS platform checked. Its binary has no LC_CODE_SIGNATURE, bundle signature or provisioning profile. Compiled LaunchScreen and full PitchCREPE model are present; the model totals **44,529,122 bytes** and retains the 22,244,328-parameter full architecture. Credential marker scan was clean.
- IPA: **42,268,081 bytes**. SHA-256: `f6a74038276d5c5ab68f046668b2f43841d40e1fa17f445af125f80b17b2ea18`, matching the release asset digest and checksum attachment.

[Raw unsigned IPA](https://github.com/JLjingluo/star-music-ios/releases/download/ios-v0.4.0-unsigned-build-38608702962/StarMusic-Unsigned.ipa) · [Checksum](https://github.com/JLjingluo/star-music-ios/releases/download/ios-v0.4.0-unsigned-build-38608702962/IPA-CHECKSUM.txt) · [Actual launch video](https://github.com/JLjingluo/star-music-ios/releases/download/ios-v0.4.0-unsigned-build-38608702962/StarMusic-Entrance.mp4)

## Actual native previews

Home dark/light, native score workspace, track chooser, three mode layouts and model settings were inspected. The launch video was reviewed across the transition from the system brand launch screen into the home cascade. There is one custom bottom navigation, hidden in workspaces. Model settings no longer display a Keychain entitlement error.

- [StarMusic-Home](https://github.com/JLjingluo/star-music-ios/releases/download/ios-v0.4.0-unsigned-build-38608702962/StarMusic-Home.png)
- [StarMusic-Home-Light](https://github.com/JLjingluo/star-music-ios/releases/download/ios-v0.4.0-unsigned-build-38608702962/StarMusic-Home-Light.png)
- [Score-Editor](https://github.com/JLjingluo/star-music-ios/releases/download/ios-v0.4.0-unsigned-build-38608702962/UI-258BDF5A-561F-48FE-8E4B-5688E322217D.png)
- [Model-Settings](https://github.com/JLjingluo/star-music-ios/releases/download/ios-v0.4.0-unsigned-build-38608702962/UI-BE55906D-9904-4882-8512-7A2F3BD5B349.png)
- [Tracks-Professional](https://github.com/JLjingluo/star-music-ios/releases/download/ios-v0.4.0-unsigned-build-38608702962/UI-7E33CAAD-C759-4C52-B304-CB56E33B127D.png)
- [Tracks-Simple](https://github.com/JLjingluo/star-music-ios/releases/download/ios-v0.4.0-unsigned-build-38608702962/UI-D64E4AD7-89CF-41C4-8C10-FFC52E823199.png)
- [Tracks-Standard](https://github.com/JLjingluo/star-music-ios/releases/download/ios-v0.4.0-unsigned-build-38608702962/UI-8C60C33F-478E-4FB6-80DA-89928DDBCA91.png)
- [Track-Chooser](https://github.com/JLjingluo/star-music-ios/releases/download/ios-v0.4.0-unsigned-build-38608702962/UI-E2BAEF62-F190-41B5-93A8-81F3C893625B.png)

## Practical limits

This is an unsigned device build: installation needs valid Apple signing and private release downloads require repository access. Keychain was exercised in the signed simulator; real iPhone microphone, interruptions and recording quality are not established by those tests. Cloud requests were validated using an HTTP stub, without a user-provided service key. No particular Doubao model is asserted to support audio, and synthetic pitch tests do not establish accuracy for complex music.
