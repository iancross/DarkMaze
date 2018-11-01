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
let REQUIRED_TO_UNLOCK = 2

struct LevelData {
    var gridX: Int
    var gridY: Int
    var delayTime: Double
    var solutionCoords: [(x: Int,y: Int)]
    var modifications: [(GridModification, Any?)]?
}

enum GridModification {
    case flip
    case meetInTheMiddle
    case splitPath //(.splitpath, array coord arrays [[1,2,3,4],[1,2,3,6]]
    case thisLooksFamiliar //the path loops back onto itself
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
        //SplitPath()
        Normal()
        Jump()
        ThisLooksFamiliar() //go back over itself
        MeetInTheMiddle()
        Combo1()
        MultiJump()
        _BryanTest()
        _BryanTest()
        _BryanTest()
        _BryanTest()
        _BryanTest()
        _BryanTest()
        _BryanTest()
        _BryanTest()
        _BryanTest()
        _BryanTest()
        _BryanTest()
        _BryanTest()
        _BryanTest()
        _BryanTest()

        //disappearing trail()
        //Flip()
        //Spin()
        //Disorient() //Multiple spins and flips
        //MovedTiles
        //Reverse()
        //HyperSpeed() //just speed it up like crazy
        //Flash() //just literally flash the grid
        //WhereToEnd() //multiple end arrows

