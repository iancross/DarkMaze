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


enum scenes {
    case menu
    case levelSelect
    case game
    case endGame
}

class GameViewController: UIViewController, GameDelegate {
    
    var sceneString = "MenuScene"

    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.black
        super.viewDidLoad()
        //let scene = SKScene(size: (view?.frame.size)!)
        if let view = self.view as! SKView? {
            
            view.preferredFramesPerSecond = 30
            mainMenu()

            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
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
    func gameOver() {
        switchScene(scene: EndGameScene(size: GameStyle.shared.defaultSceneSize))
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
