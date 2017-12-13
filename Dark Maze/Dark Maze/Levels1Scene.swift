//
//  Levels1.swift
//  Dark Maze
//
//  Created by crossibc on 12/12/17.
//  Copyright © 2017 crossibc. All rights reserved.
//

import SpriteKit
import GameplayKit

class Levels1Scene: SKScene {
    
    var floatingStartButton = SKLabelNode()
    
    override func didMove(to view: SKView) {
        print("fuck")

    }
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    /*override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
     print("test")
     let gameSceneTemp = GameScene(fileNamed: "Level1Scene")
     self.scene?.view?.presentScene(gameSceneTemp!, transition: SKTransition.doorsCloseHorizontal(withDuration: 2))
     }*/
    
}

