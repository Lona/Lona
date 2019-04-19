//
//  iOSUITests.swift
//  iOSUITests
//
//  Created by Devin Abbott on 4/19/19.
//  Copyright © 2019 Lona. All rights reserved.
//

import XCTest
import EyesImages

func cropImage(imageToCrop: UIImage, toRect rect:CGRect) -> UIImage {
    let imageRef: CGImage = imageToCrop.cgImage!.cropping(to: rect)!
    let cropped: UIImage = UIImage(cgImage: imageRef)
    return cropped
}

func env(contents: String, property: String) -> String? {
    guard let re = try? NSRegularExpression(pattern: #"^\#(property)=(.*)$"#) else { return nil }

    let contentsRange = NSRange(location: 0, length: contents.count)

    guard let range = re.firstMatch(in: contents, range: contentsRange)?.range(at: 1) else { return nil }

    return (contents as NSString).substring(with: range) as String
}

class iOSUITests: XCTestCase {

    // Put setup code here. This method is called before the invocation of each test method in the class.
    override func setUp() {

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
    }

    // Put teardown code here. This method is called after the invocation of each test method in the class.
    override func tearDown() {}

    func testExample() {
        let bundle = Bundle(for: iOSUITests.self)

        guard let url = bundle.url(forResource: "test", withExtension: ".env") else {
            XCTAssert(false, "No test.env file")
            return
        }

        guard let contents = try? String(contentsOf: url) else {
            XCTAssert(false, "Couldn't read test.env file")
            return
        }

        guard let applitoolsAPIKey = env(contents: contents, property: "APPLITOOLS_API_KEY") else {
            XCTAssert(false, "No API key")
            return
        }

        let eyes = Eyes()

        eyes.apiKey = applitoolsAPIKey

        // Start the test
        eyes.open(withApplicationName: "LonaViewer", testName: "iOS screenshots")

        defer { eyes.abortIfNotClosed() }

        for cell in XCUIApplication().tables.cells.allElementsBoundByIndex {
            let label = cell.staticTexts.firstMatch.label

            cell.tap()

            // The navigation bar will have the same label as the table cell, so we wait until this exists
            let exists = XCUIApplication().navigationBars.matching(identifier: label).firstMatch
                .waitForExistence(timeout: 0.5)

            XCTAssert(exists, "Element doesn't exist")

            let screenshotImage = XCUIApplication().windows.firstMatch.screenshot().image

            // Crop out the time in the navbar, which will be recognized as a diff.
            // The simulator doesn't provide a way to simulate time.
            let croppingRect = CGRect(
                x: 0,
                y: 90,
                width: screenshotImage.size.width * screenshotImage.scale,
                height: screenshotImage.size.height * screenshotImage.scale - 90)

            let croppedImage = cropImage(imageToCrop: screenshotImage, toRect: croppingRect)

            eyes.check(withTag: label, andSettings: Target.image(croppedImage))

            XCUIApplication().navigationBars.buttons.firstMatch.tap()
        }

        do {
            try eyes.close()
        } catch {
            XCTAssert(false, "Failed to close eyes")
        }
    }
}
