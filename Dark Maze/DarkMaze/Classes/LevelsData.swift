//
//  Level1LevelsData.swift
//  Dark Maze
//
//  Created by crossibc on 12/24/17.
//  Copyright © 2017 crossibc. All rights reserved.
//

import UIKit
import Foundation
import CoreData

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
    var modifications: [GridModification]?
}

enum GridModification {
    case flip
    case meetInTheMiddle
}

class LevelsData{
    static let shared = LevelsData()
    
    var currentLevelSuccess: Bool
    var selectedLevel: (page: Int, level: Int)
    private var levelGroups = [(category: String, levels: [LevelData])]()
    
    init(){
        currentLevelSuccess = false
        //used by the gameplay if you play an earlier level
        selectedLevel = (page: 0, level: 0)
        
        //levelGroups = [(category: String, levels: [LevelData])]()
        Normal()
        Jump()
        Huge()
        MeetInTheMiddle()
        //ThisLooksFamiliar() //go back over itself
        //disappearing trail()
        //MultiJump()
        //SplitPath()
        //Flip()
        //Spin()
        //Disorient() //Multiple spins and flips
        //MovedTiles
        //Reverse()
        //HyperSpeed() //just speed it up like crazy
        //Flash() //just literally flash the grid
        //WhereToEnd() //multiple end arrows
        Blackout()
        //_BrokenTest()
        initCoreData()
    }
    
    private func initCoreData(){
        //deleteCoreData()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Level",in: managedContext)!
        for i in 0...levelGroups.count-1{
            let level = NSManagedObject(entity: entity, insertInto: managedContext)
            level.setValue(i, forKey: "page")
            level.setValue(0, forKey: "levels_completed")
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func deleteCoreData(){
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }

        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Level")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try managedContext.execute(deleteRequest)
        } catch let error as NSError {
            // TODO: handle the error
        }
    }
    func isPageUnlocked(page: Int)->Bool{
        if page == 0{
            return true
        }
        else{
            return nextLevelToCompleteOnPage(page: page-1) >= REQUIRED_TO_UNLOCK
        }
    }
    
    func getSelectedLevelData() -> LevelData{ 
        return levelGroups[selectedLevel.page].levels[selectedLevel.level]
    }
    
    //This should be called when you hit "next level"
    //Depending on which page you are on, it'll go to the next available level on that page
    //by advancing "selected level"
    func nextLevel(){
        if selectedLevel.level < levelGroups[selectedLevel.page].levels.count - 1{
            selectedLevel.level += 1
        }
        else if selectedLevel.page < levelGroups.count - 1 {
            selectedLevel.level = 0
            selectedLevel.page += 1
        }
    }
    
    //returns the next level to complete within a page
    func nextLevelToCompleteOnPage(page: Int) -> Int{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return 0
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Level")
        fetchRequest.predicate = NSPredicate(format: "page == \(page)")
        do {
            let levels = try managedContext.fetch(fetchRequest) as [NSManagedObject]
            let levels_completed = levels[0].value(forKeyPath: "levels_completed") as! Int
            return levels_completed
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return 0
        }
    }
    