        //_BrokenTest()
        initCoreData()

    }
    
    
    //https://stackoverflow.com/questions/35372450/core-data-one-to-many-relationship-in-swift
    //https://stackoverflow.com/questions/35372450/core-data-one-to-many-relationship-in-swift
    private func initCoreData(){
        
        //testing
        //deleteCoreData()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("something bad app delegate ------------------------------------")
            return
        }
        if !doesDataExist(){
            let managedContext = appDelegate.persistentContainer.viewContext
            let pageEntity = NSEntityDescription.entity(forEntityName: "Page",in: managedContext)!
            let levelEntity = NSEntityDescription.entity(forEntityName: "Level",in: managedContext)!
            for i in 0...levelGroups.count-1{
                let page = Page(entity: pageEntity, insertInto: managedContext)
                if i == 0{
                    page.unlocked = true
                }
                else{
                    page.unlocked = false
                }
                
                //testing
                //page.unlocked = true
                
                page.number = Int32(i)
                for (j,levelData) in levelGroups[i].levels.enumerated(){
                    let level = Level(entity: levelEntity, insertInto: managedContext)
                    level.failedAttempts = 0
    //                //testing
    //                if i == 0 && j < 7{
    //                    level.completed = true
    //                }
    //                else{
    //                    level.completed = false
    //                }
    //                //end test
                    level.completed = false
                    level.number = Int32(j)
                    level.page = page
                    level.failedAttempts = 0
                }
            }
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    func doesDataExist()->Bool{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return false
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Page")
        do {
            let pages = try managedContext.fetch(fetchRequest)
            return pages.count > 0
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return false
        }
    }
    
    func deleteCoreData(){
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entities = ["Level","Page"]
        for entity in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try managedContext.execute(deleteRequest)
            } catch let error as NSError {
                // TODO: handle the error
            }
        }
    }
    
    //updated
    func isPageUnlocked(page: Int)->Bool{
        if page == 0{
            return true
        }
        else{
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return false
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Level")
            
            fetchRequest.predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates:
                [NSPredicate(format: "page.number == \(Int32(page - 1))"),
                 NSPredicate(format: "completed == \(true)")])
            do {
                let levelsCount = try (managedContext.fetch(fetchRequest) as [NSManagedObject]).count
                return levelsCount >= REQUIRED_TO_UNLOCK
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            return false
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
    //Updated
    func nextLevelToCompleteOnPage(page: Int) -> Int{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return 0
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Level")
        fetchRequest.predicate = NSPredicate(format: "page.number == \(page)")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "number", ascending: true)]
        do {
            if let levels = try managedContext.fetch(fetchRequest) as? [Level]{
                for level in levels{
                    if !level.completed{
                        return Int(level.number)
                    }
                }
                //if all levels are completed
                return levels.count
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return 0
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
    func levelCompleted(success: Bool){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Level")
        let pagePredicate = NSPredicate(format: "page.number == \(selectedLevel.page)")
        let levelPredicate = NSPredicate(format: "number == \(selectedLevel.level)")
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [pagePredicate,levelPredicate])
        fetchRequest.predicate = compoundPredicate
        
        //update completed and update failedAttempts
        do {
            let levels = try managedContext.fetch(fetchRequest) as [NSManagedObject]
            if (levels[0].value(forKey: "completed") as! Bool) == false{
                if success{
                    levels[0].setValue(true, forKey: "completed")
                }
                else{
                    let failedAttempts = levels[0].value(forKey: "failedAttempts") as? Int32
                    levels[0].setValue(failedAttempts!+1, forKey: "failedAttempts")
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        //now save
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func selectedLevelFirstAttemptSuccess()-> Bool{
        return firstAttemptSuccess(forLevel: (selectedLevel))
    }
    
    func firstAttemptSuccess(forLevel toTest: (page: Int, level: Int))->Bool{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return false
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Level")
        let pagePredicate = NSPredicate(format: "page.number == \(toTest.page)")
        let levelPredicate = NSPredicate(format: "number == \(toTest.level)")
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [pagePredicate,levelPredicate])
        fetchRequest.predicate = compoundPredicate
        
        do {
            let levels = try managedContext.fetch(fetchRequest) as [NSManagedObject]
            if levels[0].value(forKey: "completed") as? Bool == true && levels[0].value(forKey: "failedAttempts") as? Int32 == 0 {
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
    
    func getSolutionCoords(group: Int, level: Int) -> [(x: Int,y: Int)]{
        return levelGroups[group].levels[level].solutionCoords
    }
    
    func printAllLevelsUtil(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Page")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "number", ascending: true)]
        do {
            let pages = try managedContext.fetch(fetchRequest) as [NSManagedObject]
            print ("count of all pages is \(pages.count)")
            for (i,page) in pages.enumerated(){
                let num = page.value(forKeyPath: "number")
                print ("Page \(num as! Int32)")
                let fetchRequest2 = NSFetchRequest<NSManagedObject>(entityName: "Level")
                fetchRequest2.sortDescriptors = [NSSortDescriptor(key: "number", ascending: true)]
                fetchRequest2.predicate = NSPredicate(format: "page.number == \(num as! Int32)")
                let levels = try managedContext.fetch(fetchRequest2) as [NSManagedObject]
                print ("count of all levels in page \(String(describing: num)) is \(levels.count)")
                for l in levels{
                    print ("---- completed \(l.value(forKeyPath: "completed") as! Int32)")
                    print ("---- level number \(l.value(forKeyPath: "number") as! Int32))")
                    print ("---- failedAttempts \(l.value(forKeyPath: "failedAttempts") as! Int32))")
                }
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
        let array = [
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
        let array = [
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
                gridX: 6, gridY: 6, delayTime: 0.5,
                solutionCoords:
                [(4,0),(4,1),(1,4),(1,3),(0,3),(0,4),(0,5),(1,5),(2,5),(2,4),(2,3),(3,3),(3,4),(3,5),(4,5),(5,5),(5,4),(5,3),(5,2),(4,2),(3,2),(3,1),(3,0)],
                 modifications: nil
            ),
            LevelData(
                gridX: 6, gridY: 6, delayTime: 0.5,
                solutionCoords:
                [(0,2),(0,1),(0,0),(1,0),(2,0),(3,0),(3,1),(3,2),(3,3),(3,4),(3,5),(2,5),(1,5),(1,4),(1,3),(2,3),(2,2),(2,1),(1,1),(5,3)],
                 modifications: nil
            ),
            LevelData(
                gridX: 6, gridY: 6, delayTime: 0.5,
                solutionCoords:
                [(5,5),(4,5),(3,5),(2,5),(2,4),(1,4),(1,3),(2,3),(3,3),(4,3),(5,3),(5,2),(5,1),(4,1),(4,0),(3,0),(3,1),(2,1),(1,1),(0,1),(4,2),(3,2),(2,2),(1,2),(0,2)],
                 modifications: nil
            ),
            //-------BONUS LEVELS--------
            LevelData(
                gridX: 6, gridY: 7, delayTime: 0.5,
                solutionCoords:
                [(2,5),(2,4),(1,4),(1,3),(2,3),(3,3),(3,2),(2,2),(1,2),(0,2),(0,1),(1,1),(2,1),(3,1),(4,1),(4,0),(3,0),(2,0)],
                 modifications: nil
            ),
            LevelData(
                gridX: 6, gridY: 7, delayTime: 0.5,
                solutionCoords:
                [(0,3),(0,4),(0,5),(1,5),(1,4),(2,4),(2,3),(2,2),(1,2),(1,1),(0,1),(0,0),(1,0),(2,0),(3,0),(4,0),(4,1)],
                 modifications: nil
            ),
            LevelData(
                gridX: 7, gridY: 7, delayTime: 0.5,
                solutionCoords:
                [(6,1),(5,1),(4,1),(3,1),(2,1),(1,1),(0,1),(0,2),(0,3),(0,4),(0,5),(0,6),(1,6),(2,6),(3,6),(4,6),(4,5),(5,5),(5,4),(5,3),(5,2),(4,2),(4,3),(3,3),(2,3),(2,2),(1,2),(1,3),(1,4),(1,5),(2,5),(2,4),(3,4),(4,4),(6,4)],
                 modifications: nil
            ),
            LevelData(
                gridX: 7, gridY: 7, delayTime: 0.5,
                solutionCoords:
                [(0,0),(1,0),(1,1),(2,1),(4,5),(4,4),(3,4),(2,4),(2,5),(2,6),(1,6),(1,5),(0,5),(0,4),(0,3),(0,2),(1,2),(2,2),(3,2),(4,2),(4,1),(4,0),(5,0),(6,0),(6,1),(6,2),(5,2),(5,3),(5,4),(5,5),(5,6),(4,6)],
                 modifications: nil
            )
        ]
        
        levelGroups.append ((category: "Jump", array))
    }
    
//    private func SplitPath(){
//        let array = [
//            LevelData(
//                gridX: 5, gridY: 5, delayTime: 0.5,
//                solutionCoords:
//                [(4,3),(3,3),(3,4),(2,4),(1,4),(1,2),(1,1),(1,0)],
//                modifications: [
//                                    (.splitPath, [[(4,3),(4,2),(4,1)]])
//                                ]
//            )
//        ]
//
//        levelGroups.append ((category: "Split Paths", array))
//    }
    
    private func MeetInTheMiddle(){
        let array = [
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.5,
                solutionCoords:
                [(0,0),(0,1),(0,2),(0,3),(1,3),(1,2),(2,2),(2,3),(3,3),(3,2),(3,1),(3,0)],
                modifications: [(.meetInTheMiddle, nil)]
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.5,
                solutionCoords:
                [(4,2),(3,2),(2,2),(2,1),(2,0),(1,0),(0,0),(0,1),(0,2),(0,3),(0,4)],
                modifications: [(.meetInTheMiddle, nil)]
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.5,
                solutionCoords:
                [(4,4),(3,4),(3,3),(2,3),(2,2),(3,2),(4,2),(4,1),(4,0),(3,0),(2,0),(1,0),(0,0)],
                modifications: [(.meetInTheMiddle, nil)]
            ),
            LevelData(
                gridX: 5, gridY: 6, delayTime: 0.5,
                solutionCoords:
                [(4,5),(4,4),(3,4),(3,3),(3,2),(4,2),(4,1),(3,1),(2,1),(1,1),(1,2),(0,2),(0,3),(0,4),(1,4),(1,3),(2,3),(2,2),(2,1),(2,0)],
                modifications: [(.meetInTheMiddle, nil)]
            ),
            LevelData(
                gridX: 5, gridY: 6, delayTime: 0.5,
                solutionCoords:
                [(4,5),(4,4),(4,3),(4,2),(3,2),(2,2),(1,2),(1,3),(2,3),(2,2),(2,1),(1,1),(0,1),(0,2),(0,3),(0,4),(1,4),(2,4),(3,4),(3,3),(3,2),(3,1),(4,1)],
                modifications: [(.meetInTheMiddle, nil)]
            ),
            LevelData(
                gridX: 6, gridY: 6, delayTime: 0.5,
                solutionCoords:
                [(0,2),(1,2),(2,2),(3,2),(4,2),(4,3),(3,3),(2,3),(2,2),(2,1),(3,1),(4,1),(4,0),(3,0),(2,0),(1,0),(0,0),(0,1),(0,2),(0,3),(0,4),(0,5),(1,5),(2,5),(3,5),(4,5),(4,4),(4,3),(5,3)],
                modifications: [(.meetInTheMiddle, nil)]
            ),
            LevelData(
                gridX: 6, gridY: 8, delayTime: 0.5,
                solutionCoords:
                [(0,0),(0,1),(0,2),(0,3),(0,4),(1,4),(1,4),(2,4),(3,4),(3,5),(2,5),(1,5),(0,5),(0,6),(0,7),(1,7),(2,7),(2,6),(3,6),(3,5),(4,5),(4,4),(5,4),(5,3),(4,3),(4,2),(3,2),(3,1),(2,1),(2,0),(1,0)],
                modifications: [(.meetInTheMiddle, nil)]
            ),
            LevelData(
                gridX: 5, gridY: 10, delayTime: 0.5,
                solutionCoords:
                [(0,9),(0,8),(0,7),(1,7),(2,7),(3,7),(3,6),(4,6),(4,5),(4,4),(3,4),(2,4),(1,4),(0,4),(0,5),(1,5),(2,5),(2,4),(2,3),(2,2),(3,2),(3,1),(2,1),(1,1),(0,1),(0,2),(0,3),(1,3),(2,3),(3,3),(4,3),(4,2)],
                modifications: [(.meetInTheMiddle, nil)]
            )]
        levelGroups.append ((category: "Meet In The Middle", array))
    }
    
    private func ThisLooksFamiliar(){
        let array = [
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.5,
                solutionCoords:
                [(0,1),(1,1),(2,1),(2,2),(2,3),(1,3),(0,3),(0,2),(1,2),(2,2),(3,2)],
                modifications: [(.thisLooksFamiliar, nil)]
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.5,
                solutionCoords:
                [(4,4),(4,3),(4,2),(3,2),(3,3),(2,3),(1,3),(0,3),(0,2),(0,1),(0,0),(1,0),(2,0),(2,1),(3,1),(3,2),(3,3),(3,4)],
                modifications: [(.thisLooksFamiliar, nil)]
            ),
            LevelData(
                gridX: 5, gridY: 6, delayTime: 0.5,
                solutionCoords:
                [(0,4),(1,4),(1,3),(2,3),(3,3),(4,3),(4,2),(4,1),(3,1),(2,1),(2,2),(2,3),(2,4),(2,5),(1,5),(0,5),(0,4),(0,3),(0,2),(0,1),(0,0)],
                modifications: [(.thisLooksFamiliar, nil)]
            ),
            LevelData(
                gridX: 5, gridY: 6, delayTime: 0.5,
                solutionCoords:
                [(4,5),(4,4),(3,4),(3,3),(3,2),(4,2),(4,1),(3,1),(2,1),(1,1),(1,2),(0,2),(0,3),(0,4),(1,4),(1,3),(2,3),(2,2),(2,1),(2,0)],
                modifications: [(.thisLooksFamiliar, nil)]
            ),
            LevelData(
                gridX: 5, gridY: 6, delayTime: 0.5,
                solutionCoords:
                [(4,5),(4,4),(4,3),(4,2),(3,2),(2,2),(1,2),(1,3),(2,3),(2,2),(2,1),(1,1),(0,1),(0,2),(0,3),(0,4),(1,4),(2,4),(3,4),(3,3),(3,2),(3,1),(4,1)],
                modifications: [(.thisLooksFamiliar, nil)]
            ),
            LevelData(
                gridX: 6, gridY: 6, delayTime: 0.5,
                solutionCoords:
                [(0,2),(1,2),(2,2),(3,2),(4,2),(4,3),(3,3),(2,3),(2,2),(2,1),(3,1),(4,1),(4,0),(3,0),(2,0),(1,0),(0,0),(0,1),(0,2),(0,3),(0,4),(0,5),(1,5),(2,5),(3,5),(4,5),(4,4),(4,3),(5,3)],
                modifications: [(.thisLooksFamiliar, nil)]
            ),
            LevelData(
                gridX: 6, gridY: 8, delayTime: 0.5,
                solutionCoords:
                [(0,0),(0,1),(0,2),(0,3),(0,4),(1,4),(1,4),(2,4),(3,4),(3,5),(2,5),(1,5),(0,5),(0,6),(0,7),(1,7),(2,7),(2,6),(3,6),(3,5),(4,5),(4,4),(5,4),(5,3),(4,3),(4,2),(3,2),(3,1),(2,1),(2,0),(1,0)],
                modifications: [(.thisLooksFamiliar, nil)]
            ),
            LevelData(
                gridX: 5, gridY: 10, delayTime: 0.5,
                solutionCoords:
                [(0,9),(0,8),(0,7),(1,7),(2,7),(3,7),(3,6),(4,6),(4,5),(4,4),(3,4),(2,4),(1,4),(0,4),(0,5),(1,5),(2,5),(2,4),(2,3),(2,2),(3,2),(3,1),(2,1),(1,1),(0,1),(0,2),(0,3),(1,3),(2,3),(3,3),(4,3),(4,2)],
                modifications: [(.thisLooksFamiliar, nil)]
            )]
        levelGroups.append ((category: "This Looks Familiar", array))
    }
    
    func Combo1(){
        let array = [
            LevelData(
                gridX: 3, gridY: 3, delayTime: 0.5,
                solutionCoords:[(0,2),(0,1),(0,0),(1,0),(1,1),(1,2),(2,2),(2,1),(2,0)],
                modifications: nil
            ),
            LevelData(
                gridX: 3, gridY: 3, delayTime: 0.5,
                solutionCoords:[(0,2),(0,1),(0,0),(1,0),(1,1),(1,2),(2,2),(2,1),(2,0)],
                modifications: nil
            ),
            LevelData(
                gridX: 3, gridY: 3, delayTime: 0.5,
                solutionCoords:[(0,2),(0,1),(0,0),(1,0),(1,1),(1,2),(2,2),(2,1),(2,0)],
                modifications: nil
            ),
            LevelData(
                gridX: 3, gridY: 3, delayTime: 0.5,
                solutionCoords:[(0,2),(0,1),(0,0),(1,0),(1,1),(1,2),(2,2),(2,1),(2,0)],
                modifications: nil
            )
        ]
        levelGroups.append ((category: "\u{2606} Combo 1", array))
    }
    
    func MultiJump(){
        let array = [
            LevelData(
                gridX: 3, gridY: 3, delayTime: 0.5,
                solutionCoords:[(0,2),(0,1),(0,0),(1,0),(1,1),(1,2),(2,2),(2,1),(2,0)],
                modifications: nil
            )
        ]
        levelGroups.append ((category: "Multi-Jump", array))
    }
    
    private func Blackout(){
        let array = [
            LevelData(
                gridX: 3, gridY: 3, delayTime: 0.5,
                solutionCoords:[(0,2),(0,1),(0,0),(1,0),(1,1),(1,2),(2,2),(2,1),(2,0)],
                 modifications: nil
            ),
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.5,
                solutionCoords:[(0,0),(1,0),(1,1),(2,1),(2,0),(3,0),(3,1),(3,2),(3,3),(2,3),(2,2),(1,2),(1,3),(0,3),(0,2),(0,1)],
                 modifications: nil
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.5,
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
                modifications: [(.flip, nil), (.meetInTheMiddle, nil)]
            ),LevelData(
                gridX: 6, gridY: 10, delayTime: 0.7,
                solutionCoords:
                [(0,7),(1,7),(1,8),(1,9),(2,9),(3,9),(3,8),(4,8),(4,7),(4,6),(5,6),(5,5),(5,4),(4,4),(3,4),(2,4),(1,4),(1,3),(2,3),(2,2),(3,2),(4,2),(4,1),(5,1)],
                 modifications: [(.flip, nil), (.meetInTheMiddle, nil)]
            )]
        levelGroups.append ((category: "Huge", array))
    }
    
    private func _BryanTest(){
        let array = [LevelData(
            gridX: 5, gridY: 5, delayTime: 0.3,
            solutionCoords:
            [(1,1),(1,2),(2,2),(2,1),(3,1),(3,2),(3,3),(3,4),(2,4),(2,3),(1,3),(1,4),(0,4),(0,3),(0,2),(0,1)],
             modifications: [(.flip, nil)]
            )]
        levelGroups.append ((category: "Bryan is a dangus", array))
    }
    private func _BrokenTest(){
        let array = [LevelData(
            gridX: 5, gridY: 5, delayTime: 0.3,
            solutionCoords:
            [(1,1),(1,2),(2,2),(2,1),(3,1),(3,2),(3,3),(3,4),(2,4),(2,3),(1,3),(1,4),(0,4),(0,3),(0,2),(0,1)],
            modifications: [(.flip, nil)]
            )]
        levelGroups.append ((category: "broken", array))
    }
}

