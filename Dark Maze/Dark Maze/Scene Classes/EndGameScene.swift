//
//  EndGameScene.swift
//  Dark Maze
//
//  Created by crossibc on 1/21/18.
//  Copyright © 2018 crossibc. All rights reserved.
//

import SpriteKit

class EndGameScene: SKScene {
    var repeatOrNextButton: TextBoxButton? = nil
    var levelSelectButton: TextBoxButton? = nil
    var mainMenuButton: TextBoxButton? = nil
    var successMessageNode = SKLabelNode()
    
    //first open the option modal
    //then direct the user based on selection
    //Main menu, level select, or next level?
    override func sceneDidLoad() {
        self.isUserInteractionEnabled = true
        
        var successMessage : String
        var success = LevelsData.shared.currentLevelSuccess
        var variableText: String
        
        
        if success {
            variableText = "Next Level"
            successMessage = "Success"
        }
        else {
            variableText = "Try Again"
            successMessage = "Failed"
        }
        successMessageNode = self.childNode(withName: "successMessage") as! SKLabelNode
        successMessageNode.text = successMessage
        print(frame.midY)
        print(frame.midY + frame.midY/4)
        
        repeatOrNextButton = TextBoxButton(x: frame.midX, y: frame.midY + frame.midY/4, text: variableText, parentScene: self)
        levelSelectButton = TextBoxButton(x: frame.midX, y: frame.midY, text: "Level Select", parentScene: self)
        mainMenuButton = TextBoxButton(x: frame.midX, y: frame.midY - frame.midY/4, text: "Main Menu", parentScene: self)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //can we handle just first touch here?
        for t in touches {
            handleTouchForEndGameMenu(t.location(in: self))
        }
    }
    
    func handleTouchForEndGameMenu(_ point: CGPoint){
        if repeatOrNextButton!.within(point: point){
            if repeatOrNextButton?.text == "Try Again"{
                if let scene = SKScene(fileNamed: "Level1Scene") {
                    scene.scaleMode = .aspectFill
                    view?.presentScene(scene)
                }
            }
            else{
                //here's where we would load the next level
            }
        }
        else if levelSelectButton!.within(point: point){
            print ("level select scene")
            if let scene = SKScene(fileNamed: "LevelSelectScene") {
                scene.scaleMode = .aspectFill
                view?.presentScene(scene)
            }
        }
        else if mainMenuButton!.within(point: point){
            print ("menu scene")
            if let scene = SKScene(fileNamed: "MenuScene") {
                scene.scaleMode = .aspectFill
                view?.presentScene(scene)
            }
        }
    }
}
