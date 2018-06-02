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
    let buttonsNode = SKNode()
    var successMessageNode = SKLabelNode()
    var displayUnlockLevelBonus: Bool?
    
    //first open the option modal
    //then direct the user based on selection
    //Main menu, level select, or next level?
    
    init(size: CGSize, unlockedLevel: Bool) {
        displayUnlockLevelBonus = unlockedLevel
        print("init \(displayUnlockLevelBonus!)")
        super.init(size: size)
        backgroundColor = UIColor.black
        anchorPoint = CGPoint(x: 0, y:0)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //max character width for a level is 17 characters
    override func sceneDidLoad() {
        self.isUserInteractionEnabled = true
        let success = determineSuccess()
        addSuccessMessage(text: success.successMessage)
        addButtons(text: success.variableText)
        
        //really if a successful bonus/unlocked happened
        let sequence = SKAction.sequence([SKAction.fadeAlpha(to: 1, duration: 3.0), SKAction.fadeAlpha(to: 0.3, duration: 2.0)])
        if displayUnlockLevelBonus! {
            print("unlocking next page")
            buttonsNode.position = CGPoint(x: buttonsNode.position.x, y: buttonsNode.position.y - frame.height/8)
            let unlocked = levelUnlocked()
            unlocked.alpha = 0
            self.addChild(unlocked)
            unlocked.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                            SKAction.fadeIn(withDuration: 1.0)]))
            {
                //self.buttonsNode.run(SKAction.repeatForever(sequence))
            }
        }
        else{
            //self.buttonsNode.run(SKAction.repeatForever(sequence))
        }
    }
    func levelUnlocked() -> SKNode{
        let bonusesNode = SKNode()
        let unlockedLabel1 = Helper.createGenericLabel("Next Level", fontsize: GameStyle.shared.TextBoxFontSize - 10)
        unlockedLabel1.verticalAlignmentMode = .baseline
        unlockedLabel1.position.y = 5
        let unlockedLabel2 = Helper.createGenericLabel("Unlocked", fontsize: GameStyle.shared.TextBoxFontSize - 20)
        unlockedLabel2.verticalAlignmentMode = .top
        bonusesNode.addChild(unlockedLabel1)
        bonusesNode.addChild(unlockedLabel2)
        let unlockSprite = SKSpriteNode(imageNamed: "unlock_sprite200x200")
        unlockSprite.setScale(0.4)
        unlockSprite.position = CGPoint(x: unlockedLabel1.frame.width/2 + 10 + unlockSprite.frame.width/2, y: 5)
        let unlockSprite2 = unlockSprite.copy() as! SKSpriteNode
        unlockSprite2.position.x = -unlockSprite2.position.x - 10
        
        bonusesNode.addChild(unlockSprite)
        bonusesNode.addChild(unlockSprite2)
        bonusesNode.position = CGPoint(x: frame.midX, y: frame.height*6/8)
        return bonusesNode
    }
    func addButtons(text: String){
        let font = GameStyle.shared.TextBoxFontSize
        let buffers: (CGFloat,CGFloat) = (20.0,20.0)

        repeatOrNextButton = TextBoxButton(x: 0, y: frame.height/8, text: text, fontsize:font, buffers: buffers)
        repeatOrNextButton?.name = "repeat"
        levelSelectButton = TextBoxButton(x: 0, y: 0.0, text: "Level Select", fontsize:font, buffers: buffers)
        mainMenuButton = TextBoxButton(x: 0, y: -frame.height/8, text: "Main Menu", fontsize:font, buffers: buffers)

        buttonsNode.position = CGPoint.zero
        buttonsNode.scene?.backgroundColor = UIColor.orange
        self.addChild(buttonsNode)
        buttonsNode.name = "BUTTONNODE"
        buttonsNode.addChild(mainMenuButton!)
        buttonsNode.addChild(levelSelectButton!)
        buttonsNode.addChild(repeatOrNextButton!)
        buttonsNode.position = CGPoint(x: frame.midX, y: frame.midY)
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
        successMessageNode.position = CGPoint(x: frame.midX, y: frame.height*7/8)
        //successMessageNode.text = text
        self.addChild(successMessageNode)

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for i in buttonsNode.children{
            if let child = i as? TextBoxButton{
                if !child.within(point: (touches.first?.location(in: buttonsNode))!){
                    child.originalState()
                }
                else{
                    child.tappedState()
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for i in buttonsNode.children{
            if let child = i as? TextBoxButton{
                if !child.within(point: (touches.first?.location(in: buttonsNode))!){
                    child.originalState()
                }
                else{
                    child.tappedState()
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let t = touches.first?.location(in: buttonsNode)
        for i in buttonsNode.children{
            if let child = i as? TextBoxButton{
                if child.within(point: (touches.first?.location(in: buttonsNode))!){
                    handleTouchForEndGameMenu(t!)
                }
            }
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
