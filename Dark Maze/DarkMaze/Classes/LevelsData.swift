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
    case spin //looks like: (.spin, CGFloat.pi)
    case meetInTheMiddle
    case divideAndConquer
    case splitPath //(.splitpath, array coord arrays [[1,2,3,4],[1,2,3,6]]
    case thisLooksFamiliar //the path loops back onto itself
    case jumbled
    case blockReveal
}

class LevelsData{
    static let shared = LevelsData()
    
    var currentLevelSuccess: Bool
    var selectedLevel: (page: Int, level: Int)
    private var levelGroups = [(category: String, levels: [LevelData])]()
    
    init(){
        print ("begin init")
        currentLevelSuccess = false
        //used by the gameplay if you play an earlier level
        selectedLevel = (page: 0, level: 0)
        //levelGroups = [(category: String, levels: [LevelData])]()
        //SplitPath()
        Intro()
        Normal()
        Jump()
        ThisLooksFamiliar() //go back over itself
        MeetInTheMiddle()
        DivideAndConquer()
        Spin()
        Jumbled()
        Combo1()
        BlockReveal()
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

        initCoreData()
        print ("end init")
    }
    
    
    //https://stackoverflow.com/questions/35372450/core-data-one-to-many-relationship-in-swift
    //https://stackoverflow.com/questions/35372450/core-data-one-to-many-relationship-in-swift
    private func initCoreData(){
        
        if testing{
            deleteCoreData()
        }
        if !doesDataExist(){
            print ("data doesn't exist")
            initLevelData()
            AudioController.shared.initAudioSettings()
        }
    }
    
