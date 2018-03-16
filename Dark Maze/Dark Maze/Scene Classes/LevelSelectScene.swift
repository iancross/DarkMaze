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
    let topRowHeight = 1150
    let verticalSpacing = 200
    var menuButton: TextBoxButton?
    

    override func didMove(to view: SKView) {
        menuButton = TextBoxButton(x: 215, y: 125, text: "Main Menu", fontsize: GameStyle.shared.SmallTextBoxFontSize, parentScene: self)
        initializePageButtons()
    }
    func initializePageButtons(){
        let currLevel = LevelsData.shared.nextLevelToComplete
        currentPage = LevelsData.shared.levels.count/numLevelsOnPage
        for i in 0...numLevelsOnPage/numLevelsOnLine{
            for j in 0...numLevelsOnLine-1{
                let levelNumber = currentPage * numLevelsOnPage + i * numLevelsOnLine + j
                if levelNumber <= LevelsData.shared.levels.count-1{
                    let box = TextBoxButton(
                        x: (frame.width/4.0 * CGFloat(j+1)),
                        y: CGFloat(topRowHeight - (i+1) * verticalSpacing),
                        text: String(99),
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
                    print(Int(button.text)!)
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
                            scene.scaleMode = .aspectFill
                            self.view?.presentScene(scene, transition: GameStyle.shared.sceneTransition)
                        }
                    })
                    button.outline.run(SKAction.sequence([embiggen,loadScene]))
                }
            }
        }
    }
}