    func hasLevelBeenCompleted(page: Int, levelToTest: Int) -> Bool{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return false
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Level")
        fetchRequest.predicate = NSPredicate(format: "page == \(page)")
        do {
            let levels = try managedContext.fetch(fetchRequest) as [NSManagedObject]
            let levels_completed = levels[0].value(forKeyPath: "levels_completed") as! Int
            if levels_completed > levelToTest {
                return true
            }
            else{
                return false
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return false
        }
    }
    
    func getNumPages() -> Int{
        return levelGroups.count
    }
    func getNumLevelsOnPage(page: Int) -> Int{
        return levelGroups[page].levels.count
    }
    func getPageCategory(page: Int) -> String{
        return levelGroups[page].category
    }
    
    func selectedLevelCompletedSuccessfully(){

        //levelGroups[selectedLevel.page].levels[selectedLevel.level].levelCompleted = true
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Level")
        fetchRequest.predicate = NSPredicate(format: "page == \(selectedLevel.page)")
        do {
            let levels = try managedContext.fetch(fetchRequest) as [NSManagedObject]
            let levels_completed = levels[0].value(forKeyPath: "levels_completed") as! Int
            if levels_completed == selectedLevel.level{
                levels[0].setValue(levels_completed + 1, forKey: "levels_completed")
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }

    }
    
    func getSolutionCoords(group: Int, level: Int) -> [(x: Int,y: Int)]{
        return levelGroups[group].levels[level].solutionCoords
    }
    
    func printAllLevelsUtil(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Level")
        do {
            let levels = try managedContext.fetch(fetchRequest) as [NSManagedObject]
            //level[0].setValue(10, forKey: "levels_complete")
            for (i,level) in levels.enumerated(){
                print("page is \(level.value(forKeyPath: "page") as! Int)")
                print("levels completed is \(level.value(forKeyPath: "levels_completed") as! Int)")
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
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
                [(0,1),(1,1),(2,1),(2,2),(3,2)],
                 modifications: nil
            ),
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.5,
                solutionCoords:
                [(0,3),(1,3),(1,2),(1,1),(2,1),(2,0)],
                 modifications: nil
            ),
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.5,
                solutionCoords:
                [(3,3),(3,2),(3,1),(2,1),(1,1),(0,1),(0,0)],
                 modifications: nil
            ),
            LevelData(
                gridX: 4, gridY: 5, delayTime: 0.5,
                solutionCoords:
                [(0,2),(0,1),(1,1),(1,2),(2,2),(2,3),(2,4),(3,4)],
                 modifications: nil
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.5,
                solutionCoords:
                [(4,0),(4,1),(4,2),(4,3),(3,3),(3,2),(2,2),(2,1),(1,1),(0,1)],
                 modifications: nil
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.5,
                solutionCoords:
                [(2,4),(2,3),(3,3),(3,2),(3,1),(3,0),(2,0),(1,0),(1,1),(1,2),(0,2)],
                 modifications: nil
            ),
            LevelData(
                gridX: 5, gridY: 6, delayTime: 0.5,
                solutionCoords:
                [(1,5),(1,4),(0,4),(0,3),(1,3),(2,3),(3,3),(4,3),(4,2),(3,2),(2,2),(2,1),(2,0)],
                 modifications: nil
            ),
            LevelData(
                gridX: 5, gridY: 6, delayTime: 0.5,
                solutionCoords:
                [(0,0),(0,1),(0,2),(0,3),(0,4),(0,5),(1,5),(2,5),(3,5),(4,5),(4,4),(4,3),(3,3),(2,3),(2,2),(2,1),(2,0),(3,0),(4,0),(4,1)],
                 modifications: nil
            ),
            //-------BONUS LEVELS--------
            LevelData(
                gridX: 5, gridY: 6, delayTime: 0.5,
                solutionCoords:
                [(2,5),(2,4),(1,4),(1,3),(2,3),(3,3),(3,2),(2,2),(1,2),(0,2),(0,1),(1,1),(2,1),(3,1),(4,1),(4,0),(3,0),(2,0)],
                 modifications: nil
            ),
            LevelData(
                gridX: 5, gridY: 6, delayTime: 0.5,
                solutionCoords:
                [(0,3),(0,4),(0,5),(1,5),(1,4),(2,4),(2,3),(2,2),(1,2),(1,1),(0,1),(0,0),(1,0),(2,0),(3,0),(4,0),(4,1)],
                 modifications: nil
            ),
            LevelData(
                gridX: 6, gridY: 6, delayTime: 0.5,
                solutionCoords:
                [(5,5),(5,4),(4,4),(4,3),(4,2),(5,2),(5,1),(5,0),(4,0),(3,0),(3,1),(2,1),(2,2),(1,2),(1,3),(1,4),(2,4),(2,5),(3,5)],
                 modifications: nil
            ),
            LevelData(
                gridX: 6, gridY: 6, delayTime: 0.5,
                solutionCoords:
                [(1,5),(1,4),(1,3),(1,2),(1,1),(2,1),(3,1),(3,2),(3,3),(3,4),(4,4),(5,4),(5,3),(5,2),(5,1),(4,1),(4,0),(3,0)],
                 modifications: nil
            )
        ]
        levelGroups.append ((category: "Normal", array))
        
    }
    private func Jump(){
        var array = [
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.5,
                solutionCoords:
                [(4,3),(3,3),(3,4),(2,4),(1,4),(1,2),(1,1),(1,0)],
                 modifications: nil
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.5,
                solutionCoords:
                [(0,0),(0,1),(0,2),(1,2),(2,2),(2,4),(3,4),(4,4),(4,3),(4,2),(4,1),(4,0)],
                 modifications: nil
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.5,
                solutionCoords:
                [(0,4),(0,3),(1,3),(4,3),(4,2),(3,2),(2,2),(2,1),(2,0),(3,0),(4,0)],
                 modifications: nil
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.5,
                solutionCoords:
                [(0,4),(0,3),(1,3),(2,3),(4,1),(3,1),(3,0),(2,0),(1,0),(1,1),(0,1)],
                 modifications: nil
            ),
            LevelData(
                gridX: 5, gridY: 6, delayTime: 0.5,
                solutionCoords:
                [(4,5),(4,4),(3,4),(2,4),(1,4),(1,3),(1,2),(1,1),(1,0),(0,0),(3,2),(3,1),(3,0),(4,0)],
                 modifications: nil
            ),
            LevelData(
                gridX: 5, gridY: 6, delayTime: 0.5,
                solutionCoords:
                [(0,5),(0,4),(0,3),(4,0),(4,1),(4,2)],
                 modifications: nil
            ),
            LevelData(
                gridX: 5, gridY: 6, delayTime: 0.5,
                solutionCoords:
                [(1,5),(1,4),(0,4),(0,3),(1,3),(2,3),(3,3),(4,3),(4,2),(3,2),(2,2),(2,1),(2,0)],
                 modifications: nil
            ),
            LevelData(
                gridX: 5, gridY: 6, delayTime: 0.5,
                solutionCoords:
                [(0,0),(0,1),(0,2),(0,3),(0,4),(0,5),(1,5),(2,5),(3,5),(4,5),(4,4),(4,3),(3,3),(2,3),(2,2),(2,1),(2,0),(3,0),(4,0),(4,1)],
                 modifications: nil
            ),
            //-------BONUS LEVELS--------
            LevelData(
                gridX: 5, gridY: 6, delayTime: 0.5,
                solutionCoords:
                [(2,5),(2,4),(1,4),(1,3),(2,3),(3,3),(3,2),(2,2),(1,2),(0,2),(0,1),(1,1),(2,1),(3,1),(4,1),(4,0),(3,0),(2,0)],
                 modifications: nil
            ),
            LevelData(
                gridX: 5, gridY: 6, delayTime: 0.5,
                solutionCoords:
                [(0,3),(0,4),(0,5),(1,5),(1,4),(2,4),(2,3),(2,2),(1,2),(1,1),(0,1),(0,0),(1,0),(2,0),(3,0),(4,0),(4,1)],
                 modifications: nil
            ),
            LevelData(
                gridX: 6, gridY: 6, delayTime: 0.5,
                solutionCoords:
                [(5,5),(5,4),(4,4),(4,3),(4,2),(5,2),(5,1),(5,0),(4,0),(3,0),(3,1),(2,1),(2,2),(1,2),(1,3),(1,4),(2,4),(2,5),(3,5)],
                 modifications: nil
            ),
            LevelData(
                gridX: 6, gridY: 6, delayTime: 0.5,
                solutionCoords:
                [(1,5),(1,4),(1,3),(1,2),(1,1),(2,1),(3,1),(3,2),(3,3),(3,4),(4,4),(5,4),(5,3),(5,2),(5,1),(4,1),(4,0),(3,0)],
                 modifications: nil
            )
        ]
        
