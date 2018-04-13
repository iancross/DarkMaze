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

class GameViewController: UIViewController, GameDelegate {
    var sceneString = "MenuScene"

    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.black
        super.viewDidLoad()
        //let scene = SKScene(size: (view?.frame.size)!)
        if let view = self.view as! SKView? {
            //view.presentScene(scene)
            Helper.switchScene(sceneName: sceneString, gameDelegate: self, view: view)

            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    func cleanUp(){
        if let v = self.view as? SKView{
            print ("cleaning up")
            v.scene?.removeAllChildren()
            v.scene?.removeFromParent()
            v.presentScene(nil)
        }
    }
    
    //GameDelegate requirements
    func gameOver() {
        print ("DELEGATION WOOO")
        Helper.switchScene(sceneName: "EndGameScene", gameDelegate: self, view: view as! SKView)
    }
    
    func switchToViewController(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let ivc = storyboard.instantiateViewController(withIdentifier: "CategorySelectView")
        let appDelegate: AppDelegate = (UIApplication.shared.delegate as? AppDelegate)!

        //ivc.sceneString = "LevelSelectScene"
        UIView.animate(withDuration: 0.7, animations: {self.view.alpha = 0}){
            (completed) in
            self.cleanUp()
            appDelegate.window?.set(rootViewController: ivc)
        }
    }
    
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let ivc = storyboard.instantiateViewController(withIdentifier: "CategorySelectView")
//        UIView.animate(withDuration: 0.7, animations: {self.view.alpha = 0}){[weak self]
//            (completed) in
//            ivc.modalTransitionStyle = .crossDissolve
//            //self?.cleanUp()
//            self?.present(ivc, animated: false){
////                self?.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
////                let appDelegate: AppDelegate = (UIApplication.shared.delegate as? AppDelegate)!
////                appDelegate.window?.rootViewController = ivc
//            }
//        }
//    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if (segue.identifier == "goToLevelSelect") {
//            _ = segue.destination as? CategorySelectViewController
//        }
//    }

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
