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
    var numLevelsOnPage = 9
    var numLevelsOnLine = 3
    let topRowHeight: CGFloat = 1150.0
    let verticalSpacing: CGFloat = 255.0
    var menuButton: TextBoxButton?
    let endArrow = SKSpriteNode(imageNamed: "right_arrow_sprite")
    var left_arrow = SKSpriteNode()
    var categoryNodes = [Any]()
    let labelBuffer: CGFloat = 20.0
    let menuBuffers: (x: CGFloat,y: CGFloat) = (20.0,20.0)

    override func didMove(to view: SKView) {
        menuButton = TextBoxButton(x: 215, y: 125, text: "Main Menu", fontsize: GameStyle.shared.SmallTextBoxFontSize, buffers: menuBuffers, parentScene: self)
        currentPage = (LevelsData.shared.nextLevelToComplete)/numLevelsOnPage

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
        let currLevel = LevelsData.shared.nextLevelToComplete
        for i in 0...numLevelsOnPage/numLevelsOnLine-1{
            for j in 0...numLevelsOnLine-1{
                let levelNumber = currentPage * numLevelsOnPage + i * numLevelsOnLine + j
                let y = topRowHeight - CGFloat(i+1) * verticalSpacing
                if levelNumber <= LevelsData.shared.levels.count-1{
                    addCategoryLabel(levelNumber, frame.midX, y + verticalSpacing*2/5)
                    let buffers: (CGFloat,CGFloat) = (30.0,40.0)
                    let box = TextBoxButton(
                        x: (frame.width/4.0 * CGFloat(j+1)), y: y, text: String(99),
                        fontsize: GameStyle.shared.TextBoxFontSize,
                        buffers: buffers,
                        parentScene: self)
                    box.updateText(String(levelNumber + 1))
                    levels.append(box)
                    if levelNumber < currLevel{
                        box.markAsCompletedLevel()
                    }
                    else if levelNumber > currLevel {
                        box.setAlpha(0.3)
                    }
                }
            }
        }
    }

    func addCategoryLabel(_ levelNumber: Int, _ x: CGFloat, _ y: CGFloat){
        if let category = LevelsData.shared.levels[levelNumber].category{
            let categoryLabel = SKLabelNode(text: category)
            categoryLabel.position = CGPoint(x: frame.midX, y: y)
            categoryLabel.fontName = GameStyle.shared.mainFontString
            categoryLabel.fontSize = GameStyle.shared.SmallTextBoxFontSize
            categoryLabel.verticalAlignmentMode = .center
            addToScene(node: categoryLabel)
            drawCategoryStyleLines(labelPosition: categoryLabel.position, labelWidth: categoryLabel.frame.width)
        }
    }
    
    func drawCategoryStyleLines(labelPosition: CGPoint, labelWidth: CGFloat){
        var rightPoints = [CGPoint(x: labelPosition.x + labelWidth/2 + labelBuffer, y: labelPosition.y),
                      CGPoint(x: frame.width/4.0*3.0, y: labelPosition.y)]
        let rightLine = SKShapeNode(points: &rightPoints,
                                          count: rightPoints.count)
        var leftPoints = [CGPoint(x: labelPosition.x - labelWidth/2 - labelBuffer, y: labelPosition.y),
                      CGPoint(x: frame.width/4.0, y: labelPosition.y)]
        let leftLine = SKShapeNode(points: &leftPoints,
                                    count: leftPoints.count)
        addToScene(node: leftLine)
        addToScene(node: rightLine)
    }
    
    func addToScene(node: Any){
        if let label = node as? SKLabelNode{
            addChild(label)
            categoryNodes.append(label)
        }
        else if let label = node as? SKShapeNode{
            addChild(label)
            categoryNodes.append(label)
        }
    }
    
    
    func initPageArrows(){
        let buffer: CGFloat = 60.0
        let levelOffset = CGFloat(numLevelsOnPage/numLevelsOnLine + 1)
        let levelsMiddle = topRowHeight - levelOffset * verticalSpacing / 2.0
        //right arrow init
        endArrow.name = "right"
        endArrow.position = CGPoint(x:frame.width - buffer, y: levelsMiddle)
        endArrow.yScale *= 2.5
        endArrow.alpha = 0.6
        left_arrow = endArrow.copy() as! SKSpriteNode
        left_arrow.name = "left"
        left_arrow.position = CGPoint(x: buffer, y: levelsMiddle)
        left_arrow.xScale = -left_arrow.xScale
        addChild(left_arrow)
        let left_sequence = SKAction.sequence(
            [SKAction.move(by: CGVector(dx: -20.0,dy: 0), duration: 0.6),
             SKAction.move(by: CGVector(dx: +20.0,dy: 0), duration: 0.6)])
        left_arrow.run(SKAction.repeatForever(left_sequence))
        addChild(endArrow)
        let right_sequence = SKAction.sequence(
            [SKAction.move(by: CGVector(dx: +20.0,dy: 0), duration: 0.6),
             SKAction.move(by: CGVector(dx: -20.0,dy: 0), duration: 0.6)])
        endArrow.run(SKAction.repeatForever(right_sequence))
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
            if let scene = SKScene(fileNamed: "MenuScene") {
                scene.scaleMode = .aspectFill
                view?.presentScene(scene, transition: GameStyle.shared.sceneTransition)
            }
        }
    }
    
    func isLevelTouched(touch: CGPoint){
        let currLevel = LevelsData.shared.nextLevelToComplete
        for button in levels{
            if button.within(point: touch){
                if Int(button.text)!-1 > currLevel{
                    let sequence = [SKAction.rotate(byAngle: 0.1, duration: 0.3),
                                    SKAction.rotate(byAngle: -0.2, duration: 0.3),
                                    SKAction.rotate(byAngle: 0.1, duration: 0.3)]
                    button.outline.run(SKAction.sequence(sequence))
                }
                else if Int(button.text)!-1 <= currLevel{
                    let embiggen = SKAction.scale(to: 1.3, duration: 0.4)
                    
                    let loadScene = SKAction.run({
                        LevelsData.shared.currentLevel = Int(button.text)! - 1
                        if let scene = SKScene(fileNamed: "Level1Scene") {
                            for gesture in (self.view?.gestureRecognizers!)!{
                                if let recognizer = gesture as? UISwipeGestureRecognizer {
                                    self.view?.removeGestureRecognizer(recognizer)
                                }
                            }
                            scene.scaleMode = .aspectFill
                            self.view?.presentScene(scene, transition: GameStyle.shared.sceneTransition)
                        }
                    })
                    button.outline.run(SKAction.sequence([embiggen,loadScene]))
                }
            }
        }
    }
    
    func isAnArrowTouched(touch: CGPoint){
        if endArrow.contains(touch){
            pageFlip(pageModifier: 1)
        }
        else if left_arrow.contains(touch){
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
        if t <= levels.count/numLevelsOnPage && t >= 0{
            currentPage += pageModifier
            removeLevelButtons()
            removeOrKeepArrows()
            removeCategories()
            initializePageButtons()
        }
    }
    
    func removeCategories(){
        while !categoryNodes.isEmpty{
            let first = categoryNodes.first
            if let label = first as? SKLabelNode{
                print ("label")
                label.removeFromParent()
            }
            if let shape = first as? SKShapeNode{
                print ("shape")
                shape.removeFromParent()
            }
            categoryNodes.removeFirst()
        }
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
           left_arrow.isHidden = false
        }
        else{
            left_arrow.isHidden = true
        }
        
        if currentPage < LevelsData.shared.levels.count/numLevelsOnPage {
            endArrow.isHidden = false
        }
        else{
            endArrow.isHidden = true
        }
    }
}

