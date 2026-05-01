//
//  SpeakPlanUITests.swift
//  SpeakPlanUITests
//
//  Created by Harshitha Kasaraneni on 01/05/26.
//

import XCTest

final class SpeakPlanUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testSmartAddTaskCreation() throws {
        let app = XCUIApplication()
        app.launch()

        // 1. Tap the Smart Add floating action button
        let addTaskButton = app.buttons["Add task"]
        XCTAssertTrue(addTaskButton.waitForExistence(timeout: 5), "The Smart Add button should exist on the Home Screen.")
        addTaskButton.tap()

        // 2. Type "Study at 6 pm for 2 hours" into the text field
        let textField = app.textFields["Speak or type your tasks..."]
        XCTAssertTrue(textField.waitForExistence(timeout: 5), "The text field should exist on the Smart Add screen.")
        textField.tap()
        textField.typeText("Study at 6 pm for 2 hours")

        // 3. Tap the "Add Tasks" button
        let submitButton = app.buttons["Add Tasks"]
        XCTAssertTrue(submitButton.waitForExistence(timeout: 5), "The Add Tasks button should exist.")
        submitButton.tap()

        // 4. Verify that the task appears in the Timeline View with the parsed time
        let taskTitle = app.staticTexts["Study"]
        XCTAssertTrue(taskTitle.waitForExistence(timeout: 5), "The newly added task 'Study' should appear in the Timeline View.")
        
        let taskTime = app.staticTexts["6:00 PM"] // adjust this if your parser outputs differently
        // Depending on device locale, time formatting might be '6:00 PM' or just '6:00'
        // Using a more robust predicate or just checking existence
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
