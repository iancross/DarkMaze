//
//  Level1LevelsData.swift
//  Dark Maze
//
//  Created by crossibc on 12/24/17.
//  Copyright © 2017 crossibc. All rights reserved.
//

import Foundation

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
    var modifications: [GridModification]?
}

enum GridModification {
    case flip
}

class LevelsData{
    static let shared = LevelsData()
    
    var currentLevelSuccess: Bool
    var currentPage: Int  //page that contains the next level to be completed
    var selectedLevel: (page: Int, level: Int)
    var levelGroup = [(category: String, levels: [LevelData])]()
    init(){
        
        currentLevelSuccess = false
        
        //used by the gameplay if you play an earlier level
        selectedLevel = (page: 0, level: 0)
        currentPage = 0
        
        //levelGroup = [(category: String, levels: [LevelData])]()
        _4x4()
        _5x5()
        _6x10Flip()
    }
    
//    init (modifications: [GridModification]?){
//        
//    }
    
    func nextLevel(){
        currentPage = selectedLevel.page
        if selectedLevel.level < levelGroup[currentPage].levels.count - 1{
            selectedLevel.level += 1
        }
        else if currentPage < levelGroup.count - 1 {
            currentPage += 1
            selectedLevel.level = 0
            selectedLevel.page = currentPage
        }
        else{
            // do nothing
        }
    }
    /*------------------------------- 4x4 -------------------------------*/
    //Description:
    //Easiest level to show how to play the game. Probably going to do all sorts of
    //directions to show the maze functionality
    func _4x4(){
        let array = [
        LevelData(
            gridX: 4, gridY: 4, delayTime: 0.5,
            solutionCoords:
            [(0,1),(0,2),(0,3),(1,3),(2,3),(3,3)],
            levelCompleted: false, modifications: nil
        ),
        LevelData(
            gridX: 4, gridY: 4, delayTime: 0.5,
            solutionCoords:
            [(0,2),(1,2),(1,3)],
            levelCompleted: false, modifications: nil
        ),
        LevelData(
            gridX: 4, gridY: 4, delayTime: 0.5,
            solutionCoords:
            [(0,3),(1,3),(1,2),(1,1),(1,0)],
            levelCompleted: false, modifications: nil
        ),
        LevelData(
            gridX: 4, gridY: 4, delayTime: 0.5,
            solutionCoords:
            [(2,3),(2,2),(1,2),(1,1),(1,0),(2,0)],
            levelCompleted: false, modifications: nil
        ),
        LevelData(
            gridX: 4, gridY: 4, delayTime: 0.5,
            solutionCoords:
            [(0,3),(1,3),(1,2),(2,2),(2,1),(3,1),(3,0)],
            levelCompleted: false, modifications: nil
        ),
        LevelData(
            gridX: 4, gridY: 4, delayTime: 0.5,
            solutionCoords:
            [(3,3),(3,2),(2,2),(2,1),(2,0),(1,0),(0,0),(0,1),(0,2)],
            levelCompleted: false, modifications: nil
        )]
        levelGroup.append ((category: "4x4", array))
    }
    func _5x5(){
        let array = [LevelData(
            gridX: 5, gridY: 5, delayTime: 0.5,
            solutionCoords:
            [(0,4),(1,4),(1,3),(2,3),(2,2),(3,2),(3,1),(3,0),(4,0)],
            levelCompleted: false, modifications: nil
        ),
        LevelData(
            gridX: 5, gridY: 5, delayTime: 0.5,
            solutionCoords:
            [(0,2),(0,1),(1,1),(1,2),(1,3),(0,3),(0,4),(1,4),(2,4),(3,4),(4,4)],
            levelCompleted: false, modifications: nil
        ),
        LevelData(
            gridX: 5, gridY: 5, delayTime: 0.5,
            solutionCoords:
            [(3,4),(3,3),(2,3),(1,3),(0,3),(0,2),(1,2),(2,2),(3,2),(3,1),(2,1),(1,1),(1,0)],
            levelCompleted: false, modifications: nil
        ),
        //there's a bug on this level - if an available square is in the solution coords
        // you can still tap on it regardless of whether it's next or not
        LevelData(
            gridX: 5, gridY: 5, delayTime: 0.5,
            solutionCoords:
            [(4,4),(3,4),(2,4),(1,4),(0,4),(0,3),(0,2),(0,1),(0,0),(1,0),(2,0),(3,0),(4,0)],
            levelCompleted: false, modifications: nil
        )]
        levelGroup.append((category:"5x5",levels: array))
    }
    func _6x10Flip(){
        let array = [LevelData(
            gridX: 6, gridY: 10, delayTime: 0.3,
            solutionCoords:
            [(0,7),(1,7),(1,8),(1,9),(2,9),(3,9),(3,8),(4,8),(4,7),(4,6),(5,6),(5,5),(5,4),(4,4),(3,4),(2,4),(1,4),(1,3),(2,3),(2,2),(3,2),(4,2),(4,1),(5,1)],
            levelCompleted: false, modifications: [.flip]
        )]
        levelGroup.append ((category: "fucking hard", array))
    }
}


//---------left off here
/*levels.append (LevelData(
 gridX: 6, gridY: 10, delayTime: 0.5,
 solutionCoords:
 [(0,7),(1,7),(1,8),(1,9),(2,9),(3,9),(3,8),(4,8),(4,7),(4,6),(5,6),(5,5),(5,4),(4,4),(3,4),(2,4),(1,4),(1,3),(2,3),(2,2),(3,2),(4,2),(4,1),(5,1)],
 levelCompleted: false, modifications: nil
 ))
 
 levels.append (LevelData(
 gridX: 6, gridY: 10, delayTime: 0.01,
 solutionCoords:
 [(0,7),(1,7),(2,7),(3,7),(4,7),(4,6),(4,5),(4,4),(4,3),(4,2),(4,1),(4,0)],
 levelCompleted: false, modifications: nil
 ))
 
 levels.append (LevelData(
 gridX: 5, gridY: 5, delayTime: 0.5,
 solutionCoords:
 [(0,4),(1,4),(1,3),(2,3),(2,2),(3,2),(3,1),(3,0),(4,0)],
 levelCompleted: false, modifications: nil
 ))
 
 levels.append (LevelData(
 gridX: 5, gridY: 5, delayTime: 0.5,
 solutionCoords:
 [(0,4),(1,4),(1,3),(2,3),(2,2),(3,2),(3,1),(3,0),(4,0)],
 levelCompleted: false, modifications: nil
 ))*/

