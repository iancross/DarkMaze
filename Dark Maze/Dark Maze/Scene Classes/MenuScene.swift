//
//  GameScene.swift
//  Dark Maze
//
//  Created by crossibc on 12/5/17.
//  Copyright © 2017 crossibc. All rights reserved.
//

import SpriteKit
import GameplayKit

protocol TestDelegate {
    func gameOver()
    func levelSelect()
}

class MenuScene: SKScene {
    var floatingStartButton = SKLabelNode()
    
    override func didMove(to view: SKView) {
        floatingStartButton = self.childNode(withName: "FloatingStartGameButton") as! SKLabelNode
        floatingStartButton.position = CGPoint(
            x: CGFloat(arc4random_uniform(UInt32(frame.width - floatingStartButton.frame.width))),
            y: CGFloat(arc4random_uniform(UInt32(frame.height - floatingStartButton.frame.height)))
        )
        let actionList = SKAction.sequence(
            [SKAction.fadeIn(withDuration: 2.0),
            SKAction.fadeOut(withDuration: 2.0),
            SKAction.run(moveLabel)]
        )
        floatingStartButton.run(SKAction.repeatForever(actionList))
    }
    
    func moveLabel(){
        let newX = arc4random_uniform(UInt32(self.frame.width - self.floatingStartButton.frame.size.width))
        let newY = arc4random_uniform(UInt32(self.frame.height - self.floatingStartButton.frame.size.height)) + UInt32(self.floatingStartButton.frame.size.height)
        let newPoint = CGPoint(x: CGFloat(newX), y: CGFloat(newY))
        self.floatingStartButton.position = newPoint
        
    }
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let nodesAtLocation = self.nodes(at: t.location(in: self))
            for nodes in nodesAtLocation{
                if nodes.name == "FloatingStartGameButton" {
                    if let scene = SKScene(fileNamed: "LevelSelectScene") {
                        scene.scaleMode = .aspectFill
                        view?.presentScene(scene)
                    }
                }
            }
        }
    }
}
