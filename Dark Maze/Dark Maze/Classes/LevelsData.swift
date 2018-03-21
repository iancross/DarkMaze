//
//  Level1LevelsData.swift
//  Dark Maze
//
//  Created by crossibc on 12/24/17.
//  Copyright © 2017 crossibc. All rights reserved.
//

import Foundation

class LevelsData{
    static let shared = LevelsData()
    
    var currentLevelSuccess: Bool
    var currentLevel: Int  //level that was selected in levelselect or by hitting next level
    var levels: [LevelData]
    var nextLevelToComplete: Int  //the highest level that has been completed
    init(){
        
        currentLevelSuccess = false
        
        //this determines which level is either currently being worked on or the next level
        //it will always be incomplete in the level select
        nextLevelToComplete = 9 // the actual level is nextLevel + 1
        
        //used by the gameplay if you play an earlier level
        currentLevel = 0
        levels = [LevelData]()
        
        //levels info
        //gridsize - self explanatory
        //blockbuffer - how many blockwidths are on either side of the grid (prob won't work when we start panning
        //
        //
        //levelCompleted: shows us what to color the level in level select
        
        
        /*------------------------------- 4x4 -------------------------------*/
        levels.append (LevelData(
            gridX: 4, gridY: 4, blockBuffer: 2, delayTime: 0.5,
            solutionCoords:
            [(0,1),(0,2),(0,3),(1,3),(2,3),(3,3)],
            levelCompleted: false, category: "4x4"
        ))
        levels.append (LevelData(
            gridX: 4, gridY: 4, blockBuffer: 2, delayTime: 0.5,
            solutionCoords:
            [(0,2),(0,3),(1,3),(2,3),(2,2),(2,1),(2,0),(3,0)],
            levelCompleted: false, category: nil
        ))
        levels.append (LevelData(
            gridX: 4, gridY: 4, blockBuffer: 2, delayTime: 0.5,
            solutionCoords:
            [(0,0),(1,0),(1,1),(1,2),(2,2),(3,2),(3,1),(3,0)],
            levelCompleted: false, category: nil
        ))
        
        /*------------------------------- 5x5 -------------------------------*/
        levels.append (LevelData(
            gridX: 5, gridY: 5, blockBuffer: 2, delayTime: 0.5,
            solutionCoords:
            [(0,1),(1,1),(1,0)],
            levelCompleted: false, category: "5x5"
        ))
        levels.append (LevelData(
            gridX: 5, gridY: 5, blockBuffer: 2, delayTime: 0.5,
            solutionCoords:
            [(0,3),(1,3),(1,4)],
            levelCompleted: false, category: nil
        ))
        levels.append (LevelData(
            gridX: 5, gridY: 5, blockBuffer: 2, delayTime: 0.5,
            solutionCoords:
            [(0,4),(1,4),(1,3),(2,3),(2,2),(3,2),(3,1),(3,0),(4,0)],
            levelCompleted: false, category: nil
        ))
        
        levels.append (LevelData(
            gridX: 5, gridY: 5, blockBuffer: 2, delayTime: 0.5,
            solutionCoords:
                [(0,4),(1,4),(1,3),(2,3),(2,2),(3,2),(3,1),(3,0),(4,0)],
            levelCompleted: false, category: "Big Boys"
        ))
        levels.append (LevelData(
            gridX: 6, gridY: 10, blockBuffer: 2, delayTime: 0.5,
            solutionCoords:
                [(0,7),(1,7),(1,8),(1,9),(2,9),(3,9),(3,8),(4,8),(4,7),(4,6),(5,6),(5,5),(5,4),(4,4),(3,4),(2,4),(1,4),(1,3),(2,3),(2,2),(3,2),(4,2),(4,1),(5,1)],
            levelCompleted: false, category: nil
        ))
        
        levels.append (LevelData(
            gridX: 6, gridY: 10, blockBuffer: 2, delayTime: 0.01,
            solutionCoords:
            [(0,7),(1,7),(2,7),(3,7),(4,7),(4,6),(4,5),(4,4),(4,3),(4,2),(4,1),(4,0)],
            levelCompleted: false, category: nil
        ))
        
        levels.append (LevelData(
            gridX: 5, gridY: 5, blockBuffer: 2, delayTime: 0.5,
            solutionCoords:
                [(0,4),(1,4),(1,3),(2,3),(2,2),(3,2),(3,1),(3,0),(4,0)],
            levelCompleted: false, category: nil
        ))
        
        levels.append (LevelData(
            gridX: 5, gridY: 5, blockBuffer: 2, delayTime: 0.5,
            solutionCoords:
                [(0,4),(1,4),(1,3),(2,3),(2,2),(3,2),(3,1),(3,0),(4,0)],
            levelCompleted: false, category: nil
        ))
    }
}

struct LevelData {
    var gridX: Int
    var gridY: Int
    var blockBuffer: Int
    var delayTime: Double
    var solutionCoords: [(x: Int,y: Int)]
    var levelCompleted: Bool
    var category: String?
}

