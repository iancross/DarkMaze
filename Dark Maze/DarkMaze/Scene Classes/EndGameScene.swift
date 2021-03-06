//
//  EndGameScene.swift
//  Dark Maze
//
//  Created by crossibc on 1/21/18.
//  Copyright © 2018 crossibc. All rights reserved.
//
let YELLOW = UIColor.init(red: 0.8, green: 0.8, blue: 0.0, alpha: 1.0)
import SpriteKit
import GoogleMobileAds

let buffers: (CGFloat,CGFloat) = (screenWidth*0.05,screenWidth*0.025)

class EndGameScene: SKScene {
    var repeatOrNextButton: TextBoxButton? = nil
    var levelSelectButton: TextBoxButton? = nil
    var mainMenuButton: TextBoxButton? = nil
    let buttonsNode = SKNode()
    var successMessageNode = SKLabelNode()
    var displayUnlockLevelBonus: Bool?
    var allLevelsComplete: Bool?

    
    //first open the option modal
    //then direct the user based on selection
    //Main menu, level select, or next level?
    
    init(size: CGSize, unlockedLevel: Bool, pageCompleted: Bool) {
        displayUnlockLevelBonus = unlockedLevel
        allLevelsComplete = pageCompleted
        print ("page completed is \(allLevelsComplete)")
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
        bonuses()
        askForFeedback()
    }
    
    func askForFeedback(){
        let selectedLevel = LevelsData.shared.selectedLevel
        if selectedLevel.page == 5 && !AudioController.shared.isSettingEnabled(settingName: "askedForFeedback1"){
            AudioController.shared.flipSettingInCoreData(key: "askedForFeedback1", newValue: true)
            openRatingPopup()
        }
        else if selectedLevel.page == 10 && !AudioController.shared.isSettingEnabled(settingName: "askedForFeedback2"){
            AudioController.shared.flipSettingInCoreData(key: "askedForFeedback2", newValue: true)
            openRatingPopup()
        }
    }
    
