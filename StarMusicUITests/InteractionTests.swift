import XCTest

final class InteractionTests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }
    private func launch(_ appearance: String = "dark") -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-appearance", appearance]
        app.launch()
        XCTAssertTrue(app.buttons["home.start"].waitForExistence(timeout: 10))
        XCTAssertEqual(app.tabBars.count, 0, "Use exactly one custom bottom navigation, without a system bar underneath.")
        return app
    }
    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
    }
    func testCreationSheetOpensEditorAndHidesNavigation() {
        let app = launch()
        capture("Home-Dark")
        app.buttons["home.start"].tap()
        XCTAssertTrue(app.buttons["start.blank"].waitForExistence(timeout: 5))
        capture("Creation-Sheet")
        app.buttons["start.blank"].tap()
        XCTAssertTrue(app.buttons["editor.back"].waitForExistence(timeout: 8))
        XCTAssertFalse(app.buttons["tab.community"].exists)
        capture("Score-Editor")
        app.buttons["editor.back"].tap()
        XCTAssertTrue(app.buttons["home.start"].waitForExistence(timeout: 5))
    }
    func testDraftSearchAndGridKeepContentAccessible() {
        let app = launch()
        app.swipeUp()
        app.buttons["home.drafts"].tap()
        XCTAssertTrue(app.buttons["drafts.searchToggle"].waitForExistence(timeout: 5))
        app.buttons["drafts.searchToggle"].tap()
        let field = app.textFields["drafts.searchField"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap(); field.typeText("zzNoMatchingDraftzz")
        XCTAssertTrue(app.staticTexts["没有匹配的旋律"].waitForExistence(timeout: 5))
        app.buttons["drafts.searchToggle"].tap()
        XCTAssertFalse(app.textFields["drafts.searchField"].exists)
        app.buttons["drafts.layout"].tap()
        XCTAssertEqual(app.buttons["drafts.layout"].label, "切换为列表")
        capture("Drafts-Grid")
        app.buttons["drafts.layout"].tap()
        XCTAssertEqual(app.buttons["drafts.layout"].label, "切换为网格")
    }
    func testLightAppearanceAndSettingsToggle() {
        let app = launch("light")
        capture("Home-Light")
        app.buttons["tab.profile"].tap()
        let toggle = app.buttons.matching(identifier: "settings.haptics").firstMatch
        // Toggle's accessibility container may expose as a switch or an ordinary button.
        let control = toggle.exists ? toggle : app.buttons["轻触反馈"]
        XCTAssertTrue(control.waitForExistence(timeout: 5))
        let original = control.value as? String
        control.tap()
        XCTAssertNotEqual(control.value as? String, original)
        control.tap()
        XCTAssertEqual(control.value as? String, original)
        capture("Profile-Light")
    }
    func testTrackChooserModesAndModelConfiguration() {
        let app = launch()
        app.buttons["home.blank"].tap()
        XCTAssertTrue(app.buttons["editor.addTrack"].waitForExistence(timeout: 8))
        app.swipeUp()
        app.buttons["editor.addTrack"].tap()
        XCTAssertTrue(app.buttons["track.addRecording"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["track.addImport"].exists)
        capture("Track-Chooser")
        app.buttons["track.addBlank"].tap()
        XCTAssertTrue(app.buttons["编辑 声音 2 的音符"].waitForExistence(timeout: 5))
        capture("Tracks-Standard")
        app.swipeDown()
        app.buttons["studio.modeMenu"].tap()
        app.buttons["简洁模式"].tap()
        XCTAssertTrue(app.buttons["展开更多工具"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["recognition.engine"].exists)
        capture("Tracks-Simple")
        app.buttons["展开更多工具"].tap()
        XCTAssertTrue(app.buttons["收起更多工具"].exists)
        app.swipeDown()
        app.buttons["studio.modeMenu"].tap()
        app.buttons["专业模式"].tap()
        XCTAssertTrue(app.buttons["recognition.engine"].waitForExistence(timeout: 5))
        capture("Tracks-Professional")
        app.buttons["editor.back"].tap()
        XCTAssertTrue(app.buttons["home.start"].waitForExistence(timeout: 5))
        app.buttons["tab.profile"].tap()
        app.cells.containing(.staticText, identifier: "识谱与我的模型").firstMatch.tap()
        XCTAssertTrue(app.textFields["model.identifier"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "无法保存或读取设备密钥")).firstMatch.exists)
        capture("Model-Settings")
    }

    func testSimpleMelodyAndKeyShiftUsePlainLanguage() {
        let app = launch()
        app.buttons["home.start"].tap(); app.buttons["start.blank"].tap()
        XCTAssertTrue(app.buttons["editor.back"].waitForExistence(timeout: 8))
        app.buttons["studio.modeMenu"].tap(); app.buttons.matching(NSPredicate(format: "label == %@ AND identifier != %@", "普通模式", "studio.modeMenu")).firstMatch.tap()
        XCTAssertTrue(app.otherElements["editor.melody"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "BPM")).firstMatch.exists)
        app.buttons["editor.addNote"].tap()
        app.otherElements["editor.melody"].coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.6)).tap()
        app.buttons["editor.keyShift"].tap()
        XCTAssertTrue(app.buttons["key.higher"].waitForExistence(timeout: 5)); app.buttons["key.higher"].tap()
        XCTAssertTrue(app.staticTexts["比原来高 1 点"].exists)
        capture("Key-Shift-Plain")
        app.buttons["key.preview"].tap(); app.buttons["key.apply"].tap()
        XCTAssertTrue(app.buttons["editor.back"].waitForExistence(timeout: 5))
        app.swipeDown(); app.buttons["studio.modeMenu"].tap(); app.buttons["简洁模式"].tap()
        XCTAssertFalse(app.buttons["recognition.engine"].exists)
        XCTAssertFalse(app.staticTexts["4/4 拍"].exists)
        XCTAssertFalse(app.buttons["editor.addTrack"].exists)
        capture("Melody-Simple")
        app.buttons["展开更多工具"].tap()
        XCTAssertTrue(app.buttons["editor.addTrack"].exists)
        app.swipeDown(); app.buttons["studio.modeMenu"].tap(); app.buttons.matching(NSPredicate(format: "label == %@ AND identifier != %@", "普通模式", "studio.modeMenu")).firstMatch.tap()
        capture("Melody-Standard")
    }

}
