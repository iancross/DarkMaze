//
//  GameScene.swift
//  Dark Maze
//
//  Created by crossibc on 12/5/17.
//  Copyright © 2017 crossibc. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var floatingStartButton = SKLabelNode()
    
    override func sceneDidLoad() {
        print("scene loaded")
    }
    override func didMove(to view: SKView) {
        
        floatingStartButton = self.childNode(withName: "FloatingStartGameButton") as! SKLabelNode
        floatingStartButton.position = CGPoint(
            x: CGFloat(arc4random_uniform(UInt32(frame.width - floatingStartButton.frame.width))),
            y: CGFloat(arc4random_uniform(UInt32(frame.height - floatingStartButton.frame.height)))
        )
    }
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("frame size",frame.maxX,frame.maxY)
        
        var x = arc4random_uniform(UInt32(frame.width - floatingStartButton.frame.size.width))
        var y = Int(arc4random_uniform(UInt32(frame.height - floatingStartButton.frame.size.height))) + Int(floatingStartButton.frame.size.height)
        floatingStartButton.position.x = CGFloat(x)
        floatingStartButton.position.y = CGFloat(y)
        //var y = CGFloat(arc4random_uniform(UInt32(frame.maxY)))
        
        print (floatingStartButton.position.x,floatingStartButton.position.y)
        
        /*floatingStartButton.position = CGPoint(
            x: CGFloat(arc4random_uniform(UInt32(frame.maxX - floatingStartButton.frame.maxX))),
            y: CGFloat(arc4random_uniform(UInt32(frame.maxY)))
        )*/
        /*for t in touches {
            let nodesAtLocation = self.nodes(at: t.location(in: self))
            for nodes in nodesAtLocation{
                if nodes.name == "FloatingStartGameButton" {
                    print("test")
                    let gameSceneTemp = GameScene(fileNamed: "Level1Scene")
                    self.scene?.view?.presentScene(gameSceneTemp!, transition: SKTransition.doorsCloseHorizontal(withDuration: 2))
                    break
                }
            }
        }*/
    }
    /*override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("test")
        let gameSceneTemp = GameScene(fileNamed: "Level1Scene")
        self.scene?.view?.presentScene(gameSceneTemp!, transition: SKTransition.doorsCloseHorizontal(withDuration: 2))
    }*/

}
