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

    
    override func didMove(to view: SKView) {
        //levels.append(TextBoxButton(x: frame.midX, y: frame.midY, text: "1", parentScene: self))
        
        //for each level select button, we need to init color and alpha
        //based on whether the level was completed and is up next
        enumerateChildNodes(withName: "//*") { (node, stop) in
            let currLevel = LevelsData.shared.nextLevelToComplete
            if let currNode = node as? SKLabelNode{
                if currNode.name == "number"{
                    let level = Int(currNode.text!)!
                    if level > currLevel{
                        currNode.alpha = 0.3
                    }
                    else if level < currLevel{
                        currNode.fontColor = UIColor.black
                    }
                }
            }
            else if let currNode = node as? SKShapeNode{
                let level = Int(currNode.name!)!
                if level > currLevel{
                    currNode.alpha = 0.3
                }
                else if level < currLevel{
                    currNode.fillColor = UIColor.white
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        for touch in touches{
            let nodesAtLocation = self.nodes(at: touch.location(in: self))
            for node in nodesAtLocation{
                if let box = node as? SKShapeNode{
                    if Int(box.name!)! <= LevelsData.shared.nextLevelToComplete {
                        LevelsData.shared.currentLevel = Int(box.name!)!
                        let embiggen = SKAction.scale(to: 1.2, duration: 0.5)
                        let loadScene = SKAction.run({
                            LevelsData.shared.currentLevel = Int(box.name!)!
                            if let scene = SKScene(fileNamed: "TapToBeginScene") {
                                scene.scaleMode = .aspectFill
                                self.view?.presentScene(scene)
                            }
                        })
                        box.run(SKAction.sequence([embiggen,loadScene]))
                    }
                    else {
                        let sequence = [SKAction.rotate(byAngle: 0.1, duration: 0.3),
                                        SKAction.rotate(byAngle: -0.2, duration: 0.3),
                                        SKAction.rotate(byAngle: 0.1, duration: 0.3)]
                        box.run(SKAction.sequence(sequence))
                    }
                }
                
                //modify levels data to make the current level whatever is selected
//                if let scene = SKScene(fileNamed: "Level1Scene") {
//                    scene.scaleMode = .aspectFill
//                    view?.presentScene(scene)
//                }
            }
        }
    }
}

