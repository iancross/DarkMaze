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
    
    override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = UIColor.black
        anchorPoint = CGPoint(x: 0, y:0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sceneDidLoad() {
        self.isUserInteractionEnabled = true
        let success = determineSuccess()
        addSuccessMessage(text: success.successMessage)
        addButtons(text: success.variableText)
    }
    func addButtons(text: String){
        let font = GameStyle.shared.TextBoxFontSize
        let buffers: (CGFloat,CGFloat) = (20.0,20.0)
        repeatOrNextButton = TextBoxButton(x: frame.midX, y: frame.midY + frame.midY/4, text: text,fontsize:font, buffers: buffers, parentScene: self)
        levelSelectButton = TextBoxButton(x: frame.midX, y: frame.midY, text: "Level Select", fontsize:font, buffers: buffers, parentScene: self)
        mainMenuButton = TextBoxButton(x: frame.midX, y: frame.midY - frame.midY/4, text: "Main Menu", fontsize:font, buffers: buffers, parentScene: self)
        
//        let buttonsNode = SKNode()
//        buttonsNode.addChild(repeatOrNextButton!)
//        self.addChild(buttonsNode)
//        buttonsNode.scene?.backgroundColor = UIColor.orange
//        buttonsNode.zRotation = CGFloat(Double.pi/3.0)
    }
    func determineSuccess() -> (successMessage: String, variableText: String) {
        var successMessage : String
        var variableText: String
        let success = LevelsData.shared.currentLevelSuccess
        if success {
            variableText = "Next Level"
            successMessage = "Success"
        }
        else {
            variableText = "Try Again"
            successMessage = "Failed"
        }
        return (successMessage: successMessage, variableText: variableText )
    }
    func addSuccessMessage(text: String){
        successMessageNode = Helper.createGenericLabel(text, fontsize: GameStyle.shared.LargeTextBoxFontSize)
        successMessageNode.position = CGPoint(x: frame.midX, y: 1130)
        //successMessageNode.text = text
        self.addChild(successMessageNode)

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
            //Helper.switchScene(sceneName: "Level1Scene", gameDelegate: self.delegate as? GameDelegate, view: self.view!)
            (self.delegate as? GameDelegate)?.playGame()
        }
        else if levelSelectButton!.within(point: point){
            //Helper.switchScene(sceneName: "LevelSelectScene", gameDelegate: self.delegate as? GameDelegate, view: self.view!)
            (self.delegate as? GameDelegate)?.levelSelect()
        }
        else if mainMenuButton!.within(point: point){
            //Helper.switchScene(sceneName: "MenuScene", gameDelegate: self.delegate as? GameDelegate, view: self.view!)
            (self.delegate as? GameDelegate)?.mainMenu()
        }
    }
}
