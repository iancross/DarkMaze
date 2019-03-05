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
import GoogleMobileAds
import AVFoundation



enum scenes {
    case menu
    case levelSelect
    case game
    case endGame
}


class GameViewController: UIViewController, GameDelegate, GADBannerViewDelegate {

    var bannerView: GADBannerView = GADBannerView()
    var sceneString = "MenuScene"

    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.black
        super.viewDidLoad()
        setupAudioSession()
        if let view = self.view as! SKView? {
            
            view.preferredFramesPerSecond = 30
            mainMenu()

            view.ignoresSiblingOrder = true
//            view.showsFPS = true
//            view.showsNodeCount = true
        }
        
    }
    
    //This category indicates that audio playback is a central feature of your app
    private func setupAudioSession(){
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
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
        switchScene(scene: EndGameScene (size: GameStyle.shared.sceneSizeWithAd, unlockedLevel: unlockedLevel))
        addBannerViewToView()
    }
    
    func playGame() {
        switchScene(scene: Level1Scene(size: GameStyle.shared.defaultSceneSize))
    }
    
    func mainMenu() {
        switchScene(scene: MenuScene(size: GameStyle.shared.defaultSceneSize))
    }
    
    func settings(){
        switchScene(scene: SettingsScene(size: GameStyle.shared.defaultSceneSize))
    }
    
    func levelSelect(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let ivc = storyboard.instantiateViewController(withIdentifier: "CategorySelectView")
        let appDelegate: AppDelegate = (UIApplication.shared.delegate as? AppDelegate)!

        UIView.animate(withDuration: 0.5, animations: {self.view.alpha = 0}){
            (completed) in
            self.cleanUp()
            appDelegate.window?.set(rootViewController: ivc)
        }
    }
    private func switchScene(scene: SKScene){
        bannerView.removeFromSuperview()
        scene.scaleMode = .aspectFill
        scene.delegate = self
        if let v = (view as? SKView){
            v.presentScene(scene)
        }
    }
    
    private func addBannerViewToView() {
        bannerView = GADBannerView(adSize: getAddSizeForScreen())
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        bannerView.rootViewController = self
        bannerView.backgroundColor = .black
        bannerView.adUnitID = GameStyle.shared.adMobTestToken
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: 0))
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: 0))
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: bottomLayoutGuide,
                                              attribute: .top,
                                              multiplier: 1,
                                              constant: 0))
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        bannerView.load(request)
    }
}

extension UIWindow {
    /// Fix for http://stackoverflow.com/a/27153956/849645
    func set(rootViewController newRootViewController: UIViewController, withTransition transition: CATransition? = nil) {
        
        let previousViewController = rootViewController

        rootViewController = newRootViewController
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
