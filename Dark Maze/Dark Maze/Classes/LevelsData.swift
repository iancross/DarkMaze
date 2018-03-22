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
    var levels: [(String,[LevelData])]
    var nextLevelToComplete: Int  //the highest level that has been completed
    init(){
        
        currentLevelSuccess = false
        
        //this determines which level is either currently being worked on or the next level
        //it will always be incomplete in the level select
        nextLevelToComplete = 2 // the actual level is nextLevel + 1
        
        //used by the gameplay if you play an earlier level
        currentLevel = 0
        
        levels = [(category: String,[LevelData])]()
        _4x4()
        _5x5()
    }
    
    /*------------------------------- 4x4 -------------------------------*/
    //Description:
    //Easiest level to show how to play the game. Probably going to do all sorts of
    //directions to show the maze functionality
    func _4x4(){
        var array = [
        LevelData(
            gridX: 4, gridY: 4, delayTime: 0.5,
            solutionCoords:
            [(0,1),(0,2),(0,3),(1,3),(2,3),(3,3)],
            levelCompleted: false
        ),
        LevelData(
            gridX: 4, gridY: 4, delayTime: 0.5,
            solutionCoords:
            [(0,2),(1,2),(1,3)],
            levelCompleted: false
        ),
        LevelData(
            gridX: 4, gridY: 4, delayTime: 0.5,
            solutionCoords:
            [(0,3),(1,3),(1,2),(1,1),(1,0)],
            levelCompleted: false
        ),
        LevelData(
            gridX: 4, gridY: 4, delayTime: 0.5,
            solutionCoords:
            [(2,3),(2,2),(1,2),(1,1),(1,0),(2,0)],
            levelCompleted: false
        ),
        LevelData(
            gridX: 4, gridY: 4, delayTime: 0.5,
            solutionCoords:
            [(0,3),(1,3),(1,2),(2,2),(2,1),(3,1),(3,0)],
            levelCompleted: false
        ),
        LevelData(
            gridX: 4, gridY: 4, delayTime: 0.5,
            solutionCoords:
            [(3,3),(3,2),(2,2),(2,1),(2,0),(1,0),(0,0),(0,1),(0,2)],
            levelCompleted: false
        )]
        levels.append ((category: "4x4", array))
    }
    func _5x5(){
        var array = [LevelData(
            gridX: 5, gridY: 5, delayTime: 0.5,
            solutionCoords:
            [(0,4),(1,4),(1,3),(2,3),(2,2),(3,2),(3,1),(3,0),(4,0)],
            levelCompleted: false
        ),
        LevelData(
            gridX: 5, gridY: 5, delayTime: 0.5,
            solutionCoords:
            [(0,2),(0,1),(1,1),(1,2),(1,3),(0,3),(0,4),(1,4),(2,4),(3,4),(4,4)],
            levelCompleted: false
        ),
        LevelData(
            gridX: 5, gridY: 5, delayTime: 0.5,
            solutionCoords:
            [(3,4),(3,3),(2,3),(1,3),(0,3),(0,2),(1,2),(2,2),(3,2),(3,1),(2,1),(1,1),(1,0)],
            levelCompleted: false
        ),
        //there's a bug on this level - if an available square is in the solution coords
        // you can still tap on it regardless of whether it's next or not
        LevelData(
            gridX: 5, gridY: 5, delayTime: 0.5,
            solutionCoords:
            [(4,4),(3,4),(2,4),(1,4),(0,4),(0,3),(0,2),(0,1),(0,0),(1,0),(2,0),(3,0),(4,0)],
            levelCompleted: false
        )]
    }
}

//levels info
//gridsize - self explanatory
//delayTime - time between tiles showing up (0 means they all show up at the same time)
//levelCompleted: shows us what to color the level in level select

struct LevelData {
    var gridX: Int
    var gridY: Int
    var delayTime: Double
    var solutionCoords: [(x: Int,y: Int)]
    var levelCompleted: Bool
}


//---------left off here
/*levels.append (LevelData(
 gridX: 6, gridY: 10, delayTime: 0.5,
 solutionCoords:
 [(0,7),(1,7),(1,8),(1,9),(2,9),(3,9),(3,8),(4,8),(4,7),(4,6),(5,6),(5,5),(5,4),(4,4),(3,4),(2,4),(1,4),(1,3),(2,3),(2,2),(3,2),(4,2),(4,1),(5,1)],
 levelCompleted: false
 ))
 
 levels.append (LevelData(
 gridX: 6, gridY: 10, delayTime: 0.01,
 solutionCoords:
 [(0,7),(1,7),(2,7),(3,7),(4,7),(4,6),(4,5),(4,4),(4,3),(4,2),(4,1),(4,0)],
 levelCompleted: false
 ))
 
 levels.append (LevelData(
 gridX: 5, gridY: 5, delayTime: 0.5,
 solutionCoords:
 [(0,4),(1,4),(1,3),(2,3),(2,2),(3,2),(3,1),(3,0),(4,0)],
 levelCompleted: false
 ))
 
 levels.append (LevelData(
 gridX: 5, gridY: 5, delayTime: 0.5,
 solutionCoords:
 [(0,4),(1,4),(1,3),(2,3),(2,2),(3,2),(3,1),(3,0),(4,0)],
 levelCompleted: false
 ))*/

