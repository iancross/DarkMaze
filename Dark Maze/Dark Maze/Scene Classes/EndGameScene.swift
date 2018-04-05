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
        let success = LevelsData.shared.currentLevelSuccess
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

        let font = GameStyle.shared.TextBoxFontSize
        let buffers: (CGFloat,CGFloat) = (20.0,20.0)
        repeatOrNextButton = TextBoxButton(x: frame.midX, y: frame.midY + frame.midY/4, text: variableText,fontsize:font, buffers: buffers, parentScene: self)
        levelSelectButton = TextBoxButton(x: frame.midX, y: frame.midY, text: "Level Select", fontsize:font, buffers: buffers, parentScene: self)
        mainMenuButton = TextBoxButton(x: frame.midX, y: frame.midY - frame.midY/4, text: "Main Menu", fontsize:font, buffers: buffers, parentScene: self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //can we handle just first touch here?
        for t in touches {
            handleTouchForEndGameMenu(t.location(in: self))
        }
    }
    
    func handleTouchForEndGameMenu(_ point: CGPoint){
        if repeatOrNextButton!.within(point: point){
            if repeatOrNextButton?.text == "Next Level"{
                LevelsData.shared.nextLevel()
            }
            Helper.switchScene(sceneName: "Level1Scene", gameDelegate: self.delegate as? GameDelegate, view: self.view!)
        }
        else if levelSelectButton!.within(point: point){
            //Helper.switchScene(sceneName: "LevelSelectScene", gameDelegate: self.delegate as? GameDelegate, view: self.view!)
            (self.delegate as? GameDelegate)?.switchToViewController()
        }
        else if mainMenuButton!.within(point: point){
            Helper.switchScene(sceneName: "MenuScene", gameDelegate: self.delegate as? GameDelegate, view: self.view!)
        }
    }
}