        levelGroups.append ((category: "Jump", array))
    }
    
    private func MeetInTheMiddle(){
        let array = [LevelData(
            gridX: 5, gridY: 5, delayTime: 0.3,
            solutionCoords:
            [(1,0),(1,1),(1,2),(1,3),(1,4)],
             modifications: [.meetInTheMiddle]
            ),
                     LevelData(
                        gridX: 5, gridY: 6, delayTime: 0.3,
                        solutionCoords:
                        [(1,0),(1,1),(1,2),(1,3),(1,4),(1,5)],
                         modifications: [.meetInTheMiddle]
            )]
        levelGroups.append ((category: "Meet In The Middle", array))
    }
    
    
    
    private func Blackout(){
        let array = [
            LevelData(
                gridX: 3, gridY: 3, delayTime: 0.3,
                solutionCoords:[(0,2),(0,1),(0,0),(1,0),(1,1),(1,2),(2,2),(2,1),(2,0)],
                 modifications: nil
            ),
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.3,
                solutionCoords:[(0,0),(1,0),(1,1),(2,1),(2,0),(3,0),(3,1),(3,2),(3,3),(2,3),(2,2),(1,2),(1,3),(0,3),(0,2),(0,1)],
                 modifications: nil
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.3,
                solutionCoords:
                [(4,0),(3,0),(2,0),(2,1),(2,2),(1,2),(1,1),(1,0),(0,0),(0,1),(0,2),(0,3),(0,4),(1,4),(1,3),(2,3),(3,3),(3,2),(3,1),(4,1),(4,2),(4,3),(4,4),(3,4),(2,4)],
                 modifications: nil
            )
        ]
        levelGroups.append ((category: "Blackout", array))
    }
    
    private func Huge(){
        let array = [LevelData(
            gridX: 6, gridY: 10, delayTime: 0.3,
            solutionCoords:
            [(0,7),(1,7),(1,8),(1,9),(2,9),(3,9),(3,8),(4,8),(4,7),(4,6),(5,6),(5,5),(5,4),(4,4),(3,4),(2,4),(1,4),(1,3),(2,3),(2,2),(3,2),(4,2),(4,1),(5,1)],
             modifications: [.flip, .meetInTheMiddle]
            ),LevelData(
                gridX: 6, gridY: 10, delayTime: 0.7,
                solutionCoords:
                [(0,7),(1,7),(1,8),(1,9),(2,9),(3,9),(3,8),(4,8),(4,7),(4,6),(5,6),(5,5),(5,4),(4,4),(3,4),(2,4),(1,4),(1,3),(2,3),(2,2),(3,2),(4,2),(4,1),(5,1)],
                 modifications: [.flip, .meetInTheMiddle]
            )]
        levelGroups.append ((category: "Huge", array))
    }
    
    private func _BrokenTest(){
        let array = [LevelData(
            gridX: 5, gridY: 5, delayTime: 0.3,
            solutionCoords:
            [(1,1),(1,2),(2,2),(2,1),(3,1),(3,2),(3,3),(3,4),(2,4),(2,3),(1,3),(1,4),(0,4),(0,3),(0,2),(0,1)],
             modifications: [.flip]
            )]
        levelGroups.append ((category: "broken", array))
    }
}


