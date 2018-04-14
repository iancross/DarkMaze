//
//  DarkMazeUITests.swift
//  DarkMazeUITests
//
//  Created by crossibc on 4/13/18.
//  Copyright © 2018 crossibc. All rights reserved.
//

import XCTest

class DarkMazeUITests: XCTestCase {
    
    var app: XCUIApplication?
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
        app?.launch()

        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLevelSelect_OpenCloseCell() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let app = XCUIApplication()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.tap()
        
        let cells = app.tables.cells
        cells.element(boundBy: 0).tap()
        cells.element(boundBy:1).tap()
    }
    
    func testLevelSelect_OpenCloseAfterScrolling() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let app = XCUIApplication()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.tap()
        
        let tablesQuery = XCUIApplication().tables
        tablesQuery.cells["Cell 0"].children(matching: .other).element(boundBy: 1).tap()
        
        tablesQuery.cells["Cell 6"].children(matching: .other).element(boundBy: 1).swipeUp()
        
        tablesQuery.cells["Cell 9"].children(matching: .other).element(boundBy: 1).tap()
        tablesQuery.cells["Cell 9"].children(matching: .button).matching(identifier: "skview button").element(boundBy: 0).tap()
    }
    
    func testLevelSelect_CorrectNumberOfLevels() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let app = XCUIApplication()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.tap()
        
        let tablesQuery = XCUIApplication().tables
        
        tablesQuery.cells["Cell 0"].children(matching: .other).element(boundBy: 1).tap()
        let skview = tablesQuery.cells["Cell 0"].children(matching: .button).matching(identifier: "drawing")
        XCTAssertTrue(skview.element(matching: XCUIElement.ElementType.any, identifier: "Level 0").exists)
        //let countElems = skview.element(matching: XCUIElement.ElementType.any, identifier: "Level")
    }
}
