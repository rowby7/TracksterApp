//
//  ScreenshotTests.swift
//  TracksterUITests
//
//  Not a real test: taps through the app with sample data and saves screenshots.
//  The images land in the test results as attachments.
//

import XCTest

final class ScreenshotTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    @MainActor
    func testHistoryAndDetailScreenshots() throws {
        let app = launchWithMockData()

        XCTAssertTrue(app.staticTexts["Run History"].waitForExistence(timeout: 15))
        sleep(20)                                 // let the route snapshots render
        snap("1-History")

        app.swipeUp()
        sleep(15)
        snap("2-History-Scrolled")
        app.swipeDown()
        sleep(2)

        let firstCard = app.scrollViews.firstMatch.buttons.firstMatch
        XCTAssertTrue(firstCard.waitForExistence(timeout: 5))
        firstCard.tap()
        usleep(1_500_000)
        snap("3-Detail-Drawing")                  // mid-animation, route half drawn
        sleep(5)
        snap("4-Detail")
    }

    @MainActor
    func testRecordScreenshots() throws {
        let app = launchWithMockData()

        app.tabBars.buttons["Start"].tap()
        allowLocationIfAsked()

        let mainButton = app.buttons["mainRunButton"]
        XCTAssertTrue(mainButton.waitForExistence(timeout: 10))
        sleep(2)
        snap("5-Record-AcquiringGPS")

        // The simulator's fake location makes GPS "ready", which unlocks Start
        let enabled = NSPredicate(format: "isEnabled == true")
        expectation(for: enabled, evaluatedWith: mainButton)
        waitForExpectations(timeout: 30)
        sleep(3)
        snap("6-Record-Ready")

        mainButton.tap()
        sleep(1)
        snap("7-Countdown")

        sleep(25)                                 // run a little so distance and the line show up
        snap("8-LiveRun")
    }

    // MARK: - Helpers

    private func launchWithMockData() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-mockData"]
        app.launch()
        return app
    }

    private func snap(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func allowLocationIfAsked() {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let allow = springboard.alerts.buttons["Allow While Using App"]
        if allow.waitForExistence(timeout: 4) {
            allow.tap()
        }
    }
}
