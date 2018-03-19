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
    let topRowHeight: CGFloat = 1100.0
    let verticalSpacing: CGFloat = 220.0
    var menuButton: TextBoxButton?
    let right_arrow = SKSpriteNode(imageNamed: "right_arrow_sprite")
    var left_arrow = SKSpriteNode()
    var categoryNodes = [Any]()
    let labelBuffer: CGFloat = 20.0

    override func didMove(to view: SKView) {
        menuButton = TextBoxButton(x: 215, y: 125, text: "Main Menu", fontsize: GameStyle.shared.SmallTextBoxFontSize, parentScene: self)
        currentPage = LevelsData.shared.currentLevel/numLevelsOnPage

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
                    addCategoryLabel(levelNumber, frame.midX, y + verticalSpacing/3)
                    let box = TextBoxButton(
                        x: (frame.width/4.0 * CGFloat(j+1)), y: y, text: String(99),
                        fontsize: GameStyle.shared.TextBoxFontSize,
                        parentScene: self)
                    box.updateText(String(levelNumber + 1))
                    levels.append(box)
                    if levelNumber < currLevel - 1{
                        box.markAsCompletedLevel()
                    }
                    else if levelNumber > currLevel - 1{
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
        right_arrow.name = "right"
        right_arrow.position = CGPoint(x:frame.width - buffer, y: levelsMiddle)
        right_arrow.yScale *= 2.5
        right_arrow.alpha = 0.6
        left_arrow = right_arrow.copy() as! SKSpriteNode
        left_arrow.name = "left"
        left_arrow.position = CGPoint(x: buffer, y: levelsMiddle)
        left_arrow.xScale = -left_arrow.xScale
        addChild(left_arrow)
        let left_sequence = SKAction.sequence(
            [SKAction.move(by: CGVector(dx: -20.0,dy: 0), duration: 0.6),
             SKAction.move(by: CGVector(dx: +20.0,dy: 0), duration: 0.6)])
        left_arrow.run(SKAction.repeatForever(left_sequence))
        addChild(right_arrow)
        let right_sequence = SKAction.sequence(
            [SKAction.move(by: CGVector(dx: +20.0,dy: 0), duration: 0.6),
             SKAction.move(by: CGVector(dx: -20.0,dy: 0), duration: 0.6)])
        right_arrow.run(SKAction.repeatForever(right_sequence))
        removeOrKeepArrows()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let currLevel = LevelsData.shared.nextLevelToComplete
        let touch = touches.first?.location(in: self)
        
        if (menuButton?.within(point: touch!))!{
            if let scene = SKScene(fileNamed: "MenuScene") {
                scene.scaleMode = .aspectFill
                view?.presentScene(scene, transition: GameStyle.shared.sceneTransition)
            }
        }
        for button in levels{
            if button.within(point: touch!){
                if Int(button.text)! > currLevel{
                    let sequence = [SKAction.rotate(byAngle: 0.1, duration: 0.3),
                                    SKAction.rotate(byAngle: -0.2, duration: 0.3),
                                    SKAction.rotate(byAngle: 0.1, duration: 0.3)]
                    button.outline.run(SKAction.sequence(sequence))
                }
                else if Int(button.text)! <= currLevel{
                    let embiggen = SKAction.scale(to: 1.5, duration: 0.4)

                    let loadScene = SKAction.run({
                        LevelsData.shared.currentLevel = Int(button.text)!
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

    @objc func swipeRight(){
        handleSwipe(pageModifier: -1)
    }
    @objc func swipeLeft(){
        handleSwipe(pageModifier: 1)
    }
    
    func handleSwipe(pageModifier: Int){
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
            print(first)
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
            right_arrow.isHidden = false
        }
        else{
            right_arrow.isHidden = true
        }
    }
}

