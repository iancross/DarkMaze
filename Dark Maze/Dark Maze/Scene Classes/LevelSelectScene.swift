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
        levels.append(TextBoxButton(x: frame.midX, y: frame.midY, text: "1", parentScene: self))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            if levels[0].within(point: touch.location(in: self)){
                //modify levels data to make the current level whatever is selected
                if let scene = SKScene(fileNamed: "Level1Scene") {
                    scene.scaleMode = .aspectFill
                    view?.presentScene(scene)
                }
            }
        }
    }
    

}

