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
        ThisLooksFamiliar() //go back over itself
        Jump()
        MeetInTheMiddle()
        Combo1()
        MultiJump()

        //disappearing trail()
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
    
    
    //https://stackoverflow.com/questions/35372450/core-data-one-to-many-relationship-in-swift
    //https://stackoverflow.com/questions/35372450/core-data-one-to-many-relationship-in-swift
    private func initCoreData(){
        deleteCoreData()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
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
            page.number = Int32(i)
            for (j,levelData) in levelGroups[i].levels.enumerated(){
                let level = Level(entity: levelEntity, insertInto: managedContext)
                level.attempts = 0
                level.completed = false
                level.number = Int32(j)
                level.page = page
            }
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        printAllLevelsUtil()
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
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return false
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Page")
        fetchRequest.predicate = NSPredicate(format: "number == \(Int32(page))")
        do {
            let pages = try managedContext.fetch(fetchRequest) as [NSManagedObject]
            return (pages[0] as! Page).unlocked
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return false
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
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return 0
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
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Page")
        do {
            let pages = try managedContext.fetch(fetchRequest) as [NSManagedObject]
            print ("count of all pages is \(pages.count)")
            for (i,page) in pages.enumerated(){
                let num = page.value(forKeyPath: "number")
      
                let fetchRequest2 = NSFetchRequest<NSManagedObject>(entityName: "Level")

                fetchRequest2.predicate = NSPredicate(format: "page.number == \(num as! Int32)")
                let levels = try managedContext.fetch(fetchRequest2) as [NSManagedObject]
                print ("count of all levels in page \(num) is \(pages.count)")
                for l in levels{
                    print (l.value(forKeyPath: "attempts"))
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
        let array = [LevelData(
            gridX: 5, gridY: 5, delayTime: 0.5,
            solutionCoords:
            [(1,0),(1,1),(1,2),(1,3),(1,4)],
             modifications: [(.meetInTheMiddle, nil)]
            ),
             LevelData(
                gridX: 5, gridY: 6, delayTime: 0.5,
                solutionCoords:
                [(1,0),(1,1),(1,2),(1,3),(1,4),(1,5)],
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

