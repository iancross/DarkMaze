//
//  TapToBeginScene.swift
//  Dark Maze
//
//  Created by crossibc on 3/12/18.
//  Copyright © 2018 crossibc. All rights reserved.
//

import Foundation
import SpriteKit

class TapToBeginScene: SKScene {
    override func didMove(to view: SKView) {
        self.isUserInteractionEnabled = true
        let tapLabel = SKLabelNode(fontNamed: GameStyle.shared.mainFontString)
        tapLabel.text = "Tap to begin"
        tapLabel.fontSize = GameStyle.shared.TextBoxFontSize
        tapLabel.fontColor = SKColor.white
        tapLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(tapLabel)
        let actionList = SKAction.sequence(
            [SKAction.fadeOut(withDuration: 2.0),
             SKAction.fadeIn(withDuration: 2.0)]
        )
        tapLabel.run(SKAction.repeatForever(actionList))
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //if begin is touched
        if let scene = SKScene(fileNamed: "Level1Scene") {
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: GameStyle.shared.sceneTransition)
        }
    }
}