//---------left off here
/*levels.append (LevelData(
 gridX: 6, gridY: 10, delayTime: 0.5,
 solutionCoords:
 [(0,7),(1,7),(1,8),(1,9),(2,9),(3,9),(3,8),(4,8),(4,7),(4,6),(5,6),(5,5),(5,4),(4,4),(3,4),(2,4),(1,4),(1,3),(2,3),(2,2),(3,2),(4,2),(4,1),(5,1)],
  modifications: nil
 ))
 
 levels.append (LevelData(
 gridX: 6, gridY: 10, delayTime: 0.01,
 solutionCoords:
 [(0,7),(1,7),(2,7),(3,7),(4,7),(4,6),(4,5),(4,4),(4,3),(4,2),(4,1),(4,0)],
  modifications: nil
 ))
 
 levels.append (LevelData(
 gridX: 5, gridY: 5, delayTime: 0.5,
 solutionCoords:
 [(0,4),(1,4),(1,3),(2,3),(2,2),(3,2),(3,1),(3,0),(4,0)],
  modifications: nil
 ))
 
 levels.append (LevelData(
 gridX: 5, gridY: 5, delayTime: 0.5,
 solutionCoords:
 [(0,4),(1,4),(1,3),(2,3),(2,2),(3,2),(3,1),(3,0),(4,0)],
  modifications: nil
 ))*/

