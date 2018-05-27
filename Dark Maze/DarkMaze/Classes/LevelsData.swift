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
let REQUIRED_TO_UNLOCK = 8

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
    var levelGroups = [(category: String, levels: [LevelData])]()
    var placeHolderLevel: LevelData?

    init(){
        currentLevelSuccess = false
        placeHolderLevel = LevelData(gridX: 4, gridY: 4, delayTime: 0.3, solutionCoords: [(0,0), (0,1), (1,1)], levelCompleted: false, modifications: nil)
        //used by the gameplay if you play an earlier level
        selectedLevel = (page: 0, level: 0)
        currentPage = 0
        
        //levelGroups = [(category: String, levels: [LevelData])]()
        Normal()
        Jump()
        //ThisLooksFamiliar() //go back over itself
        //disappearing trail()
        //MultiJump()
        //SplitPath()
        //Flip()
        //Spin()
        //Disorient() //Multiple spins and flips
        //MeetInTheMiddle()
        //MovedTiles
        //Reverse()
        //HyperSpeed() //just speed it up like crazy
        //Flash() //just literally flash the grid
        //WhereToEnd() //multiple end arrows
        Blackout()
        Huge()
        //_BrokenTest()
    }
    func isPageUnlocked(page: Int)->Bool{
        if page == 0{
            return true
        }
        else{
            var passedLevels = 0
            for i in levelGroups[page-1].levels{
                if i.levelCompleted {
                    passedLevels += 1
                }
            }
            return passedLevels >= REQUIRED_TO_UNLOCK
        }
    }
    
    func nextLevel(){
        currentPage = selectedLevel.page
        if selectedLevel.level < levelGroups[currentPage].levels.count - 1{
            selectedLevel.level += 1
        }
        else if currentPage < levelGroups.count - 1 {
            currentPage += 1
            selectedLevel.level = 0
            selectedLevel.page = currentPage
        }
        else{
            // do nothing
        }
    }
    
    //returns the highest completed level
    func getCategoryProgress(groupIndex: Int) -> Int{
        var count = 0
        for l in levelGroups[groupIndex].levels {
            if l.levelCompleted {
                count += 1
            }
        }
        return count
    }
    
    //returns the next level to complete within a page
    func nextLevelToComplete(groupIndex: Int) -> Int{
        let pageLevels = levelGroups[groupIndex].levels
        for (i,level) in pageLevels.enumerated(){
            if !level.levelCompleted{
                return i
            }
        }
        return pageLevels.count - 1
    }
    
    func getSolutionCoords(group: Int, level: Int) -> [(x: Int,y: Int)]{
        return levelGroups[group].levels[level].solutionCoords
    }
    /*------------------------------- 4x4 -------------------------------*/
    //Description:
    //Easiest level to show how to play the game. Probably going to do all sorts of
    //directions to show the maze functionality
    private func Normal(){
        var array = [
        LevelData(
            gridX: 4, gridY: 4, delayTime: 0.5,
            solutionCoords:
            [(0,1),(0,2),(0,3),(1,3),(2,3),(3,3)],
            levelCompleted: true, modifications: nil
        ),
        LevelData(
            gridX: 4, gridY: 4, delayTime: 0.5,
            solutionCoords:
            [(0,3),(1,3),(1,2),(1,1),(1,0)],
            levelCompleted: true, modifications: nil
            ),LevelData(
                gridX: 4, gridY: 4, delayTime: 0.5,
                solutionCoords:
                [(0,1),(0,2),(0,3),(1,3),(2,3),(3,3)],
                levelCompleted: true, modifications: nil
            ),
              LevelData(
                gridX: 4, gridY: 4, delayTime: 0.5,
                solutionCoords:
                [(0,3),(1,3),(1,2),(1,1),(1,0)],
                levelCompleted: true, modifications: nil
            ),
              LevelData(
                gridX: 4, gridY: 4, delayTime: 0.5,
                solutionCoords:
                [(0,1),(0,2),(0,3),(1,3),(2,3),(3,3)],
                levelCompleted: true, modifications: nil
            ),
             LevelData(
                gridX: 4, gridY: 4, delayTime: 0.5,
                solutionCoords:
                [(0,3),(1,3),(1,2),(1,1),(1,0)],
                levelCompleted: true, modifications: nil
            ),
             LevelData(
                gridX: 4, gridY: 4, delayTime: 0.5,
                solutionCoords:
                [(0,3),(1,3),(1,2),(1,1),(1,0)],
                levelCompleted: true, modifications: nil
            )
       ]
        for _ in 1...16-array.count{
            array.append(placeHolderLevel!)
        }
        levelGroups.append ((category: "Normal", array))

    }
    
    private func Jump(){
        var array = [
        LevelData(
            gridX: 5, gridY: 6, delayTime: 0.5,
            solutionCoords: [(0,1),(0,0),(1,0),(2,0),(2,3),(2,4),(1,4),(1,5),(2,5),(3,5),(4,5)],
            levelCompleted: true, modifications: nil
        ),
        LevelData(
            gridX: 5, gridY: 6, delayTime: 0.5,
            solutionCoords: [(0,1),(0,2),(0,3),(1,3),(2,3),(3,3),(4,3),(4,2),(4,1),(3,1),(2,1),(2,2),(2,3),(2,4),(2,5)],
            levelCompleted: false, modifications: nil
        )]
        for _ in 0...16-array.count{
            array.append(placeHolderLevel!)
        }
        levelGroups.append ((category: "Jump", array))
    }
    
    private func Blackout(){
        let array = [
            LevelData(
                gridX: 3, gridY: 3, delayTime: 0.3,
                solutionCoords:[(0,2),(0,1),(0,0),(1,0),(1,1),(1,2),(2,2),(2,1),(2,0)],
                levelCompleted: true, modifications: nil
            ),
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.3,
                solutionCoords:[(0,0),(1,0),(1,1),(2,1),(2,0),(3,0),(3,1),(3,2),(3,3),(2,3),(2,2),(1,2),(1,3),(0,3),(0,2),(0,1)],
                levelCompleted: false, modifications: nil
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.3,
                solutionCoords:
                [(4,0),(3,0),(2,0),(2,1),(2,2),(1,2),(1,1),(1,0),(0,0),(0,1),(0,2),(0,3),(0,4),(1,4),(1,3),(2,3),(3,3),(3,2),(3,1),(4,1),(4,2),(4,3),(4,4),(3,4),(2,4)],
                levelCompleted: false, modifications: nil
            )
        ]
        levelGroups.append ((category: "Blackout", array))
    }
    
    private func Huge(){
        let array = [LevelData(
            gridX: 6, gridY: 10, delayTime: 0.3,
            solutionCoords:
            [(0,7),(1,7),(1,8),(1,9),(2,9),(3,9),(3,8),(4,8),(4,7),(4,6),(5,6),(5,5),(5,4),(4,4),(3,4),(2,4),(1,4),(1,3),(2,3),(2,2),(3,2),(4,2),(4,1),(5,1)],
            levelCompleted: false, modifications: [.flip]
        )]
        levelGroups.append ((category: "Huge", array))
    }
    
    private func _BrokenTest(){
        let array = [LevelData(
            gridX: 5, gridY: 5, delayTime: 0.3,
            solutionCoords:
            [(1,1),(1,2),(2,2),(2,1),(3,1),(3,2),(3,3),(3,4),(2,4),(2,3),(1,3),(1,4),(0,4),(0,3),(0,2),(0,1)],
            levelCompleted: false, modifications: [.flip]
            )]
        levelGroups.append ((category: "broken", array))
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

