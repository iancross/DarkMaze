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
    
    //GameDelegate requirements
    func gameOver() {
        print ("DELEGATION WOOO")
        Helper.switchScene(sceneName: "EndGameScene", gameDelegate: self, view: view as! SKView)
    }
    
    func switchToViewController(){
        //self.performSegue(withIdentifier: "goToLevelSelect", sender: nil)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let ivc = storyboard.instantiateViewController(withIdentifier: "CategorySelectView")
        UIView.animate(withDuration: 0.7, animations: {self.view.alpha = 0}){
            (completed) in
            ivc.modalTransitionStyle = .crossDissolve
            self.present(ivc, animated: false, completion: nil)
        }
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if (segue.identifier == "goToLevelSelect") {
//            _ = segue.destination as? CategorySelectViewController
//        }
//    }

}