    private func initLevelData(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("something bad app delegate ------------------------------------")
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
            
            //                //testing
            //                page.unlocked = true
            
            page.number = Int32(i)
            for (j,levelData) in levelGroups[i].levels.enumerated(){
                let level = Level(entity: levelEntity, insertInto: managedContext)
                level.attemptsBeforeSuccess = 0
                level.completed = false
                
                //remove later!!!
                if testing{
                    level.completed = true
                }
                
                level.number = Int32(j)
                level.page = page
                level.totalAttempts = 0
                level.attemptsBeforeSuccess = 0
                level.firstTimeBonus = false
            }
        }
        //remove later!!!!!
        testing = false
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    public func resetGame(){
        deleteCoreData()
        initLevelData()
        currentLevelSuccess = false
        selectedLevel = (page: 0, level: 0)
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
        
        let entities = ["Level","Page","Settings"]
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
                return levelsCount >= levelGroups[page-1].levels.count//REQUIRED_TO_UNLOCK
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
        
        //update completed and update attemptsBeforeSuccess
        do {
            let levels = try managedContext.fetch(fetchRequest) as [NSManagedObject]
            if !(levels[0].value(forKey: "completed") as! Bool){
                if let attemptsBeforeSuccess = levels[0].value(forKey: "attemptsBeforeSuccess") as? Int32{
                    if success{
                        levels[0].setValue(true, forKey: "completed")
                        if attemptsBeforeSuccess == 0{
                            levels[0].setValue(true, forKey: "firstTimeBonus")
                        }
                    }
                    else{
                        levels[0].setValue(attemptsBeforeSuccess+1, forKey: "attemptsBeforeSuccess")
                    }
                }
            }
            if let totalAttempts = levels[0].value(forKey: "totalAttempts") as? Int32{
                levels[0].setValue(totalAttempts+1, forKey: "totalAttempts")
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
            if let bonus = levels[0].value(forKey: "firstTimeBonus") as? Bool {
                print ("------- The value of bonus is  \(bonus)")
                return bonus
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        print ("something fucked uppppppppppppp")
        return false
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
                    print ("---- attemptsBeforeSuccess \(l.value(forKeyPath: "attemptsBeforeSuccess") as! Int32))")
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    private func Intro(){
        let array = [
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.5,
                solutionCoords:
                [(0,1),(1,1),(2,1),(2,2),(3,2)],
                modifications: nil
            ),
            LevelData(
                gridX: 7, gridY: 10, delayTime: 0.2,
                solutionCoords:
                [(6,5),(5,5),(5,4),(4,4),(4,5),(4,6),(4,7),(1,8),(1,7),(1,6),(2,6),(2,5),(2,4),(1,4),(0,4),(0,5),(1,5),(2,5),(3,5),(3,4),(3,3),(3,2),(2,2),(0,1),(1,1),(1,0),(2,0),(3,0),(4,0),(4,1),(5,1),(5,2),(6,2)],
                modifications: [(.jumbled, [((2,2),(1,3)),((3,2),(2,3))]),(.flip, nil), (.spin, CGFloat.pi)]
            )
        ]
        levelGroups.append ((category: "Intro", array))
    }
    
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
            )
        ]
        levelGroups.append ((category: "Normal", array))
        
    }
    private func Jump(){
        let array = [
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.5,
                solutionCoords:
                [(0,0),(1,0),(2,0),(3,0),(3,1),(1,2),(1,3),(2,3),(3,3)],
                modifications: nil
            ),
            LevelData(
                gridX: 4, gridY: 5, delayTime: 0.5,
                solutionCoords:
                [(3,0),(2,0),(1,0),(0,0),(0,1),(1,1),(2,2),(1,2),(1,3),(2,3),(3,3)],
                modifications: nil
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.5,
                solutionCoords:
                [(4,3),(3,3),(3,4),(2,4),(1,4),(0,4),(0,3),(2,2),(2,1),(3,1),(3,0)],
                 modifications: nil
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.5,
                solutionCoords:
                [(2,0),(2,1),(1,1),(1,2),(0,2),(4,2),(3,2),(3,3),(2,3),(2,4)],
                 modifications: nil
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.5,
                solutionCoords:
                [(0,4),(0,3),(1,3),(4,3),(4,2),(3,2),(2,2),(2,1),(2,0),(3,0),(4,0)],
                 modifications: nil
            ),
            LevelData(
                gridX: 5, gridY: 6, delayTime: 0.5,
                solutionCoords:
                [(0,4),(0,3),(1,3),(2,3),(4,1),(3,1),(3,0),(2,0),(1,0),(1,1),(0,1)],
                 modifications: nil
            ),
            LevelData(
                gridX: 6, gridY: 6, delayTime: 0.5,
                solutionCoords:
                [(4,5),(4,4),(3,4),(2,4),(1,4),(1,3),(1,2),(1,1),(1,0),(0,0),(3,2),(3,1),(3,0),(4,0)],
                 modifications: nil
            ),
            LevelData(
                gridX: 6, gridY: 7, delayTime: 0.5,
                solutionCoords:
                [(2,6),(2,5),(1,5),(0,5),(0,4),(0,3),(1,3),(4,2),(4,3),(5,3),(5,2),(5,1),(4,1),(3,1),(3,2),(3,3),(3,4),(4,4),(5,4)],
                 modifications: nil
            )

        ]
        