    func openRatingPopup(){
        if #available(iOS 10.3, *){
            SKStoreReviewController.requestReview()
        }
    }
    
    func bonuses(){
        let bannerHeight = kGADAdSizeFullBanner.size.height
        let nodes: [SKNode] = collectBonuses()
        let positions: [CGPoint] =
            [CGPoint(x: frame.midX, y: frame.height*5.8/8),
             CGPoint(x: frame.midX, y: frame.height*5/8)]
        
        for (i, node) in nodes.enumerated(){
            node.position = positions[i]
            node.alpha = 0
            self.addChild(node)
            let sequence = SKAction.sequence([SKAction.wait(forDuration: Double(i+1)*0.5),
                                              SKAction.fadeIn(withDuration: 0.7)])
            node.run(sequence)
        }
                
        if let last = nodes.last{
            let y = (last.position.y - bannerHeight)/2 + bannerHeight
            buttonsNode.position = CGPoint(x: frame.midX, y: y)
        }
        else {
            buttonsNode.position = CGPoint(x: frame.midX, y: frame.height*4/8)
        }
        self.addChild(buttonsNode)
        buttonsNode.run(SKAction.sequence([SKAction.wait(forDuration: Double(nodes.count + 1)*0.5),
                                          SKAction.fadeIn(withDuration: 1.0)]))
    }
    
    func collectBonuses() -> [SKNode]{
        var nodes = [SKNode]()
        if LevelsData.shared.displayFirstTimeBonus(){
            nodes.append(firstTryBonus())
        }
        if displayUnlockLevelBonus!{
            nodes.append(levelUnlockedBonus())
            LevelsData.shared.nextLevel()
        }
        else if allLevelsComplete ?? false && LevelsData.shared.selectedLevel.page < LevelsData.shared.levelGroups.count - 1{
            nodes.append(pageCompletedBonus())
        }
        return nodes
    }
    
    func firstTryBonus()-> SKNode{
        let firstTryNode = SKNode()
        let label1 = Helper.createGenericLabel("First Try!", fontsize: screenWidth*0.1)
        label1.verticalAlignmentMode = .baseline
        label1.position.y = 5
        firstTryNode.addChild(label1)
        
        let starLabel1 = SKLabelNode(text: "\u{2605}")
        starLabel1.fontColor = YELLOW //UIColor.init(red: 0.8, green: 0.8, blue: 0.0, alpha: 1.0)
        starLabel1.fontSize = screenWidth*0.1
        starLabel1.horizontalAlignmentMode = .center
        starLabel1.position = CGPoint(x: label1.frame.width/2 + screenWidth*0.01 + starLabel1.frame.width/2, y: 5)
        
        let starLabel2 = starLabel1.copy() as! SKLabelNode
        starLabel2.position.x = -starLabel2.position.x
        
        firstTryNode.addChild(starLabel1)
        firstTryNode.addChild(starLabel2)
        return firstTryNode
    }
    
    func pageCompletedBonus()-> SKNode{
        let nextLevelName = LevelsData.shared.getPageCategory(page: LevelsData.shared.selectedLevel.page)
        
        let bonusesNode = SKNode()
        let unlockedLabel1 = Helper.createGenericLabel("'" + nextLevelName + "'", fontsize: screenWidth*0.086)
        unlockedLabel1.verticalAlignmentMode = .baseline
        unlockedLabel1.position.y = 5
        let unlockedLabel2 = Helper.createGenericLabel("Completed", fontsize: screenWidth*0.086)
        unlockedLabel2.verticalAlignmentMode = .top
        bonusesNode.addChild(unlockedLabel1)
        bonusesNode.addChild(unlockedLabel2)
        
        let starLabel1 = SKLabelNode(text: "\u{2713}")
        starLabel1.fontColor = .white //YELLOW //UIColor.init(red: 0.8, green: 0.8, blue: 0.0, alpha: 1.0)
        starLabel1.fontSize = screenWidth*0.12
        starLabel1.horizontalAlignmentMode = .center
        starLabel1.verticalAlignmentMode = .center
        starLabel1.position = CGPoint(
            x: CGFloat.maximum(unlockedLabel1.frame.width, unlockedLabel2.frame.width)/2
                + screenWidth*0.01 + starLabel1.frame.width/2,
            y: 5)
        
        let starLabel2 = starLabel1.copy() as! SKLabelNode
        //starLabel2.horizontalAlignmentMode = .left
        starLabel2.position.x = -starLabel2.position.x
        bonusesNode.addChild(starLabel1)
        bonusesNode.addChild(starLabel2)
        
        //the final position
        bonusesNode.position = CGPoint(x: frame.midX, y: frame.height*13/16)
        return bonusesNode
    }
    
    func levelUnlockedBonus() -> SKNode{
        let nextLevelName = LevelsData.shared.getPageCategory(page: LevelsData.shared.selectedLevel.page + 1)

        let bonusesNode = SKNode()
        let unlockedLabel1 = Helper.createGenericLabel("'" + nextLevelName + "'", fontsize: screenWidth*0.086)
        unlockedLabel1.verticalAlignmentMode = .baseline
        unlockedLabel1.position.y = 5
        let unlockedLabel2 = Helper.createGenericLabel("Unlocked", fontsize: screenWidth*0.086)
        unlockedLabel2.verticalAlignmentMode = .top
        bonusesNode.addChild(unlockedLabel1)
        bonusesNode.addChild(unlockedLabel2)
        let unlockSprite = SKSpriteNode(imageNamed: "unlock_sprite200x200")
        unlockSprite.setScale(screenHeight / 1334 * 0.4)
        unlockSprite.position = CGPoint(
            x: CGFloat.maximum(unlockedLabel1.frame.width, unlockedLabel2.frame.width)/2
                + screenWidth*0.01 + unlockSprite.frame.width/2,
            y: 5)
        let unlockSprite2 = unlockSprite.copy() as! SKSpriteNode
        unlockSprite2.position.x = -unlockSprite2.position.x - screenWidth*0.01
        
        bonusesNode.addChild(unlockSprite)
        bonusesNode.addChild(unlockSprite2)
        
        //the final position
        bonusesNode.position = CGPoint(x: frame.midX, y: frame.height*13/16)
        return bonusesNode
    }
    
    
    func addButtons(text: String){
        let font = screenWidth*0.09
        if (allLevelsComplete ?? false || displayUnlockLevelBonus ?? false){
//            repeatOrNextButton = TextBoxButton(x: 0, y: frame.height/8, text: text, fontsize:font, buffers: buffers)
//            repeatOrNextButton?.name = "repeat"
            levelSelectButton = TextBoxButton(x: 0, y: frame.height/8, text: "Level Select", fontsize:font, buffers: buffers)
            mainMenuButton = TextBoxButton(x: 0, y: 0, text: "Main Menu", fontsize:font, buffers: buffers)
//            buttonsNode.addChild(repeatOrNextButton!)
            buttonsNode.addChild(mainMenuButton!)
            buttonsNode.addChild(levelSelectButton!)
        }
        else{
            repeatOrNextButton = TextBoxButton(x: 0, y: frame.height/8, text: text, fontsize:font, buffers: buffers)
            repeatOrNextButton?.name = "repeat"
            levelSelectButton = TextBoxButton(x: 0, y: 0.0, text: "Level Select", fontsize:font, buffers: buffers)
            mainMenuButton = TextBoxButton(x: 0, y: -frame.height/8, text: "Main Menu", fontsize:font, buffers: buffers)
            buttonsNode.addChild(mainMenuButton!)
            buttonsNode.addChild(levelSelectButton!)
            buttonsNode.addChild(repeatOrNextButton!)
        }
        buttonsNode.position = CGPoint.zero
        buttonsNode.name = "BUTTONNODE"
        buttonsNode.alpha = 0
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
        successMessageNode = Helper.createGenericLabel(text, fontsize: screenWidth*0.16)
        successMessageNode.position = CGPoint(x: frame.midX, y: frame.height*7/8)
        //successMessageNode.text = text
        self.addChild(successMessageNode)

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for child in self.children{
            child.removeAllActions()
            child.alpha = 1.0
        }
        for i in buttonsNode.children{
            if let child = i as? TextBoxButton{
                if let t = touches.first?.location(in: buttonsNode){
                    if !child.within(point: t){
                        child.originalState()
                    }
                    else{
                        child.tappedState()
                    }
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for i in buttonsNode.children{
            if let child = i as? TextBoxButton{
                if let t = touches.first?.location(in: buttonsNode){
                    if !child.within(point: t){
                        child.originalState()
                    }
                    else{
                        child.tappedState()
                    }
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for i in buttonsNode.children{
            if let child = i as? TextBoxButton{
                if child.within(point: (touches.first?.location(in: buttonsNode))!){
                    if let t = touches.first?.location(in: buttonsNode){
                        handleTouchForEndGameMenu(t)
                        AudioController.shared.playButtonClick()
                    }
                }
            }
        }
    }
    
    func handleTouchForEndGameMenu(_ point: CGPoint){
        if repeatOrNextButton?.within(point: point) ?? false{
            if repeatOrNextButton?.text == "Next Level"{
                LevelsData.shared.nextLevel()
            }
            //Helper.switchScene(sceneName: "Level1Scene", gameDelegate: self.delegate as? GameDelegate, view: self.view!)
            (self.delegate as? GameDelegate)?.playGame()
        }
        else if levelSelectButton?.within(point: point) ?? false{
            //Helper.switchScene(sceneName: "LevelSelectScene", gameDelegate: self.delegate as? GameDelegate, view: self.view!)
            (self.delegate as? GameDelegate)?.levelSelect()
        }
        else if mainMenuButton?.within(point: point) ?? false{
            //Helper.switchScene(sceneName: "MenuScene", gameDelegate: self.delegate as? GameDelegate, view: self.view!)
            (self.delegate as? GameDelegate)?.mainMenu()
        }
    }
}
