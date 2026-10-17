import XCTest

final class InteractionTests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }
    private func launch(_ appearance: String = "dark") -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-appearance", appearance, "--ui-test-standard-mode", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        XCTAssertTrue(app.buttons["home.start"].waitForExistence(timeout: 10))
        XCTAssertEqual(app.tabBars.count, 1, "Exactly one native tab bar owns the four sections.")
        for title in ["创作", "社区", "消息", "我的"] { XCTAssertTrue(app.tabBars.buttons[title].exists) }
        return app
    }
    private func capture(_ name: String) {
        // Allow the OS-owned glass/menu transition to finish before recording a static preview.
        Thread.sleep(forTimeInterval: 0.5)
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot()); attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
    }
    private func back(_ app: XCUIApplication) { app.navigationBars.buttons.element(boundBy: 0).tap() }
    private func blank(_ app: XCUIApplication) {
        app.buttons["home.start"].tap(); XCTAssertTrue(app.buttons["start.blank"].waitForExistence(timeout: 5)); app.buttons["start.blank"].tap()
        XCTAssertTrue(app.buttons["studio.modeMenu"].waitForExistence(timeout: 8))
    }
    private func mode(_ title: String, _ app: XCUIApplication) {
        app.buttons["studio.modeMenu"].tap()
        app.buttons.matching(NSPredicate(format: "label == %@ AND identifier != %@", title, "studio.modeMenu")).firstMatch.tap()
    }
    func testCreationSheetOpensEditorAndHidesNavigation() {
        let app = launch(); capture("Home-Dark")
        app.buttons["home.start"].tap(); XCTAssertTrue(app.buttons["start.blank"].waitForExistence(timeout: 5)); capture("Creation-Sheet")
        app.buttons["start.blank"].tap(); XCTAssertTrue(app.buttons["studio.modeMenu"].waitForExistence(timeout: 8))
        XCTAssertFalse(app.tabBars.firstMatch.isHittable); capture("Melody-Editor-Native")
        back(app); XCTAssertTrue(app.buttons["home.start"].waitForExistence(timeout: 5)); XCTAssertTrue(app.tabBars.firstMatch.isHittable)
    }
    func testDraftNativeSearchAndGridKeepContentAccessible() {
        let app = launch(); app.swipeUp(); app.buttons["home.drafts"].tap()
        let field = app.searchFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5)); field.tap(); field.typeText("zzNoMatchingDraftzz")
        XCTAssertTrue(app.staticTexts["没有匹配的旋律"].waitForExistence(timeout: 5)); capture("Drafts-Native-Search")
        field.buttons.firstMatch.tap(); app.buttons["Close"].tap()
        app.buttons["drafts.layout"].tap(); XCTAssertEqual(app.buttons["drafts.layout"].label, "切换为列表"); capture("Drafts-Grid")
        app.buttons["drafts.layout"].tap(); XCTAssertEqual(app.buttons["drafts.layout"].label, "切换为网格")
    }
    func testLightAppearanceAndNativeSettingsToggle() {
        let app = launch("light"); capture("Home-Light"); app.tabBars.buttons["我的"].tap()
        let control = app.switches["settings.haptics"]
        if !control.isHittable { app.swipeUp() }
        XCTAssertTrue(control.waitForExistence(timeout: 5)); let original = control.value as? String
        control.coordinate(withNormalizedOffset: CGVector(dx: 0.94, dy: 0.5)).tap(); XCTAssertNotEqual(control.value as? String, original); control.coordinate(withNormalizedOffset: CGVector(dx: 0.94, dy: 0.5)).tap(); XCTAssertEqual(control.value as? String, original)
        capture("Profile-Light")
    }
    func testTrackChooserModesAndModelConfiguration() {
        let app = launch(); blank(app); app.buttons["editor.toolsMenu"].tap(); app.buttons["editor.addTrack"].tap()
        XCTAssertTrue(app.buttons["track.addRecording"].waitForExistence(timeout: 5)); XCTAssertTrue(app.buttons["track.addImport"].exists); capture("Track-Chooser")
        app.buttons["track.addBlank"].tap(); XCTAssertTrue(app.buttons["编辑 旋律 2 的音符"].waitForExistence(timeout: 5)); capture("Tracks-Standard")
        app.swipeDown(); mode("简洁模式", app)
        XCTAssertTrue(app.buttons["展开更多工具"].waitForExistence(timeout: 5)); XCTAssertFalse(app.buttons["recognition.engine"].exists); capture("Tracks-Simple")
        app.swipeUp() // Reveal the whole control above the native bottom toolbar in the two-track view.
        app.buttons["展开更多工具"].tap(); XCTAssertTrue(app.buttons["收起更多工具"].waitForExistence(timeout: 5)); capture("Tracks-Simple-Tools")
        app.swipeDown(); mode("专业模式", app); XCTAssertTrue(app.buttons["recognition.engine"].waitForExistence(timeout: 5)); capture("Tracks-Professional")
        back(app); XCTAssertTrue(app.buttons["home.start"].waitForExistence(timeout: 5)); app.tabBars.buttons["我的"].tap()
        let modelLink = app.buttons["识谱与我的模型"]; if !modelLink.isHittable { app.swipeUp() }; modelLink.tap()
        XCTAssertTrue(app.textFields["model.identifier"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "无法保存或读取设备密钥")).firstMatch.exists); capture("Model-Settings")
    }
    func testSimpleMelodyAndKeyShiftUsePlainLanguage() {
        let app = launch(); blank(app)
        XCTAssertTrue(app.otherElements["editor.melody"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "BPM")).firstMatch.exists)
        app.buttons["editor.addNote"].tap(); app.otherElements["editor.melody"].coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.6)).tap()
        app.buttons["editor.keyShift"].tap(); XCTAssertTrue(app.buttons["key.higher"].waitForExistence(timeout: 5)); app.buttons["key.higher"].tap()
        XCTAssertTrue(app.staticTexts["比原来高 1 点"].exists); capture("Key-Shift-Plain")
        app.buttons["key.preview"].tap(); app.buttons["key.apply"].tap(); XCTAssertTrue(app.buttons["studio.modeMenu"].waitForExistence(timeout: 5))
        app.swipeDown(); mode("简洁模式", app)
        XCTAssertFalse(app.buttons["recognition.engine"].exists); XCTAssertFalse(app.staticTexts["4/4 拍"].exists); XCTAssertFalse(app.buttons["editor.addTrack"].exists); capture("Melody-Simple")
        app.buttons["展开更多工具"].tap(); app.buttons["editor.toolsMenu"].tap(); XCTAssertTrue(app.buttons["editor.addTrack"].exists); app.coordinate(withNormalizedOffset: CGVector(dx: 0.03, dy: 0.3)).tap()
        app.swipeDown(); mode("普通模式", app); XCTAssertTrue(app.otherElements["editor.melody"].waitForExistence(timeout: 5)); capture("Melody-Standard")
    }
    func testNativeTabHistoryAndEdgeSwipeBack() {
        let app = launch(); app.swipeUp(); app.buttons["home.drafts"].tap(); XCTAssertTrue(app.searchFields.firstMatch.waitForExistence(timeout: 5))
        app.tabBars.buttons["消息"].tap(); XCTAssertTrue(app.staticTexts["暂无在线消息"].waitForExistence(timeout: 5)); capture("Messages-Native")
        app.tabBars.buttons["创作"].tap(); XCTAssertTrue(app.searchFields.firstMatch.exists, "Native tabs retain each section's navigation history.")
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.005, dy: 0.5))
        start.press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.85, dy: 0.5)))
        XCTAssertTrue(app.buttons["home.start"].waitForExistence(timeout: 5)); app.swipeDown(); blank(app)
        start.press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.85, dy: 0.5)))
        XCTAssertTrue(app.buttons["home.start"].waitForExistence(timeout: 5))
    }
    func testNativeSheetsDismissAndRecordingCancel() {
        let app = launch(); app.buttons["home.start"].tap(); XCTAssertTrue(app.buttons["start.blank"].waitForExistence(timeout: 5))
        app.buttons["取消"].tap(); XCTAssertTrue(app.buttons["home.start"].isHittable)
        app.buttons["home.start"].tap(); app.buttons["start.record"].tap()
        XCTAssertTrue(app.buttons["recording.start"].waitForExistence(timeout: 8)); XCTAssertFalse(app.tabBars.firstMatch.isHittable); capture("Recording-Preparation")
        app.buttons["recording.cancel"].tap(); XCTAssertTrue(app.buttons["home.start"].waitForExistence(timeout: 5))
    }
    func testCoordinateFreeNoteEntryAndProfessionalScore() {
        let app = launch(); blank(app); app.buttons["editor.toolsMenu"].tap()
        app.buttons["editor.noteEntry"].tap()
        XCTAssertTrue(app.buttons["noteEntry.add"].waitForExistence(timeout: 5)); capture("Accessible-Note-Entry")
        app.buttons["noteEntry.add"].tap()
        XCTAssertTrue(app.buttons["studio.modeMenu"].waitForExistence(timeout: 5))
        app.buttons.matching(NSPredicate(format: "label == %@", "旋律片段，可编辑")).firstMatch.tap()
        XCTAssertTrue(app.navigationBars["调整这个片段"].waitForExistence(timeout: 5)); capture("Note-Correction-Sheet")
        app.buttons["完成"].tap(); app.swipeDown(); mode("专业模式", app)
        XCTAssertTrue(app.staticTexts["4/4 拍"].waitForExistence(timeout: 5)); capture("Score-Native-Professional")
    }
    func testCommunityNativeDetailAndComments() {
        let app = launch(); app.tabBars.buttons["社区"].tap()
        app.buttons.containing(.staticText, identifier: "晚风经过的地方").firstMatch.tap()
        XCTAssertTrue(app.navigationBars["作品详情"].waitForExistence(timeout: 5)); capture("Community-Detail")
        app.buttons["演示评论"].tap(); XCTAssertTrue(app.navigationBars["演示评论"].waitForExistence(timeout: 5)); capture("Comments-Sheet")
        app.buttons["完成"].tap(); back(app); XCTAssertTrue(app.navigationBars["社区"].waitForExistence(timeout: 5))
    }
    func testDenseScoreFontPaginationAndBottomControlsRemainSeparate() {
        let app = XCUIApplication()
        app.launchArguments = ["-appearance", "light", "--ui-test-standard-mode", "--ui-test-dense-score", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        let draft = app.buttons.containing(.staticText, identifier: "密集谱面回归").firstMatch
        XCTAssertTrue(draft.waitForExistence(timeout: 10)); draft.tap(); mode("专业模式", app)
        XCTAssertTrue(app.otherElements["editor.score"].waitForExistence(timeout: 8)); capture("Dense-Score-Light")
        let next = app.buttons["score.next"]; if !next.isHittable { app.swipeUp() }; XCTAssertTrue(next.isHittable); next.tap()
        XCTAssertTrue(app.staticTexts["参考谱 · 2 / 2"].waitForExistence(timeout: 5)); capture("Dense-Score-Next-Page")
        app.swipeUp()
        let tools = app.buttons["editor.toolsMenu"], key = app.buttons["editor.keyShift"]
        XCTAssertTrue(tools.isHittable); XCTAssertTrue(key.isHittable)
        XCTAssertLessThanOrEqual(tools.frame.maxY, key.frame.minY + 1, "Scrollable editing tools must stop above the pinned transport.")
        capture("Editor-Bottom-No-Overlap")
        XCUIDevice.shared.orientation = .landscapeLeft
        XCTAssertTrue(key.waitForExistence(timeout: 5)); capture("Dense-Score-Landscape")
        XCUIDevice.shared.orientation = .portrait
    }
    func testLargeTypeEditorKeepsExplicitToolsAndPlaybackReachable() {
        let app = XCUIApplication()
        app.launchArguments = ["-appearance", "dark", "--ui-test-standard-mode", "--ui-test-large-type", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch(); XCTAssertTrue(app.buttons["home.start"].waitForExistence(timeout: 10)); blank(app)
        app.swipeUp()
        XCTAssertTrue(app.buttons["editor.keyShift"].isHittable)
        XCTAssertTrue(app.buttons["editor.toolsMenu"].exists)
        capture("Editor-Accessibility-Large-Type")
        back(app)
    }
    func testFreeHummingScoreKeepsClearPitchOnlyMarksAndEditableNotes() {
        let app = XCUIApplication()
        app.launchArguments = ["-appearance", "light", "--ui-test-standard-mode", "--ui-test-dense-score", "--ui-test-free-score", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        let draft = app.buttons.containing(.staticText, identifier: "密集谱面回归").firstMatch
        XCTAssertTrue(draft.waitForExistence(timeout: 10)); draft.tap(); mode("专业模式", app)
        XCTAssertTrue(app.otherElements["editor.score"].waitForExistence(timeout: 5)); capture("Free-Humming-Score-Light")
        let note = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "F3，")).firstMatch
        if !note.isHittable { app.swipeUp() }
        XCTAssertTrue(note.isHittable); note.tap()
        XCTAssertTrue(app.navigationBars["音符校正"].waitForExistence(timeout: 5)); capture("Free-Score-Note-Correction")
        app.buttons["完成"].tap()
    }

    func testNumberedNotationEditsSameNotesAndExportsPDF() {
        let app = XCUIApplication()
        app.launchArguments = ["-appearance", "light", "--ui-test-standard-mode", "--ui-test-dense-score", "--ui-test-free-score", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        let draft = app.buttons.containing(.staticText, identifier: "密集谱面回归").firstMatch
        XCTAssertTrue(draft.waitForExistence(timeout: 10)); draft.tap()
        app.buttons["editor.projectMenu"].tap(); app.buttons["editor.notationMenu"].tap(); app.buttons["notation.numbered"].tap()
        XCTAssertTrue(app.otherElements["editor.numberedScore"].waitForExistence(timeout: 5)); capture("Numbered-Score-Light")
        let note = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@ AND label BEGINSWITH %@", "numbered.note.", "F3，")).firstMatch
        XCTAssertTrue(note.isHittable)
        let id = note.identifier, original = note.label
        note.tap(); XCTAssertTrue(app.navigationBars["调整这个片段"].waitForExistence(timeout: 5))
        app.buttons["高一点"].tap(); app.buttons["完成"].tap()
        XCTAssertNotEqual(app.buttons[id].label, original)
        // XCTest can call a clipped control below safeAreaInset hittable.
        // Scroll as a user would, then verify its entire frame clears transport.
        app.swipeUp()
        let add = app.buttons["editor.addNote"], transport = app.buttons["editor.keyShift"]
        for _ in 0..<3 where add.frame.maxY > transport.frame.minY { app.swipeUp() }
        XCTAssertTrue(add.isHittable)
        XCTAssertLessThanOrEqual(add.frame.maxY, transport.frame.minY + 1)
        add.tap()
        XCTAssertTrue(app.navigationBars["添加一个声音"].waitForExistence(timeout: 5))
        app.buttons["noteEntry.add"].tap()
        XCTAssertTrue(app.otherElements["editor.numberedScore"].waitForExistence(timeout: 5))
        app.buttons["保存与分享"].tap(); app.buttons["简谱 PDF"].tap()
        XCTAssertTrue(app.otherElements["system.shareSheet"].waitForExistence(timeout: 15)); capture("Numbered-PDF-Native-Share")
    }

}
