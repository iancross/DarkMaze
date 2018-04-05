//
//  LevelSelectScene.swift
//  Dark Maze
//
//  Created by crossibc on 12/5/17.
//  Copyright © 2017 crossibc. All rights reserved.
//

import SpriteKit
import GameplayKit


class LevelSelectScene: SKScene {
    var levels = [TextBoxButton]()
    var currentPage = 0
    var numLevelsOnPage = 12
    var numLevelsOnLine = 3
    let topRowHeight: CGFloat = 1140.0
    var verticalSpacing: CGFloat = 255.0
    var menuButton: TextBoxButton?
    let rightArrow = SKSpriteNode(imageNamed: "right_arrow_sprite")
    var leftArrow = SKSpriteNode()
    var categoryHeader: CategoryHeader?
    let labelBuffer: CGFloat = 20.0
    let menuBuffers: (x: CGFloat,y: CGFloat) = (20.0,20.0)

    override func didMove(to view: SKView) {
        (self.delegate as? GameDelegate)?.gameOver()
        verticalSpacing = frame.height/CGFloat(numLevelsOnPage/numLevelsOnLine + 3)
        menuButton = TextBoxButton(x: 215, y: 125, text: "Main Menu", fontsize: GameStyle.shared.SmallTextBoxFontSize, buffers: menuBuffers, parentScene: self)
        currentPage = LevelsData.shared.selectedLevel.page
        initializePageButtons()
        initPageArrows()
        
        let swipeRight : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeRight))
        let swipeLeft : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeLeft))
        
        swipeRight.direction = .right
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeRight)
        view.addGestureRecognizer(swipeLeft)
    }
    
    func initializePageButtons(){
        let group = LevelsData.shared.levelGroups[currentPage]
        let nextLevelToComplete = nextLevel(page: group)
        addCategoryLabel(group.category, frame.midX, topRowHeight - verticalSpacing*2/5)
        for i in 0...numLevelsOnPage/numLevelsOnLine-1{
            for j in 0...numLevelsOnLine-1{
                let levelNumber = i * (numLevelsOnLine) + j
                let y = topRowHeight - CGFloat(i+1) * verticalSpacing
                if levelNumber <= group.levels.count - 1 {
                    let box = TextBoxButton(
                        x: (frame.width/(CGFloat(numLevelsOnLine) + 1) * CGFloat(j+1)), y: y, text: String(99),
                        fontsize: GameStyle.shared.TextBoxFontSize,
                        buffers: (20.0,30.0),
                        parentScene: self)
                    box.updateText(String(levelNumber + 1))
                    levels.append(box)
                    if group.levels[levelNumber].levelCompleted{
                        box.markAsCompletedLevel()
                    }
                    else if levelNumber == nextLevelToComplete{
                        //do nothing
                    }
                    else {
                        box.setAlpha(0.3)
                    }
                }
            }
        }
    }

    func nextLevel(page: (category: String, levels: [LevelData])) -> Int{
        for (i,level) in page.levels.enumerated(){
            if !level.levelCompleted{
                return i
            }
        }
        return 0
    }
    func addCategoryLabel(_ category: String, _ x: CGFloat, _ y: CGFloat){
        categoryHeader = CategoryHeader(string: category)
        if ((categoryHeader?.position = CGPoint(x: x, y: y)) != nil){
            addChild(categoryHeader!)
        }
    }
    
    func initPageArrows(){
        let buffer: CGFloat = 60.0
        let levelOffset = CGFloat(numLevelsOnPage/numLevelsOnLine + 1)
        let levelsMiddle = topRowHeight - levelOffset * verticalSpacing / 2.0
        //right arrow init
        rightArrow.name = "right"
        rightArrow.position = CGPoint(x:frame.width - buffer, y: levelsMiddle)
        rightArrow.yScale *= 2.5
        rightArrow.alpha = 0.6
        leftArrow = rightArrow.copy() as! SKSpriteNode
        leftArrow.name = "left"
        leftArrow.position = CGPoint(x: buffer, y: levelsMiddle)
        leftArrow.xScale = -leftArrow.xScale
        addChild(leftArrow)
        let left_sequence = SKAction.sequence(
            [SKAction.move(by: CGVector(dx: -20.0,dy: 0), duration: 0.6),
             SKAction.move(by: CGVector(dx: +20.0,dy: 0), duration: 0.6)])
        leftArrow.run(SKAction.repeatForever(left_sequence))
        addChild(rightArrow)
        let right_sequence = SKAction.sequence(
            [SKAction.move(by: CGVector(dx: +20.0,dy: 0), duration: 0.6),
             SKAction.move(by: CGVector(dx: -20.0,dy: 0), duration: 0.6)])
        rightArrow.run(SKAction.repeatForever(right_sequence))
        removeOrKeepArrows()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first?.location(in: self){
            isMenuTouched(touch: touch)
            isLevelTouched(touch: touch)
            isAnArrowTouched(touch: touch)
        }
    }
    
    func isMenuTouched(touch: CGPoint){
        if (menuButton?.within(point: touch))!{
            Helper.switchScene(sceneName: "MenuScene", gameDelegate: self.delegate as? GameDelegate, view: view!)
        }
    }
    
    func isLevelTouched(touch: CGPoint){
        let group = LevelsData.shared.levelGroups[currentPage]
        let nextLevelToComplete = nextLevel(page: group)
        for button in levels{
            if button.within(point: touch){
                if Int(button.text)!-1 > nextLevelToComplete{
                    let sequence = [SKAction.rotate(byAngle: 0.1, duration: 0.3),
                                    SKAction.rotate(byAngle: -0.2, duration: 0.3),
                                    SKAction.rotate(byAngle: 0.1, duration: 0.3)]
                    button.outline.run(SKAction.sequence(sequence))
                }
                else if Int(button.text)!-1 <= nextLevelToComplete{
                    let embiggen = SKAction.scale(to: 1.3, duration: 0.4)
                    
                    let loadScene = SKAction.run({
                        LevelsData.shared.selectedLevel = (page: self.currentPage, level: Int(button.text)! - 1)
                        Helper.switchScene(sceneName: "Level1Scene", gameDelegate: self.delegate as? GameDelegate, view: self.view!)
                    })
                    button.outline.run(SKAction.sequence([embiggen,loadScene]))
                }
            }
        }
    }
    
    func isAnArrowTouched(touch: CGPoint){
        if rightArrow.contains(touch){
            pageFlip(pageModifier: 1)
        }
        else if leftArrow.contains(touch){
            pageFlip(pageModifier: -1)
        }
    }

    @objc func swipeRight(){
        pageFlip(pageModifier: -1)
    }
    @objc func swipeLeft(){
        pageFlip(pageModifier: 1)
    }
    
    func pageFlip(pageModifier: Int){
        let t = currentPage + pageModifier
        if t < LevelsData.shared.levelGroups.count && t >= 0{
            currentPage += pageModifier
            removeLevelButtons()
            removeOrKeepArrows()
            removeCategories()
            initializePageButtons()
        }
    }
    
    func removeCategories(){
        categoryHeader?.removeFromParent()
    }
    
    func removeLevelButtons(){
        for box in levels {
            box.removeAllChildren()
            box.removeFromParent()
        }
        levels.removeAll()
    }
    
    func removeOrKeepArrows(){
        if currentPage > 0{
           leftArrow.isHidden = false
        }
        else{
            leftArrow.isHidden = true
        }
        
        if currentPage < LevelsData.shared.levelGroups.count - 1 {
            rightArrow.isHidden = false
        }
        else{
            rightArrow.isHidden = true
        }
    }
}

