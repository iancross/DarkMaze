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
let REQUIRED_TO_UNLOCK = 1

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
    case distractions
    case multipleEndArrows
    case flash
}

class LevelsData{
    static let shared = LevelsData()
    
    var currentLevelSuccess: Bool
    var selectedLevel: (page: Int, level: Int)
    public var levelGroups = [(category: String, levels: [LevelData])]()
    
    init(){
        currentLevelSuccess = false
        //used by the gameplay if you play an earlier level
        selectedLevel = (page: 0, level: 0)
        Intro()
        Normal()
        Jump()
        LooksFamiliar() //go back over itself
        Spin()
        OutsideIn()
        MultiJump()
        WhereToEnd()
        Jumbled()
        Flip()
        Flash()
        Distraction()
        Finale()


        
        initCoreData()
        let p = mostRecentlyUnlockedPage()
        let l = nextLevelToCompleteOnPage(page: p)
        selectedLevel = (page: p, level: l ?? 0)
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
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let pageEntity = NSEntityDescription.entity(forEntityName: "Page",in: managedContext)!
        let levelEntity = NSEntityDescription.entity(forEntityName: "Level",in: managedContext)!
        for i in 0...levelGroups.count-1{
            let page = Page(entity: pageEntity, insertInto: managedContext)
            page.unlocked = false
            
            page.number = Int32(i)
            for (j, _) in levelGroups[i].levels.enumerated(){
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
                
//                if i < 6{
//                    level.completed = true
//                    level.totalAttempts = 1
//                    page.unlocked = true
//                }
//                else{
//                    level.completed = false
//                }
//
//                if i == 6 && j < 7{
//                    level.completed = true
//                }
            }
        }

        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    public func resetGame(){
        deleteCoreData()
        initCoreData()
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
                return levelsCount >= REQUIRED_TO_UNLOCK || levelsCount == levelGroups[page-1].levels.count
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
    func nextLevelToCompleteOnPage(page: Int) -> Int?{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
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
                return nil
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return nil
    }
    
    func mostRecentlyUnlockedPage() -> Int{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return 0
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Page")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "number", ascending: true)]
        do {
            if let pages = try managedContext.fetch(fetchRequest) as? [Page]{
                for page in pages{
                    print ("page is \(page.number) and the unlocked bool is \(page.unlocked)")
                    if !page.unlocked{
                        return Int(page.number)
                    }

                }
                //if all levels are completed
                return pages.count
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
        if page < levelGroups.count{
            return levelGroups[page].category
        }
        else{
            return " "
        }
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
                        
                        print ("\(selectedLevel.level) ==?? \(levelGroups[selectedLevel.page].levels.count - 1)")
                        if (selectedLevel.level == REQUIRED_TO_UNLOCK - 1 || selectedLevel.level == levelGroups[selectedLevel.page].levels.count - 1)
                            && selectedLevel.page < levelGroups.count{
                            print ("about to unlock page")
                            unlock(page: selectedLevel.page + 1)
                        }
                    }
                    else{
                        levels[0].setValue(attemptsBeforeSuccess+1, forKey: "attemptsBeforeSuccess")
                    }
                }
            }
            
            //we always update the attempts
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
    
    func unlock(page: Int){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Page")
        let pagePredicate = NSPredicate(format: "number == \(selectedLevel.page)")
        fetchRequest.predicate = pagePredicate
        
        //update completed and update attemptsBeforeSuccess
        do {
            let pages = try managedContext.fetch(fetchRequest) as [NSManagedObject]
            if let page = pages[0] as? Page {
                print ("setting page to unlocked")
                page.setValue(true, forKey: "unlocked")
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
    
    func displayFirstTimeBonus()-> Bool{
        let toTest: (page: Int, level: Int) = selectedLevel
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
            //we want bonus == true, attemptsBeforeSuccess == 0, attempts = 1
            let levels = try managedContext.fetch(fetchRequest) as [NSManagedObject]
            if let bonus = levels[0].value(forKey: "firstTimeBonus") as? Bool {
                if let attemptsBeforeSuccess = levels[0].value(forKey: "attemptsBeforeSuccess") as? Int32 {
                    if let totalAttempts = levels[0].value(forKey: "totalAttempts") as? Int32 {
                        return bonus && attemptsBeforeSuccess == 0 && totalAttempts == 1
                    }
                }
            }
            return false
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return false
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
            //we want bonus == true, attemptsBeforeSuccess == 0, attempts = 1
            let levels = try managedContext.fetch(fetchRequest) as [NSManagedObject]
            if let bonus = levels[0].value(forKey: "firstTimeBonus") as? Bool {
                if let attemptsBeforeSuccess = levels[0].value(forKey: "attemptsBeforeSuccess") as? Int32 {
                    return bonus && attemptsBeforeSuccess == 0

                }
            }
            return false
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return false
    }
    
    func getSolutionCoords(group: Int, level: Int) -> [(x: Int,y: Int)]{
        return levelGroups[group].levels[level].solutionCoords
    }

    
    private func Intro(){
        let array = [
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.45,
                solutionCoords:
                [(0,1),(1,1),(2,1),(2,2),(3,2)],
                modifications: nil
            ),
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.45,
                solutionCoords:
                [(3,3),(2,3),(1,3),(0,3),(0,2),(1,2),(1,1),(1,0)],
                modifications: nil
            )
        ]
        levelGroups.append ((category: "Intro", array))
    }
    
    private func Finale(){
        let array = [
            LevelData(
                gridX: 7, gridY: 12, delayTime: 0.4,
                solutionCoords:
                [(3,0),(3,1),(3,2),(2,2),(1,2),(0,2),(0,3),(1,3),(2,3),(2,4),(2,5),(3,5),(3,6),(3,7),(2,7),(1,7),(0,7),(0,8),(0,9),(4,9),(5,9),(6,9),(6,8),(6,7),(6,6),(6,5),(6,4),(6,3),(6,2),(6,1),(6,0)],
                modifications:
                [(.distractions, nil), (.jumbled, [
                                ((0,11),(4,11)),
                                ((1,11),(5,11)),
                                ((2,11),(6,11)),
                                ((0,10),(4,10)),
                                ((1,10),(5,10)),
                                ((2,10),(6,10)),
                                ((0,9),(4,9)),
                                ((1,9),(5,9)),
                                ((2,9),(6,9)),
                                ((0,8),(4,8)),
                                ((1,8),(5,8)),
                                ((2,8),(6,8)),
                                ((0,7),(4,7)),
                                ((1,7),(5,7)),
                                ((2,7),(6,7)),
                                ((0,6),(4,6)),
                                ((1,6),(5,6)),
                                ((2,6),(6,6)),
                                ((0,5),(4,5)),
                                ((1,5),(5,5)),
                                ((2,5),(6,5)),
                                ((0,4),(4,4)),
                                ((1,4),(5,4)),
                                ((2,4),(6,4)),
                                ((0,3),(4,3)),
                                ((1,3),(5,3)),
                                ((2,3),(6,3)),
                                ((0,2),(4,2)),
                                ((1,2),(5,2)),
                                ((2,2),(6,2)),
                                ((0,1),(4,1)),
                                ((1,1),(5,1)),
                                ((2,1),(6,1)),
                                ((0,0),(4,0)),
                                ((1,0),(5,0)),
                                ((2,0),(6,0))
                                ])
                            ]
            ),
            LevelData(
                gridX: 7, gridY: 12, delayTime: 0.35,
                solutionCoords:
                [(6,4),(5,4),(4,4),(3,4),(2,4),(2,5),(2,6),(2,7),(3,7),(4,7),(4,6),(4,5),(3,5),(3,6),(3,7),(3,8),(3,9),(3,10),(2,10),(2,9),(3,9),(4,9),(3,2),(2,2),(1,2),(0,2),(0,1),(1,1),(2,1),(3,1),(4,1),(5,1),(5,2),(6,2)],
                modifications: [(.multipleEndArrows, [(6,3),(6,1)]),(.flip, false)]
            ),
            LevelData(
                gridX: 7, gridY: 11, delayTime: 0.35,
                solutionCoords:
                [(6,4),(5,4),(5,3),(4,2),(3,2),(3,1),(2,0),(1,0),(1,1),(1,2),(1,3),(1,4),(1,5),(2,5),(2,6),(2,7),(2,8),(2,9),(1,9),(0,9),(0,8),(0,7),(1,7),(2,7),(3,7),(4,7),(4,8),(4,9),(4,10),(5,10),(5,9),(6,9)],
                modifications: [(.meetInTheMiddle, nil),(.multipleEndArrows, [(6,2),(6,1),(6,0),(5,0),(4,0),(3,0),(2,0),(1,0),(0,0),(0,1),(0,2),(0,3),(0,4),(0,5),(0,6),(0,7),(0,8),(0,9),(0,10),(1,10),(2,10),(3,10),(4,10),(5,10),(6,10),(6,8),(6,7),(6,6),])]
            ),
            LevelData(
                gridX: 7, gridY: 11, delayTime: 0.35,
                solutionCoords:
                [(6,10),(5,10),(5,9),(5,8),(5,7),(5,6),(3,4),(4,4),(1,7),(1,6),(0,6),(0,5),(0,4),(1,4),(1,3),(5,3),(5,4),(5,5),(4,5),(3,5),(2,5),(2,4),(2,3),(2,2),(6,5),(6,6),(6,7),(5,7),(4,7),(3,7),(3,8),(3,9),(4,9),(5,9),(6,9),(6,8),(5,8),(4,8),(3,8),(2,8),(1,8),(1,9),(0,9)],
                modifications: [(.distractions, nil)]
            ),
            LevelData(
                gridX: 7, gridY: 11, delayTime: 0.35,
                solutionCoords:
                [(6,5),(5,5),(4,5),(3,5),(3,4),(2,4),(2,3),(3,3),(3,2),(4,2),(5,2),(5,1),(5,0),(4,0),(3,0),(2,0),(2,1),(1,1),(0,1),(0,2),(0,3),(0,4),(0,5),(0,6),(1,6),(2,6),(3,6),(4,6),(4,7),(5,7),(5,8),(5,9),(5,10)],
                modifications: [(.flip, false),(.spin, CGFloat.pi)]
            ),
            
            LevelData(
                gridX: 7, gridY: 7, delayTime: 0.35,
                solutionCoords:
                [(6,3),(5,3),(4,3),(2,3),(1,3),(0,3),(5,0),(5,1),(5,2),(5,3),(5,4),(5,5),(5,6),(2,0),(2,1),(2,2),(1,4),(1,5),(1,6),(0,2),(1,2),(2,2),(3,2),(4,1),(5,1),(6,1),(6,2),(6,3),(6,4),(6,5),(6,6)],
                modifications: [(.spin, -CGFloat.pi), (.flip, false)]
            ),
            LevelData(
                gridX: 7, gridY: 12, delayTime: 0.35,
                solutionCoords:
                [(4,11),(5,11),(6,11),(6,10),(5,10),(5,9),(5,8),(5,7),(2,7),(2,8),(2,9),(3,9),(3,3),(3,4),(3,5),(4,5),(6,3),(6,2),(5,2),(4,2),(3,2),(3,1),(2,1),(2,2),(1,2),(1,3),(2,3),(2,4),(2,5),(2,6),(3,6),(3,7),(3,8),(4,8),(4,9),(4,10),(3,10),(3,11)],
                modifications: [(.distractions, nil)]
            ),
                        LevelData(
                            gridX: 7, gridY: 12, delayTime: 0.4,
                            solutionCoords:
                            [(0,0)],
                            modifications: [(.flip, true), (.spin, CGFloat.pi), (.flip, false)]
                        )

        ]
        levelGroups.append ((category: "Finale", array))
    }
    
    private func Distraction(){
        let array = [
            
            LevelData(
                gridX: 7, gridY: 7, delayTime: 0.45,
                solutionCoords:
                [(0,3),(1,3),(2,3),(3,3),(3,2),(3,1),(2,1),(1,1),(1,2),(1,3),(1,4),(1,5),(2,0),(3,0),(4,0),(4,1),(4,2),(5,2),(5,1),(5,0),(6,2),(6,3)],
                modifications: [(.distractions, nil)]
            ),
            LevelData(
                gridX: 7, gridY: 7, delayTime: 0.45,
                solutionCoords:
                [(3,6),(3,5),(4,5),(4,4),(5,4),(5,3),(5,2),(4,2),(2,5),(2,4),(3,4),(3,3),(4,3),(5,3),(6,3),(6,2),(6,1),(5,1),(4,1),(3,1),(3,0)],
                modifications: [(.distractions, nil)]
            ),
            LevelData(
                gridX: 7, gridY: 7, delayTime: 0.45,
                solutionCoords:
                [(4,6),(5,6),(5,5),(6,5),(6,4),(5,4),(5,3),(5,2),(5,1),(6,1),(0,3),(0,2),(1,2),(1,1),(1,0),(2,0),(2,1),(3,1),(3,2),(3,3),(3,4),(3,5),(3,6)],
                modifications: [(.distractions, nil)]
            ),
            LevelData(
                gridX: 7, gridY: 7, delayTime: 0.45,
                solutionCoords:
                [(6,2),(6,3),(5,3),(4,3),(4,4),(5,4),(5,5),(4,5),(3,5),(2,5),(2,6),(3,6),(0,3),(0,2),(0,1),(1,1),(1,2),(2,2),(2,1),(2,0),(3,0),(4,0),(5,0),(6,0)],
                modifications: [(.distractions, nil), (.multipleEndArrows, [(5,6),(0,6),(0,4)])]
            ),
            LevelData(
                gridX: 7, gridY: 7, delayTime: 0.45,
                solutionCoords:
                [(0,1),(1,1),(1,2),(2,2),(3,2),(3,3),(4,3),(4,4),(3,4),(2,4),(1,4),(1,5),(0,5),(0,6),(1,6),(2,6),(3,6),(4,6),(5,6),(5,5),(5,4),(5,3),(5,2),(5,1),(5,0)],
                modifications: [(.jumbled, [
                                ((1,2),(2,1)),
                                ((0,4),(2,5)),
                                ((4,0),(6,0)),
                                ((4,5),(6,5)),
                                ]),
                                (.distractions, nil)]
            ),
            LevelData(
                gridX: 7, gridY: 7, delayTime: 0.45,
                solutionCoords:
                [(0,3),(1,3),(1,2),(5,1),(4,1),(4,2),(5,2),(6,2),(4,6),(3,6),(3,5),(4,5),(5,5),(6,5),(1,5),(1,6)],
                modifications: [(.distractions, nil)]
            ),
            LevelData(
                gridX: 7, gridY: 7, delayTime: 0.45,
                solutionCoords:
                [(6,5),(6,4),(6,3),(5,3),(4,3),(3,3),(2,3),(2,4),(2,5),(3,5),(4,5),(5,5),(5,4),(5,3),(5,2),(5,1),(5,0),(4,0),(4,1),(4,2),(4,3),(4,4),(4,5),(4,6),(3,6),(3,5),(3,4),(3,3),(3,2),(3,1),(2,1),(2,0),(1,0),(1,1),(0,1)],
                modifications: [(.distractions, nil)]
            ),
            LevelData(
                gridX: 7, gridY: 7, delayTime: 0.3,
                solutionCoords:
                [(6,0),(5,0),(4,0),(3,0),(2,0),(1,0),(0,0),(0,1),(1,1),(2,1),(3,1),(4,1),(5,1),(6,1),(6,2),(6,3),(6,4),(6,5),(6,6),(5,6),(4,6),(3,6),(3,5),(4,5),(5,5),(5,4),(4,4),(3,4),(2,4),(2,5),(2,6),(1,6),(0,6),(0,5),(1,5),(1,4),(1,3),(2,3),(3,3),(4,3),(5,3),(5,2),(4,2),(3,2),(2,2),(1,2),(0,2),(0,3),(0,4),],
                modifications: [(.distractions, nil)]
            )
        ]
        levelGroups.append ((category: "Distractions", array))
    }
    
    //Description:
    //Easiest level to show how to play the game. Probably going to do all sorts of
    //directions to show the maze functionality
    private func Normal(){
        let array = [
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.45,
                solutionCoords:
                [(2,0),(2,1),(2,2),(1,2),(1,3)],
                 modifications: nil
            ),
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.45,
                solutionCoords:
                [(0,3),(1,3),(1,2),(1,1),(2,1),(2,0)],
                 modifications: nil
            ),
//            LevelData(
//                gridX: 4, gridY: 4, delayTime: 0.45,
//                solutionCoords:
//                [(3,3),(3,2),(3,1),(2,1),(1,1),(0,1),(0,0)],
//                 modifications: nil
//            ),
//            LevelData(
//                gridX: 4, gridY: 5, delayTime: 0.45,
//                solutionCoords:
//                [(0,2),(0,1),(1,1),(1,2),(2,2),(2,3),(2,4),(3,4)],
//                 modifications: nil
//            ),
//            LevelData(
//                gridX: 5, gridY: 5, delayTime: 0.45,
//                solutionCoords:
//                [(4,0),(4,1),(4,2),(4,3),(3,3),(3,2),(2,2),(2,1),(1,1),(0,1)],
//                 modifications: nil
//            ),
//            LevelData(
//                gridX: 5, gridY: 5, delayTime: 0.45,
//                solutionCoords:
//                [(2,4),(2,3),(3,3),(3,2),(3,1),(3,0),(2,0),(1,0),(1,1),(1,2),(0,2)],
//                 modifications: nil
//            ),
//            LevelData(
//                gridX: 5, gridY: 6, delayTime: 0.45,
//                solutionCoords:
//                [(1,5),(1,4),(0,4),(0,3),(1,3),(2,3),(3,3),(4,3),(4,2),(3,2),(2,2),(2,1),(2,0)],
//                 modifications: nil
//            ),
//            LevelData(
//                gridX: 5, gridY: 6, delayTime: 0.45,
//                solutionCoords:
//                [(0,0),(0,1),(0,2),(0,3),(0,4),(0,5),(1,5),(2,5),(3,5),(4,5),(4,4),(4,3),(3,3),(2,3),(2,2),(2,1),(2,0),(3,0),(4,0),(4,1)],
//                 modifications: nil
//            )
        ]
        levelGroups.append ((category: "Normal", array))
        
    }
    private func Jump(){
        let array = [
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.45,
                solutionCoords:
                [(0,0),(1,0),(2,0),(3,0),(3,1),(1,2),(1,3),(2,3),(3,3)],
                modifications: nil
            ),
            LevelData(
                gridX: 4, gridY: 5, delayTime: 0.45,
                solutionCoords:
                [(3,0),(2,0),(1,0),(0,0),(0,1),(1,1),(2,2),(1,2),(1,3),(2,3),(3,3)],
                modifications: nil
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.45,
                solutionCoords:
                [(4,3),(3,3),(3,4),(2,4),(1,4),(0,4),(0,3),(2,2),(2,1),(3,1),(3,0)],
                 modifications: nil
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.45,
                solutionCoords:
                [(2,0),(2,1),(1,1),(1,2),(0,2),(4,2),(3,2),(3,3),(2,3),(2,4),(1,4),(0,4)],
                 modifications: nil
            ),
            LevelData(
                gridX: 5, gridY: 6, delayTime: 0.45,
                solutionCoords:
                [(0,4),(0,3),(1,3),(2,3),(4,1),(3,1),(3,0),(2,0),(1,0),(1,1),(0,1)],
                modifications: nil
            ),
            LevelData(
                gridX: 5, gridY: 6, delayTime: 0.45,
                solutionCoords:
                [(4,0),(4,1),(3,1),(3,0),(2,0),(1,0),(1,1),(3,4),(3,3),(4,3),(4,2),(3,2),(2,2),(1,2),(0,2)],
                 modifications: nil
            ),
            LevelData(
                gridX: 6, gridY: 6, delayTime: 0.45,
                solutionCoords:
                [(4,5),(4,4),(3,4),(2,4),(1,4),(1,3),(1,2),(1,1),(1,0),(0,0),(3,2),(3,1),(3,0),(4,0),(4,1),(5,1)],
                 modifications: nil
            ),
            LevelData(
                gridX: 6, gridY: 7, delayTime: 0.45,
                solutionCoords:
                [(2,6),(2,5),(1,5),(0,5),(0,4),(0,3),(1,3),(4,2),(4,3),(5,3),(5,2),(5,1),(4,1),(3,1),(3,2),(3,3),(3,4),(4,4),(5,4)],
                 modifications: nil
            )

        ]
        
        levelGroups.append ((category: "Jump", array))
    }
    