        levelGroups.append ((category: "Jump", array))
    }
    
    private func MeetInTheMiddle(){
        let array = [
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.8,
                solutionCoords:
                [(0,0),(0,1),(0,2),(0,3),(1,3),(2,3),(2,2),(2,1),(2,0),(3,0)],
                modifications: [(.meetInTheMiddle, nil)]
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.8,
                solutionCoords:
                [(4,2),(3,2),(2,2),(2,1),(2,0),(1,0),(0,0),(0,1),(0,2),(0,3),(0,4)],
                modifications: [(.meetInTheMiddle, nil)]
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.8,
                solutionCoords:
                [(4,4),(3,4),(3,3),(2,3),(2,2),(3,2),(4,2),(4,1),(4,0),(3,0),(2,0),(1,0),(0,0)],
                modifications: [(.meetInTheMiddle, nil)]
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.8,
                solutionCoords:
                [(0,4),(0,3),(1,3),(1,2),(2,2),(2,1),(2,0),(3,0),(4,0)],
                modifications: [(.meetInTheMiddle, nil)]
            ),
            LevelData(   //5
                gridX: 5, gridY: 6, delayTime: 0.9,
                solutionCoords:
                [(4,3),(3,3),(3,2),(4,2),(4,1),(4,0),(3,0),(2,0),(1,0),(1,1),(1,2),(0,2),(0,3),(0,4),(1,4),(2,4),(2,5)],
                modifications: [(.meetInTheMiddle, nil)]
            ),
            LevelData(
                gridX: 5, gridY: 6, delayTime: 0.9,
                solutionCoords:
                [(0,0),(1,0),(2,0),(3,0),(4,0),(4,1),(3,1),(2,1),(1,1),(0,1),(0,2),(1,2),(2,2),(3,2),(3,3),(3,4),(2,4),(1,4),(0,4),(0,5),(1,5)],
                modifications: [(.meetInTheMiddle, nil)]
            ),
            LevelData(
                gridX: 4, gridY: 7, delayTime: 0.8,
                solutionCoords:
                [(0,5),(0,4),(0,3),(1,3),(1,2),(1,1),(1,0),(2,0),(2,1),(2,2),(2,3),(3,3),(3,4),(3,5),(3,6),],
                modifications: [(.meetInTheMiddle, nil)]
            ),
            LevelData(
                gridX: 4, gridY: 8, delayTime: 0.8,
                solutionCoords:
                [(3,2),(2,2),(2,3),(3,3),(3,4),(3,5),(3,6),(2,6),(1,6),(1,7),(0,7),(0,6),(0,5),(0,4),(1,4),(1,3),(1,2),(0,2),(0,1),(0,0),(1,0)],
                modifications: [(.meetInTheMiddle, nil)]
            )]
        levelGroups.append ((category: "Meet In The Middle", array))
    }
    
    private func DivideAndConquer(){
        let array = [
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.8,
                solutionCoords:
                [(0,0),(0,1),(0,2),(0,3),(1,3),(2,3),(2,2),(2,1),(2,0),(3,0)],
                modifications: [(.divideAndConquer, nil)]
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.8,
                solutionCoords:
                [(4,2),(3,2),(2,2),(2,1),(2,0),(1,0),(0,0),(0,1),(0,2),(0,3),(0,4)],
                modifications: [(.divideAndConquer, nil)]
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.8,
                solutionCoords:
                [(4,4),(3,4),(3,3),(2,3),(2,2),(3,2),(4,2),(4,1),(4,0),(3,0),(2,0),(1,0),(0,0)],
                modifications: [(.divideAndConquer, nil)]
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.8,
                solutionCoords:
                [(0,4),(0,3),(1,3),(1,2),(2,2),(2,1),(2,0),(3,0),(4,0)],
                modifications: [(.divideAndConquer, nil)]
            ),
            LevelData(   //5
                gridX: 5, gridY: 6, delayTime: 0.9,
                solutionCoords:
                [(4,3),(3,3),(3,2),(4,2),(4,1),(4,0),(3,0),(2,0),(1,0),(1,1),(1,2),(0,2),(0,3),(0,4),(1,4),(2,4),(2,5)],
                modifications: [(.divideAndConquer, nil)]
            ),
            LevelData(
                gridX: 5, gridY: 6, delayTime: 0.9,
                solutionCoords:
                [(0,0),(1,0),(2,0),(3,0),(4,0),(4,1),(3,1),(2,1),(1,1),(0,1),(0,2),(1,2),(2,2),(3,2),(3,3),(3,4),(2,4),(1,4),(0,4),(0,5),(1,5)],
                modifications: [(.divideAndConquer, nil)]
            ),
            LevelData(
                gridX: 4, gridY: 7, delayTime: 0.8,
                solutionCoords:
                [(0,5),(0,4),(0,3),(1,3),(1,2),(1,1),(1,0),(2,0),(2,1),(2,2),(2,3),(3,3),(3,4),(3,5),(3,6),],
                modifications: [(.divideAndConquer, nil)]
            ),
            LevelData(
                gridX: 4, gridY: 8, delayTime: 0.8,
                solutionCoords:
                [(3,2),(2,2),(2,3),(3,3),(3,4),(3,5),(3,6),(2,6),(1,6),(1,7),(0,7),(0,6),(0,5),(0,4),(1,4),(1,3),(1,2),(0,2),(0,1),(0,0),(1,0)],
                modifications: [(.divideAndConquer, nil)]
            )]
        levelGroups.append ((category: "Divide and Conquer", array))
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
                gridX: 4, gridY: 4, delayTime: 0.5,
                solutionCoords:
                [(0,1),(0,2),(0,3),(1,3),(2,3),(3,3),(3,2),(3,1),(3,0),(2,0),(1,0),(0,0),(0,1),(0,2),(0,3)],
                modifications: [(.thisLooksFamiliar, nil)]
            ),
            LevelData(
                gridX: 4, gridY: 5, delayTime: 0.5,
                solutionCoords:
                [(0,1),(1,1),(1,2),(2,2),(2,3),(2,4),(3,4),(3,3),(3,2),(2,2),(1,2),(0,2)],
                modifications: [(.thisLooksFamiliar, nil)]
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.5,
                solutionCoords:
                [(4,3),(4,2),(3,2),(2,2),(1,2),(1,1),(1,0),(2,0),(3,0),(3,1),(3,2),(3,3),(2,3),(1,3),(0,3)],
                modifications: [(.thisLooksFamiliar, nil)]
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.5,
                solutionCoords:
                [(3,0),(3,1),(2,1),(1,1),(1,0),(2,0),(2,1),(2,2),(2,3),(2,4),(1,4),(1,3),(2,3),(3,3),(3,4)],
                modifications: [(.thisLooksFamiliar, nil)]
            ),
            LevelData(
                gridX: 5, gridY: 6, delayTime: 0.5,
                solutionCoords:
                [(0,0),(0,1),(1,1),(1,2),(2,2),(2,1),(3,1),(3,0),(2,0),(2,1),(2,2),(2,3),(3,3),(4,3)],
                modifications: [(.thisLooksFamiliar, nil)]
            ),
            LevelData(
                gridX: 5, gridY: 6, delayTime: 0.5,
                solutionCoords:
                [(2,0),(2,1),(2,2),(2,3),(2,4),(2,5),(1,5),(1,4),(2,4),(3,4),(4,4),(4,3),(3,3),(2,3),(1,3),(1,2),(2,2),(3,2),(4,2)],
                modifications: [(.thisLooksFamiliar, nil)]
            ),
            LevelData(
                gridX: 5, gridY: 6, delayTime: 0.5,
                solutionCoords:
                [(4,2),(3,2),(2,2),(2,1),(3,1),(3,2),(3,3),(3,4),(3,5),(4,5),(4,4),(3,4),(2,4),(1,4),(0,4),(0,3),(1,3),(1,4),(1,5)],
                modifications: [(.thisLooksFamiliar, nil)]
            )]
        levelGroups.append ((category: "This Looks Familiar", array))
    }
    
    private func Spin(){
        let array = [
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.5,
                solutionCoords:
                [(2,3),(2,2),(2,1),(1,1),(0,1)],
                modifications: [(.spin, CGFloat.pi/2.0)]
            ),
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.5,
                solutionCoords:
                [(3,0),(3,1),(2,1),(2,0),(1,0),(0,0),(0,1),(0,2),(0,3)],
                modifications: [(.spin, -CGFloat.pi/2.0)]
            ),
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.5,
                solutionCoords:
                [(3,2),(3,1),(2,1),(2,2),(1,2),(1,1),(1,0),(0,0)],
                modifications: [(.spin, 3.0*CGFloat.pi/4.0)]
            ),
            LevelData(
                gridX: 4, gridY: 5, delayTime: 0.5,
                solutionCoords:
                [(0,2),(0,3),(1,3),(1,2),(1,1),(2,1),(3,1),(3,2),(3,3),(3,4)],
                modifications: [(.spin, CGFloat.pi/2.0)]
            ),
            LevelData(
                gridX: 5, gridY: 4, delayTime: 0.5,
                solutionCoords:
                [(2,0),(3,0),(4,0),(4,1),(4,2),(3,2),(2,2),(1,2),(1,1),(0,1),(0,2),(0,3)],
                modifications: [(.spin, -CGFloat.pi/2.0)]
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.5,
                solutionCoords:
                [(4,3),(3,3),(3,2),(2,2),(2,1),(1,1),(1,2),(0,2)],
                modifications: [(.spin, -3.0*CGFloat.pi/2.0)]
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.5,
                solutionCoords:
                [(2,4),(2,3),(3,3),(3,2),(3,1),(3,0),(2,0),(1,0),(1,1),(1,2),(0,2)],
                modifications: [(.spin, 2.0*CGFloat.pi)]
            ),
            LevelData(
                gridX: 6, gridY: 6, delayTime: 0.5,
                solutionCoords:
                [(0,5),(1,5),(1,4),(0,4),(0,3),(1,3),(2,3),(3,3),(4,3),(4,4),(4,5),(5,5)],
                modifications: [(.spin, 3.0*CGFloat.pi/2.0)]
            ),
            
        ]
        levelGroups.append ((category: "Spin", array))
    }
    
    func Combo1(){
        let array = [
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.5,
                solutionCoords:
                [(2,3),(3,3),(3,2),(3,1),(2,1),(1,1),(0,1),(2,2),(2,1),(2,0)],
                modifications: nil
            ),
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.5,
                solutionCoords:
                [(3,2),(2,2),(1,2),(1,3),(0,2),(0,1),(1,1),(2,1),(3,1),(3,0)],
                modifications: [(.spin, -CGFloat.pi/4.0)]
            ),
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.5,
                solutionCoords:
                [(3,2),(3,1),(2,1),(2,2),(1,2),(1,1),(1,0),(0,0)],
                modifications: [(.spin, 3.0*CGFloat.pi/4.0)]
            ),
            LevelData(
                gridX: 4, gridY: 5, delayTime: 0.5,
                solutionCoords:
                [(0,2),(0,3),(1,3),(1,2),(1,1),(2,1),(3,1),(3,2),(3,3),(3,4)],
                modifications: [(.spin, CGFloat.pi/2.0)]
            ),
            LevelData(
                gridX: 5, gridY: 4, delayTime: 0.5,
                solutionCoords:
                [(2,0),(3,0),(4,0),(4,1),(4,2),(3,2),(2,2),(1,2),(1,1),(0,1),(0,2),(0,3)],
                modifications: [(.spin, -CGFloat.pi/2.0)]
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.5,
                solutionCoords:
                [(4,3),(3,3),(3,2),(2,2),(2,1),(1,1),(1,2),(0,2)],
                modifications: [(.spin, -3.0*CGFloat.pi/2.0)]
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.5,
                solutionCoords:
                [(2,4),(2,3),(3,3),(3,2),(3,1),(3,0),(2,0),(1,0),(1,1),(1,2),(0,2)],
                modifications: [(.spin, 2.0*CGFloat.pi)]
            ),
            LevelData(
                gridX: 6, gridY: 6, delayTime: 0.5,
                solutionCoords:
                [(0,5),(1,5),(1,4),(0,4),(0,3),(1,3),(2,3),(3,3),(4,3),(4,4),(4,5),(5,5)],
                modifications: [(.spin, 3.0*CGFloat.pi/2.0)]
            )]
        levelGroups.append ((category: "Combo 1", array))
    }
    private func Jumbled(){
        let array = [
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.5,
                solutionCoords:
                [(0,1),(1,1),(2,1),(2,2),(3,2)],
                modifications: [(.jumbled, [
                        ((1,1),(1,3))
                    ])]
            ),
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.5,
                solutionCoords:
                [(0,3),(1,3),(1,2),(2,2),(3,2)],
                modifications: [(.jumbled, [
                                    ((0,3),(0,1)),
                                    ((1,3),(1,1))
                                    ]
                                )]
            ),
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.5,
                solutionCoords:
                [(3,2),(2,2),(2,1),(3,1)],
                modifications: [(.flip, nil),(.spin, CGFloat.pi)]
            ),
            LevelData(
                gridX: 4, gridY: 5, delayTime: 0.5,
                solutionCoords:
                [(0,4),(0,3),(0,2),(0,1),(1,1),(2,1),(2,0)],
                modifications: [(.jumbled,[((0,1),(1,2)),((1,1),(2,2)),((2,1),(3,2)),((2,0),(3,1))])]
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
            )
        ]
        levelGroups.append ((category: "Jumbled", array))
        
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
                modifications: [(.flip, nil), (.divideAndConquer, nil)]
            ),LevelData(
                gridX: 6, gridY: 10, delayTime: 0.7,
                solutionCoords:
                [(0,7),(1,7),(1,8),(1,9),(2,9),(3,9),(3,8),(4,8),(4,7),(4,6),(5,6),(5,5),(5,4),(4,4),(3,4),(2,4),(1,4),(1,3),(2,3),(2,2),(3,2),(4,2),(4,1),(5,1)],
                 modifications: [(.flip, nil), (.divideAndConquer, nil)]
            )]
        levelGroups.append ((category: "Huge", array))
    }
    
    private func BlockReveal(){
        let array = [
            LevelData(
                gridX: 4, gridY: 4, delayTime: 1,
                solutionCoords:
                [(2,3),(3,3),(3,2),(3,1),(2,1),(1,1),(0,1),(2,2),(2,1),(2,0)],
                modifications: [(.blockReveal, [2,3,2,10])]
                                 
                                 //[[(0,3),(0,2),(1,2),(1,3),(2,3),(2,2),(3,2),(3,3)], [(0,1),(1,1),(2,1),(3,1),(3,0),(2,0),(1,0),(0,0)]])]
            ),
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.5,
                solutionCoords:
                [(3,2),(2,2),(1,2),(1,3),(0,2),(0,1),(1,1),(2,1),(3,1),(3,0)],
                modifications: [(.spin, -CGFloat.pi/4.0)]
            ),
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.5,
                solutionCoords:
                [(3,2),(3,1),(2,1),(2,2),(1,2),(1,1),(1,0),(0,0)],
                modifications: [(.spin, 3.0*CGFloat.pi/4.0)]
            ),
            LevelData(
                gridX: 4, gridY: 5, delayTime: 0.5,
                solutionCoords:
                [(0,2),(0,3),(1,3),(1,2),(1,1),(2,1),(3,1),(3,2),(3,3),(3,4)],
                modifications: [(.spin, CGFloat.pi/2.0)]
            ),
            LevelData(
                gridX: 5, gridY: 4, delayTime: 0.5,
                solutionCoords:
                [(2,0),(3,0),(4,0),(4,1),(4,2),(3,2),(2,2),(1,2),(1,1),(0,1),(0,2),(0,3)],
                modifications: [(.spin, -CGFloat.pi/2.0)]
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.5,
                solutionCoords:
                [(4,3),(3,3),(3,2),(2,2),(2,1),(1,1),(1,2),(0,2)],
                modifications: [(.spin, -3.0*CGFloat.pi/2.0)]
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.5,
                solutionCoords:
                [(2,4),(2,3),(3,3),(3,2),(3,1),(3,0),(2,0),(1,0),(1,1),(1,2),(0,2)],
                modifications: [(.spin, 2.0*CGFloat.pi)]
            ),
            LevelData(
                gridX: 6, gridY: 6, delayTime: 0.5,
                solutionCoords:
                [(0,5),(1,5),(1,4),(0,4),(0,3),(1,3),(2,3),(3,3),(4,3),(4,4),(4,5),(5,5)],
                modifications: [(.spin, 3.0*CGFloat.pi/2.0)]
            )]
        levelGroups.append ((category: "Blocked Reveal", array))
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
