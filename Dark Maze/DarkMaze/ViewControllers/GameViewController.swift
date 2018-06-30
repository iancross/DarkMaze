//
//  GameViewController.swift
//  Dark Maze
//
//  Created by crossibc on 12/5/17.
//  Copyright © 2017 crossibc. All rights reserved
//testing git
//

import UIKit
import SpriteKit
import GameplayKit
import CoreData


enum scenes {
    case menu
    case levelSelect
    case game
    case endGame
}

class GameViewController: UIViewController, GameDelegate {
    
    
    var sceneString = "MenuScene"

    override func viewDidLoad() {
        //self.save()
        self.view.backgroundColor = UIColor.black
        super.viewDidLoad()
        if let view = self.view as! SKView? {
            
            view.preferredFramesPerSecond = 30
            mainMenu()

            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    func save() {
        deleteCoreData()
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // 1
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        // 2
        let entity =
            NSEntityDescription.entity(forEntityName: "Level",
                                       in: managedContext)!

        for i in 1...25{
            let level = NSManagedObject(entity: entity,
                                        insertInto: managedContext)
            level.setValue(i, forKey: "page")
            level.setValue((i + 10), forKey: "levels_completed")
        }
        
        
        // 4
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Level")
        do {
            let levels = try managedContext.fetch(fetchRequest) as [NSManagedObject]
            for (i,level) in levels.enumerated(){
                print(i)
                print(level.value(forKeyPath: "page"))
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
    
    func deleteCoreData(){
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // 1
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

    func cleanUp(){
        if let v = self.view as? SKView{
            v.scene?.removeAllChildren()
            v.scene?.removeFromParent()
            v.presentScene(nil)
        }
    }
    
    //GameDelegate requirements
    func gameOver(unlockedLevel: Bool) {
        print ("GameOver")
        switchScene(scene: EndGameScene (size: GameStyle.shared.defaultSceneSize, unlockedLevel: unlockedLevel))
    }
    
    func playGame() {
        switchScene(scene: Level1Scene(size: GameStyle.shared.defaultSceneSize))
    }
    
    func mainMenu() {
        switchScene(scene: MenuScene(size: GameStyle.shared.defaultSceneSize))
    }
    
    func levelSelect(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let ivc = storyboard.instantiateViewController(withIdentifier: "CategorySelectView")
        let appDelegate: AppDelegate = (UIApplication.shared.delegate as? AppDelegate)!

        UIView.animate(withDuration: 0.7, animations: {self.view.alpha = 0}){
            (completed) in
            self.cleanUp()
            appDelegate.window?.set(rootViewController: ivc)
        }
    }
    private func switchScene(scene: SKScene){
        
        scene.scaleMode = .aspectFill
        scene.delegate = self
        if let v = (view as? SKView){
            v.presentScene(scene)
        }
    }
}

extension UIWindow {
    /// Fix for http://stackoverflow.com/a/27153956/849645
    func set(rootViewController newRootViewController: UIViewController, withTransition transition: CATransition? = nil) {
        
        let previousViewController = rootViewController
        
//        if let transition = transition {
//            // Add the transition
//            layer.add(transition, forKey: kCATransition)
//        }
        
        rootViewController = newRootViewController
        
//        // Update status bar appearance using the new view controllers appearance - animate if needed
//        if UIView.areAnimationsEnabled {
//            UIView.animate(withDuration: CATransaction.animationDuration()) {
//                newRootViewController.setNeedsStatusBarAppearanceUpdate()
//            }
//        } else {
//            newRootViewController.setNeedsStatusBarAppearanceUpdate()
//        }
        
        // The presenting view controllers view doesn't get removed from the window as its currently transistioning and presenting a view controller
        if let transitionViewClass = NSClassFromString("UITransitionView") {
            for subview in subviews where subview.isKind(of: transitionViewClass) {
                subview.removeFromSuperview()
            }
        }
        if let previousViewController = previousViewController {
            // Allow the view controller to be deallocated
            previousViewController.dismiss(animated: false) {
                // Remove the root view in case its still showing
                previousViewController.view.removeFromSuperview()
            }
        }
    }
}