    //might need to review these again
    private func LooksFamiliar(){
        let array = [
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.45,
                solutionCoords:
                [(3,3),(3,2),(2,2),(2,1),(2,0),(1,0),(1,1),(2,1),(3,1)],
                modifications: [(.thisLooksFamiliar, nil)]
            ),
            LevelData(
                gridX: 4, gridY: 5, delayTime: 0.45,
                solutionCoords:
                [(0,1),(1,1),(1,2),(2,2),(2,3),(2,4),(3,4),(3,3),(3,2),(2,2),(1,2),(0,2)],
                modifications: [(.thisLooksFamiliar, nil)]
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.45,
                solutionCoords:
                [(4,3),(4,2),(3,2),(2,2),(1,2),(1,1),(1,0),(2,0),(3,0),(3,1),(3,2),(3,3),(2,3),(1,3),(0,3)],
                modifications: [(.thisLooksFamiliar, nil)]
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.45,
                solutionCoords:
                [(3,0),(3,1),(2,1),(1,1),(1,0),(2,0),(2,1),(2,2),(2,3),(2,4),(1,4),(1,3),(2,3),(3,3),(3,4)],
                modifications: [(.thisLooksFamiliar, nil)]
            ),
            LevelData(
                gridX: 5, gridY: 6, delayTime: 0.45,
                solutionCoords:
                [(0,0),(0,1),(1,1),(1,2),(2,1),(3,1),(4,1),(4,0),(3,0),(3,1),(3,2),(3,3),(3,4),(4,4)],
                modifications: [(.thisLooksFamiliar, nil)]
            ),
            LevelData(
                gridX: 5, gridY: 6, delayTime: 0.45,
                solutionCoords:
                [(4,3),(3,3),(2,3),(1,3),(0,3),(3,2),(3,3),(3,4),(2,4),(1,4),(1,3),(1,2),(1,1),(2,1),(2,0)],
                modifications: [(.thisLooksFamiliar, nil)]
            ),
            LevelData(
                gridX: 5, gridY: 7, delayTime: 0.45,
                solutionCoords:
                [(0,4),(0,3),(1,3),(1,2),(2,2),(3,2),(4,2),(4,3),(4,4),(3,4),(2,4),(2,3),(2,2),(2,1),(1,1),(1,0),(0,0)],
                modifications: [(.thisLooksFamiliar, nil)]
            ),
            LevelData(
                gridX: 5, gridY: 7, delayTime: 0.45,
                solutionCoords:
                [(4,0),(3,0),(2,0),(2,1),(3,1),(3,2),(4,2),(4,3),(4,4),(0,6),(0,5),(0,4),(1,4),(2,4),(3,4),(3,3),(4,3)],
                modifications: [(.thisLooksFamiliar, nil)]
            )]
        levelGroups.append ((category: "Looks Familiar", array))
    }
    
    
    private func Spin(){
        let array = [
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.45,
                solutionCoords:
                [(2,3),(2,2),(2,1),(1,1),(0,1)],
                modifications: [(.spin, CGFloat.pi/2.0)]
            ),
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.45,
                solutionCoords:
                [(3,0),(3,1),(2,1),(2,0),(1,0),(0,0),(0,1),(0,2),(0,3)],
                modifications: [(.spin, -CGFloat.pi/2.0)]
            ),
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.45,
                solutionCoords:
                [(3,2),(3,1),(2,1),(2,2),(1,2),(1,1),(1,0),(0,0)],
                modifications: [(.spin, 3.0*CGFloat.pi/4.0)]
            ),
            LevelData(
                gridX: 4, gridY: 5, delayTime: 0.45,
                solutionCoords:
                [(0,2),(0,3),(1,3),(1,2),(1,1),(2,1),(3,1),(3,2),(3,3),(3,4)],
                modifications: [(.spin, CGFloat.pi/2.0)]
            ),
            LevelData(
                gridX: 5, gridY: 4, delayTime: 0.45,
                solutionCoords:
                [(3,0),(3,1),(3,2),(3,3),(2,3),(2,2),(3,2),(4,2),(4,1),(3,1),(2,1),(1,1),(0,1)],
                modifications: [(.spin, -CGFloat.pi/2.0)]
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.45,
                solutionCoords:
                [(4,3),(4,2),(3,2),(1,3),(0,3),(0,2),(0,1),(1,1),(1,0)],
                modifications: [(.spin, 3.0*CGFloat.pi/4.0)]
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.45,
                solutionCoords:
                [(3,0),(3,1),(3,2),(2,2),(2,1),(3,1),(4,1),(1,2),(1,3),(2,3),(2,4)],
                modifications: [(.spin, CGFloat.pi/2.0)]
            ),
            LevelData(
                gridX: 6, gridY: 6, delayTime: 0.45,
                solutionCoords:
                [(0,5),(1,5),(2,5),(2,4),(2,3),(2,2),(1,2),(1,3),(2,3),(3,3),(4,3),(5,3),(5,4),(4,4),(4,2),(4,1),(4,0)],
                modifications: [(.spin, -CGFloat.pi/2.0)]
            ),
            
            ]
        levelGroups.append ((category: "Spin", array))
    }

    private func OutsideIn(){
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
                modifications: [(.spin, -CGFloat.pi/2.0),(.meetInTheMiddle, nil)]//, ]
            ),
            LevelData(   //5
                gridX: 5, gridY: 6, delayTime: 0.9,
                solutionCoords:
                [(4,3),(3,3),(3,2),(4,2),(4,1),(4,0),(3,0),(2,0),(1,0),(1,1),(1,2),(0,2),(0,3),(0,4),(1,4),(2,4),(2,5)],
                modifications: [(.meetInTheMiddle, nil)]
            ),
            LevelData(
                gridX: 4, gridY: 7, delayTime: 0.8,
                solutionCoords:
                [(0,5),(0,4),(0,3),(1,3),(1,2),(1,1),(1,0),(2,0),(2,1),(2,2),(2,3),(3,3),(3,4),(3,5),(3,6)],
                modifications: [(.meetInTheMiddle, nil), (.spin, CGFloat.pi)]
            ),
            LevelData(
                gridX: 5, gridY: 6, delayTime: 0.9,
                solutionCoords:
                [(0,0),(1,0),(2,0),(3,0),(4,0),(4,1),(3,1),(1,1),(0,1),(0,2),(1,2),(2,2),(3,2),(3,3),(3,4),(2,4),(1,4),(0,4),(0,5),(1,5)],
                modifications: [(.meetInTheMiddle, nil)]
            ),
            LevelData(
                gridX: 4, gridY: 7, delayTime: 0.8,
                solutionCoords:
                [(0,0),(0,1),(1,1),(2,1),(2,2),(2,3),(2,4),(0,6),(1,6),(1,5),(1,4),(1,3),(2,3),(3,3)],
                modifications: [(.meetInTheMiddle, nil)]
            )]
        levelGroups.append ((category: "Outside In", array))
    }
    
    func MultiJump(){
        let array = [
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.45,
                solutionCoords:
                [(0,0),(2,0),(3,0),(3,1),(1,2),(1,3),(2,3),(3,3)],
                modifications: nil
            ),
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.45,
                solutionCoords:
                [(2,0),(2,1),(2,3),(1,3),(1,2),(1,1),(3,2),(2,2),(1,2),(0,2)],
                modifications: nil
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.45,
                solutionCoords:
                [(0,0),(1,0),(3,1),(4,1),(4,2),(0,3),(1,3),(2,3),(3,4),(2,4),(1,4)],
                modifications: nil
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.45,
                solutionCoords:
                [(0,2),(1,2),(2,2),(2,1),(2,0),(4,3),(3,3),(2,3),(1,3),(0,3),(4,0),(3,0),(3,1),(3,2),(3,3),(3,4)],
                modifications: nil
            ),
            LevelData(
                gridX: 5, gridY: 6, delayTime: 0.45,
                solutionCoords:
                [(1,5),(1,4),(2,4),(3,4),(4,2),(3,2),(3,1),(4,1),(4,0),(4,3),(3,3),(2,3),(1,3),(1,2),(0,2),(0,1),(1,1),(2,1),(2,2),(2,3),(2,4),(2,5),],
                modifications: nil
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.45,
                solutionCoords:
                [(1,0),(2,0),(3,0),(4,2),(4,1),(3,4),(2,4),(1,4),(2,2),(1,2),(0,2)],
                modifications: [(.spin, CGFloat.pi/2.0)]
            ),
            LevelData(
                gridX: 6, gridY: 6, delayTime: 0.45,
                solutionCoords:
                [(0,0),(1,0),(2,0),(3,0),(4,0),(4,1),(4,2),(4,3),(4,4),(0,2),(1,2),(2,2),(2,3),(2,4),(1,5),(1,4),(0,4)],
                modifications: [(.meetInTheMiddle, nil)]
            ),
            LevelData(
                gridX: 6, gridY: 6, delayTime: 0.35,
                solutionCoords:
                [(0,0),(0,1),(0,2),(1,2),(2,2),(3,2),(3,1),(3,0),(2,0),(1,0),(2,1),(3,1),(4,1),(4,2),(4,3),(3,3),(2,3),(1,3),(1,2),(1,1),(0,3),(0,4),(0,5),(1,5),(1,4),(2,4),(3,4),(4,4),(5,4),(5,3),(5,2),(5,1),(5,0),(4,0),(2,5),(3,5),(4,5),(5,5)],
                modifications: nil
            )
            
        ]
        
        levelGroups.append ((category: "Multi-Jump", array))
    }
    
    
    //LEFT OFF HERE FOR LEVEL DESIGN~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    
    
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
    

    
    private func Jumbled(){
        let array = [
            LevelData(
                gridX: 4, gridY: 5, delayTime: 0.45,
                solutionCoords:
                [(2,4),(1,4),(1,3),(2,3),(2,2),(3,2),(3,1),(3,0)],
                modifications: [(.jumbled, [
                                ((3,2),(1,2)),
                                ((3,1),(1,1)),
                                ((3,0),(1,0)),
                                ]
                )]
            ),
            LevelData(
                gridX: 4, gridY: 5, delayTime: 0.45,
                solutionCoords:
                [(1,0),(1,1),(2,0),(2,1),(3,1),(3,2),(2,2),(2,3),(2,4),(3,4)],
                modifications: [(.jumbled, [
                                ((0,1),(2,0)),
                                ((0,2),(2,1)),
                                ((1,2),(3,1)),
                                ]),
                                (.multipleEndArrows, [(1,4)]
                )]
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.45,
                solutionCoords:
                [(0,3),(0,2),(1,2),(1,1),(2,1),(2,0),(3,0),(4,0),(4,1),(2,3),(3,3),(3,4)],
                modifications: [(.jumbled, [
                                ((0,1),(1,2)),
                                ((0,0),(1,1)),
                                ((1,0),(2,1)),
                                ((2,3),(3,2)),
                                ((3,3),(4,2)),
                                ((3,4),(4,3))
                                ]
                )]
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.45,
                solutionCoords:
                [(2,0),(2,1),(0,2),(0,3),(0,4),(1,2),(1,1),(1,0),(3,1),(3,0)],
                modifications: [(.jumbled, [
                                ((0,4),(2,4)),
                                ((0,3),(2,3)),
                                ((0,2),(2,2)),
                                ((1,1),(3,3)),
                                ((1,0),(3,2)),
                                ((1,2),(3,4))
                                ]
                )]
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.45,
                solutionCoords:
                [(1,4),(1,3),(1,2),(0,2),(0,3),(1,3),(2,3),(4,0),(4,1),(4,2),(4,3)],
                modifications: [(.jumbled, [
                                ((4,2),(3,1)),
                                ((2,1),(4,3))
                                ]),
                                (.multipleEndArrows, [(2,0),(4,4),(4,3)])
                ]
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.45,
                solutionCoords:
                [(0,1),(1,1),(1,2),(1,3),(1,4),(2,4),(2,3),(3,3),(4,3)],
                modifications: [(.jumbled, [
                                ((3,3),(3,0)),
                                ((4,3),(2,0))
                                ]),
                                (.multipleEndArrows, [(3,0)]),
                                (.spin,  -CGFloat.pi/4.0)
                ]
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.45,
                solutionCoords:
                [(1,4),(1,3),(2,3),(3,3),(3,2),(2,2),(1,2),(0,2),(0,1),(0,0),(1,0),(2,0),(3,0)],
                modifications: [(.jumbled, [
                    ((0,3),(0,1)),
                    ((1,2),(1,0)),
                    ((1,3),(1,1)),
                    ((2,2),(2,0)),
                    ((2,3),(2,1)),
                    ((3,2),(3,0)),
                    ((3,3),(3,1)),
                    ((4,2),(4,0)),
                    ((4,3),(4,1)),
                    ((0,2),(0,0))
                    ]
                    )]
            ),
            LevelData(
                gridX: 6, gridY: 6, delayTime: 0.45,
                solutionCoords:
                [(5,4),(4,4),(3,4),(0,4),(1,4),(2,4),(2,5),(1,5),(1,0),(1,1),(0,1),(3,1),(4,1),(5,1),],
                modifications: [(.jumbled, [
                                ((0,2),(3,5)),
                                ((0,1),(3,4)),
                                ((0,0),(3,3)),
                                ((1,2),(4,5)),
                                ((1,1),(4,4)),
                                ((1,0),(4,3)),
                                ((2,2),(5,5)),
                                ((2,1),(5,4)),
                                ((2,0),(5,3)),
                                ((0,5),(3,2)),
                                ((0,4),(3,1)),
                                ((0,3),(3,0)),
                                ((1,5),(4,2)),
                                ((1,4),(4,1)),
                                ((1,3),(4,0)),
                                ((2,5),(5,2)),
                                ((2,4),(5,1)),
                                ((2,3),(5,0))
                                ]
                )]
            )
        ]
        levelGroups.append ((category: "Jumbled", array))
        
    }
    private func Flip(){
        let array = [
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.45,
                solutionCoords:
                [(1,3),(0,3),(0,2),(1,2),(2,2),(3,2),(1,1),(1,0),(2,0),(2,1),(2,2),(2,3)],
                modifications: [(.flip, true)]
            ),
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.45,
                solutionCoords:
                [(0,1),(0,0),(1,0),(1,1),(2,1),(3,1),(3,2),(2,2),(1,2),(1,3)],
                modifications: [(.meetInTheMiddle, nil),(.flip, false)]
            ),
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.45,
                solutionCoords:
                [(1,3),(2,3),(2,2),(2,1),(3,1),(3,2),(2,2),(1,2),(2,0),(1,0),(0,0)],
                modifications: [(.flip, false)]
            ),
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.45,
                solutionCoords:
                [(0,1),(1,1),(2,1),(2,0),(3,0),(3,1)],
                modifications: [(.spin, CGFloat.pi/2),(.flip, false)]
            ),
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.45,
                solutionCoords:
                [(3,2),(3,1),(2,1),(2,2),(1,2),(1,1),(1,0),(0,0)],
                modifications: [(.spin, -CGFloat.pi/4),(.flip, true)]
            ),
            LevelData(
                gridX: 4, gridY: 6, delayTime: 0.45,
                solutionCoords:
                [(2,5),(2,4),(2,3),(3,3),(3,2),(3,1),(3,0),(2,0),(1,0),(1,1),(1,2),(0,2)],
                modifications: [(.flip, false),(.flip, true)]
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.45,
                solutionCoords:
                [(3,4),(3,3),(1,0),(1,1),(1,2),(2,4),(1,4),(0,4),(3,1),(3,2),(4,2),(4,1)],
                modifications: [(.jumbled, [
                                ((1,2),(2,2)),
                                ((1,1),(2,1)),
                                ((1,0),(2,0))
                                ]),
                                (.multipleEndArrows, [(4,3)]),
                                (.flip, true)
                ]
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.45,
                solutionCoords:
                [(0,3),(0,2),(0,1),(1,1),(2,1),(3,1),(3,2),(3,3),(3,4),(2,4),(1,4),(0,4),(1,2),(1,3),(2,3),(2,2),(2,0),(1,0)],
                modifications: [(.jumbled, [
                                ((1,0),(3,0)),
                                ((2,0),(4,0)),
                                ((3,4),(4,3)),
                                ((3,3),(4,2))
                                ]),
                                (.flip, false)
                ]
            )
        ]
        levelGroups.append ((category: "Flip", array))
    }
    
    private func Blackout(){
        let array = [
            LevelData(
                gridX: 3, gridY: 3, delayTime: 0.45,
                solutionCoords:[(0,2),(0,1),(0,0),(1,0),(1,1),(1,2),(2,2),(2,1),(2,0)],
                 modifications: nil
            ),
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.45,
                solutionCoords:[(0,0),(1,0),(1,1),(2,1),(2,0),(3,0),(3,1),(3,2),(3,3),(2,3),(2,2),(1,2),(1,3),(0,3),(0,2),(0,1)],
                 modifications: nil
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.45,
                solutionCoords:
                [(4,0),(3,0),(2,0),(2,1),(2,2),(1,2),(1,1),(1,0),(0,0),(0,1),(0,2),(0,3),(0,4),(1,4),(1,3),(2,3),(3,3),(3,2),(3,1),(4,1),(4,2),(4,3),(4,4),(3,4),(2,4)],
                 modifications: nil
            )
        ]
        levelGroups.append ((category: "Blackout", array))
    }
    
    private func BlockReveal(){
        let array = [
            LevelData(
                gridX: 4, gridY: 4, delayTime: 1,
                solutionCoords:
                [(2,3),(3,3),(3,2),(3,1),(2,1),(1,1),(0,1),(2,2),(2,1),(2,0)],
                modifications: [(.blockReveal, [2,3,2,10])]
            ),
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.45,
                solutionCoords:
                [(3,2),(2,2),(1,2),(1,3),(0,2),(0,1),(1,1),(2,1),(3,1),(3,0)],
                modifications: [(.spin, -CGFloat.pi/4.0)]
            ),
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.45,
                solutionCoords:
                [(3,2),(3,1),(2,1),(2,2),(1,2),(1,1),(1,0),(0,0)],
                modifications: [(.spin, 3.0*CGFloat.pi/4.0)]
            ),
            LevelData(
                gridX: 4, gridY: 5, delayTime: 0.45,
                solutionCoords:
                [(0,2),(0,3),(1,3),(1,2),(1,1),(2,1),(3,1),(3,2),(3,3),(3,4)],
                modifications: [(.spin, CGFloat.pi/2.0)]
            ),
            LevelData(
                gridX: 5, gridY: 4, delayTime: 0.45,
                solutionCoords:
                [(2,0),(3,0),(4,0),(4,1),(4,2),(3,2),(2,2),(1,2),(1,1),(0,1),(0,2),(0,3)],
                modifications: [(.spin, -CGFloat.pi/2.0)]
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.45,
                solutionCoords:
                [(4,3),(3,3),(3,2),(2,2),(2,1),(1,1),(1,2),(0,2)],
                modifications: [(.spin, -3.0*CGFloat.pi/2.0)]
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.45,
                solutionCoords:
                [(2,4),(2,3),(3,3),(3,2),(3,1),(3,0),(2,0),(1,0),(1,1),(1,2),(0,2)],
                modifications: [(.spin, 2.0*CGFloat.pi)]
            ),
            LevelData(
                gridX: 6, gridY: 6, delayTime: 0.45,
                solutionCoords:
                [(0,5),(1,5),(1,4),(0,4),(0,3),(1,3),(2,3),(3,3),(4,3),(4,4),(4,5),(5,5)],
                modifications: [(.spin, 3.0*CGFloat.pi/2.0)]
            )]
        levelGroups.append ((category: "Blocked Reveal", array))
    }
    
    
    private func WhereToEnd(){
        let array = [
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.45,
                solutionCoords: [(3,3),(3,2),(3,1),(3,0),(2,0),(2,1),(2,2),(1,2),(0,2),(0,1)],
                modifications: [(.multipleEndArrows, [(0,3)])]
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.45,
                solutionCoords:
                [(1,0),(2,0),(3,0),(3,1),(2,1),(2,3),(1,3),(0,3),(0,2),(1,2),(1,3),(1,4),(2,4)],
                modifications: [(.multipleEndArrows,[(0,4)])]
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.45,
                solutionCoords:
                [(0,1),(1,1),(2,1),(2,2),(2,3),(1,3),(0,3),(0,4),(1,4),(4,3),(4,2),(4,1),(3,1),(3,0),(2,0)],
                modifications: [(.multipleEndArrows,[(4,0)])]
            ),
            LevelData(
                gridX: 6, gridY: 6, delayTime: 0.45,
                solutionCoords:
                [(5,3),(4,3),(3,3),(3,4),(3,5),(4,5),(4,4),(3,4),(2,4),(4,1),(3,1),(3,0),(4,0),(5,0),(5,1),(5,2),(4,2),(3,2),(2,2),(2,1),(1,1),(0,1),(0,2)],
                modifications: [(.multipleEndArrows,[(0,1),(0,0)])]
            ),
            LevelData(
                gridX: 4, gridY: 4, delayTime: 0.45,
                solutionCoords:
                [(3,0),(2,0),(1,0),(1,1),(2,1),(3,1),(3,2),(3,3),(2,3),(1,3),(1,2),(0,2),(0,1)],
                modifications: [(.spin, CGFloat.pi/2.0),(.multipleEndArrows,[(0,1),(0,3)])]
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.45,
                solutionCoords:
                [(4,0),(3,0),(3,1),(4,1),(2,1),(2,2),(2,3),(3,3),(3,2),(2,2),(1,2),(1,3),(1,4)],
                modifications: [(.spin, -CGFloat.pi/2.0),(.multipleEndArrows,[(0,2),(1,0)])]
            ),
            LevelData(
                gridX: 4, gridY: 6, delayTime: 0.45,
                solutionCoords:
                [(3,5),(2,5),(1,5),(0,4),(0,3),(1,3),(1,4),(2,4),(2,3),(2,2),(1,2),(1,1),(2,1),(2,0)],
                modifications: [(.multipleEndArrows,[(0,1),(0,0),(1,0)])]
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.45,
                solutionCoords:
                [(4,2),(4,1),(3,1),(2,1),(2,2),(2,3),(1,3),(0,3),(0,2),(1,2),(2,2),(3,2),(3,1),(3,0),(2,0),(1,0)],
                modifications: [(.spin, -CGFloat.pi/4.0),(.multipleEndArrows,[(2,0),(3,0),(4,0)])]
            )]
        levelGroups.append ((category: "Where To End", array))
    }
    
    
    private func Flash(){
        let array = [
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.45,
                solutionCoords:
                [(0,3),(0,4),(1,4),(2,4),(3,4),(3,3),(3,2),(3,1),(3,0),(2,0),(1,0),(1,1),(1,2),(2,2),(3,2),(4,2)],
                modifications: [(.flash, nil)]
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.45,
                solutionCoords:
                [(4,0),(3,0),(3,1),(2,1),(1,1),(1,0),(0,4),(0,3),(1,3),(2,3),(2,4),(3,4),(4,4)],
                modifications: [(.flash, nil)]
            ),
            LevelData(
                gridX: 6, gridY: 5, delayTime: 0.45,
                solutionCoords:
                [(4,0),(5,0),(5,1),(5,2),(5,3),(4,3),(4,2),(3,2),(2,2),(1,2),(0,2),(0,3),(0,4),(1,4),(2,4),(1,0),(2,0),(3,0)],
                modifications: [(.flash, nil)]
            ),
            LevelData(
                gridX: 6, gridY: 6, delayTime: 0.45,
                solutionCoords:
                [(5,5),(5,4),(5,3),(5,2),(5,1),(5,0),(4,0),(3,0),(2,0),(1,0),(1,1),(1,2),(1,3),(2,3),(3,3),(3,2),(2,5),(1,5),(0,5),(0,4)],
                modifications: [(.flash, nil),(.flip, true)]
            ),
            LevelData(
                gridX: 6, gridY: 7, delayTime: 0.45,
                solutionCoords:
                [(5,6),(4,6),(3,6),(2,6),(2,5),(2,4),(2,3),(2,2),(1,2),(0,2),(0,3),(0,4),(1,4),(2,4),(3,4),(4,4),(4,3),(5,3),(5,2),(5,1),(4,1),(4,0),(3,0)],
                modifications: [(.flash, nil),(.multipleEndArrows, [(5,0)])]
            ),
            LevelData(
                gridX: 7, gridY: 7, delayTime: 0.45,
                solutionCoords:
                [(0,3),(0,2),(1,2),(1,1),(2,1),(2,0),(3,0),(4,0),(4,1),(5,1),(5,2),(5,3),(6,3),(6,4),(6,5),(5,5),(4,5),(4,4),(3,4),(2,4),(1,4),(1,5),(2,5),(2,6)],
                modifications: [(.flash, nil)]
            ),
            LevelData(
                gridX: 6, gridY: 8, delayTime: 0.45,
                solutionCoords:
                [(3,7),(4,7),(4,6),(3,6),(2,6),(1,6),(0,6),(0,5),(0,4),(0,3),(0,2),(1,2),(2,2),(3,2),(4,2),(4,1),(4,0),(3,0),(2,0),(2,1),(2,2),(2,3),(2,4),(3,4),(4,4),(5,4),(5,5)],
                modifications: [(.flash, nil),(.multipleEndArrows, [(0,1)]),(.flip, true)]
            ),
            LevelData(
                gridX: 5, gridY: 5, delayTime: 0.45,
                solutionCoords:
                [(4,1),(3,1),(3,0),(2,0),(1,0),(1,1),(1,2),(2,2),(2,3),(2,4),(1,4),(0,4),(0,3)],
                modifications: [(.flash, nil), (.spin, CGFloat.pi/2), (.flip, true)]
            )
        ]
        levelGroups.append ((category: "Flash", array))
    }
}


