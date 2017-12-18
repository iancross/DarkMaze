//
//  Level1Scene.swift
//  Dark Maze
//
//  Created by crossibc on 12/5/17.
//  Copyright © 2017 crossibc. All rights reserved.
//

import SpriteKit
import GameplayKit


class LevelSelectScene: SKScene {

    private var label : SKLabelNode?
    
    override func didMove(to view: SKView) {
        level1 = self.childNode(withName: "Level1") as? SKSpriteNode
        level1?.position = CGPoint(x: frame.midX, y: frame.midY)
        initialize
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let gameSceneTemp = SKScene(fileNamed: "Levels1Scene")
        self.scene?.view?.presentScene(gameSceneTemp!, transition: SKTransition.doorsCloseHorizontal(withDuration: 2))
    }
}

