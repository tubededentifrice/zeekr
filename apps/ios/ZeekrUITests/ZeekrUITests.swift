import XCTest

@MainActor
final class ZeekrUITests: XCTestCase {
    private func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        return app
    }

    private func enableDemo(_ app: XCUIApplication) {
        app.buttons["setup"].tap()
        XCTAssertTrue(app.switches["demoToggle"].waitForExistence(timeout: 5))
        app.switches["demoToggle"].tap()
        app.buttons["Done"].tap()
    }

    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testLiveControlHasNoSendButton() {
        let app = launch()
        capture("Vehicle")
        app.buttons["unlock"].tap()
        XCTAssertTrue(app.staticTexts["blockedReason"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["runDemo"].exists)
        capture("Live control blocked")
    }

    func testBlockedControlCanOpenDemoSettings() {
        let app = launch()
        app.buttons["unlock"].tap()
        let settings = app.buttons["Demo settings"]
        XCTAssertTrue(settings.waitForExistence(timeout: 5))
        if !settings.isHittable { app.swipeUp() }
        settings.tap()
        XCTAssertTrue(app.switches["demoToggle"].waitForExistence(timeout: 5))
        app.switches["demoToggle"].tap()
        app.buttons["Done"].tap()
        app.buttons["unlock"].tap()
        XCTAssertTrue(app.buttons["runDemo"].waitForExistence(timeout: 5))
    }

    func testDemoUnlockAndActivity() {
        let app = launch()
        enableDemo(app)
        app.buttons["unlock"].tap()
        app.buttons["runDemo"].tap()
        let state = app.staticTexts["detailLockState"]
        let observed = NSPredicate(format: "label == %@", "Unlocked in demo")
        expectation(for: observed, evaluatedWith: state)
        waitForExpectations(timeout: 8)
        capture("Demo unlock")
        app.buttons["Done"].tap()
        app.tabBars.buttons["Activity"].tap()
        XCTAssertTrue(app.staticTexts["State observed"].waitForExistence(timeout: 5))
        capture("Activity")
    }

    func testCatalogSearchExplainsUnresolvedAC() {
        let app = launch()
        app.tabBars.buttons["Controls"].tap()
        capture("Controls")
        let search = app.searchFields.firstMatch
        if !search.isHittable { app.swipeDown() }
        search.tap()
        search.typeText("Start AC")
        app.buttons["control-acStart"].tap()
        XCTAssertTrue(app.staticTexts["blockedReason"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["runDemo"].exists)
        capture("Climate limit")
    }

    func testProximityDemoAndLoss() {
        let app = launch()
        enableDemo(app)
        app.tabBars.buttons["Proximity"].tap()
        capture("Proximity")
        let arm = app.buttons["armProximity"]
        XCTAssertTrue(arm.waitForExistence(timeout: 5))
        if !arm.isHittable { app.swipeUp() }
        arm.tap()
        app.buttons["Signal lost"].tap()
        XCTAssertEqual(app.staticTexts["proximityState"].label, "State unconfirmed")
        capture("Proximity signal lost")
    }

    func testDemoDoesNotSurviveRelaunch() {
        let app = launch()
        enableDemo(app)
        app.terminate()
        app.launch()
        XCTAssertEqual(app.staticTexts["lockState"].label, "State unknown")
    }
}
