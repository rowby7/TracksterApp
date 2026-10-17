//
//  TracksterUITests.swift
//  TracksterUITests
//
//  Created by Rowby Villanueva on 9/10/26.
//

import XCTest

final class TracksterUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        app = XCUIApplication()
        app.launch()
    }

    // MARK: - History

    @MainActor
    func testHistoryTabShowsTitle() {
        app.tabBars.buttons["History"].tap()

        XCTAssertTrue(app.staticTexts["Run History"].waitForExistence(timeout: 5))
    }

    // MARK: - Record

    @MainActor
    func testRecordTabShowsStartButton() {
        app.tabBars.buttons["Start"].tap()
        allowLocationIfAsked()

        let mainButton = app.buttons["mainRunButton"]
        XCTAssertTrue(mainButton.waitForExistence(timeout: 5))
        XCTAssertEqual(mainButton.label, "Start")
    }

    // MARK: - Helpers

    /// The location prompt belongs to iOS, not the app, so it has to be tapped through Springboard
    private func allowLocationIfAsked() {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let allow = springboard.alerts.buttons["Allow While Using App"]
        if allow.waitForExistence(timeout: 3) {
            allow.tap()
        }
    }
}
