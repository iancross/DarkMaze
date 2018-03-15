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
        nextLevelToComplete = 4
        
        //used by the gameplay if you play an earlier level
        currentLevel = 0
        levels = [LevelData]()
        
        //levels info
        //gridsize - self explanatory
        //blockbuffer - how many blockwidths are on either side of the grid (prob won't work when we start panning
        //
        //
        //levelCompleted: shows us what to color the level in level select
        
        //level 1
        levels.append (LevelData(
            gridSizeX: 4,
            gridSizeY: 4,
            blockBuffer: 3,
            delayTime: 0.5,
            solutionCoords:
                [(0,1),(0,2),(0,3),(1,3),(2,3),(3,3)],
            levelCompleted: false
        ))
        //level 2
        levels.append (LevelData(
            gridSizeX: 4,
            gridSizeY: 4,
            blockBuffer: 3,
            delayTime: 0.5,
            solutionCoords:
                [(0,2),(0,3),(1,3),(2,3),(2,2),(2,1),(2,0),(3,0)],
            levelCompleted: false
        ))
        
        //level 3
        levels.append (LevelData(
            gridSizeX: 4,
            gridSizeY: 4,
            blockBuffer: 3,
            delayTime: 0.5,
            solutionCoords:
                [(0,0),(1,0),(1,1),(1,2),(2,2),(3,2),(3,1),(3,0)],
            levelCompleted: false
        ))
        
        //level 4
        levels.append (LevelData(
            gridSizeX: 5,
            gridSizeY: 5,
            blockBuffer: 3,
            delayTime: 0.5,
            solutionCoords:
            [(0,1),(0,0),(1,0),(2,0),(3,0),(3,1),(4,1),(4,2),(4,3)],
            levelCompleted: false
        ))
        
        //level 5
        levels.append (LevelData(
            gridSizeX: 5,
            gridSizeY: 5,
            blockBuffer: 3,
            delayTime: 0.5,
            solutionCoords:
            [(0,1),(1,1),(1,2),(2,2),(3,2),(3,1),(3,0),(4,0)],
            levelCompleted: false
        ))
        
        //level 6
        levels.append (LevelData(
            gridSizeX: 5,
            gridSizeY: 5,
            blockBuffer: 3,
            delayTime: 0.5,
            solutionCoords:
            [(0,4),(1,4),(1,3),(2,3),(2,2),(3,2),(3,1),(3,0),(4,0)],
            levelCompleted: false
        ))
    }
}
struct LevelData {
    var gridSizeX: Int
    var gridSizeY: Int
    var blockBuffer: Int
    var delayTime: Double
    var solutionCoords: [(x: Int,y: Int)]
    var levelCompleted: Bool
}

