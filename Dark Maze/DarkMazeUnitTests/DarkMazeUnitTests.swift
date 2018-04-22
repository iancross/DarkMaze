//
//  DarkMazeUnitTests.swift
//  DarkMazeUnitTests
//
//  Created by crossibc on 4/16/18.
//  Copyright © 2018 crossibc. All rights reserved.
//

import XCTest
@testable import DarkMaze

class DarkMazeUnitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testEnsureLevelGroupsExist(){
        let groups = LevelsData().levelGroups
        XCTAssertTrue(groups.count > 0)
    }
    
    func testEachGroupHasLevels(){
        let groups = LevelsData().levelGroups
        for (_, level) in groups{
            XCTAssertTrue(level.count > 0)
        }
    }
    
    func testEachLevelHasCoords(){
        let l = LevelsData()
        let groups = l.levelGroups
        for (offset: i, element: (category: cat, levels: levels)) in groups.enumerated(){
            for (j, _) in levels.enumerated(){
                let solutionCoords = l.getSolutionCoords(group: i, level: j)
                XCTAssertFalse(solutionCoords.isEmpty, "group: \(cat)  level \(j + 1)")
            }
        }
    }
    
    func testFirstAndEndCoordsDifferent(){
        let l = LevelsData()
        let groups = l.levelGroups
        for (offset: i, element: (category: cat, levels: levels)) in groups.enumerated(){
            for (j, _) in levels.enumerated(){
                let solutionCoords = l.getSolutionCoords(group: i, level: j)
                XCTAssertFalse(Helper.intTupleIsEqual(solutionCoords.first!, solutionCoords.last!),  "group: \(cat)  level \(j + 1)")
            }
        }
    }
    
    func testNoRepeatedCoords(){
        let l = LevelsData()
        let groups = l.levelGroups
        for (offset: i, element: (category: cat, levels: levels)) in groups.enumerated(){
            for (j, _) in levels.enumerated(){
                let solutionCoords = l.getSolutionCoords(group: i, level: j)
                for i in 0...solutionCoords.count - 2{
                    XCTAssertFalse(Helper.intTupleIsEqual(solutionCoords[i], solutionCoords[i+1]), "group: \(cat)  level \(j + 1)")
                }
            }
        }
    }
    
    func testStartAndEndCoordsOnTheEdge(){
        let l = LevelsData()
        let groups = l.levelGroups
        for (offset: i, element: (category: cat, levels: levels)) in groups.enumerated(){
            for (j, level) in levels.enumerated(){
                let solutionCoords = l.getSolutionCoords(group: i, level: j)
                
                XCTAssertTrue(solutionCoords.first?.x == 0 || solutionCoords.first?.x == level.gridX-1 || solutionCoords.first?.y == 0 || solutionCoords.first?.y == level.gridY-1, "group: \(cat)  level \(j + 1)")
                XCTAssertTrue(solutionCoords.last?.x == 0 || solutionCoords.last?.x == level.gridX-1 || solutionCoords.last?.y == 0 || solutionCoords.last?.y == level.gridY-1, "group: \(cat)  level \(j + 1)")
            }
        }
    }
}
