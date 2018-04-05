//
//  Helper.swift
//  Dark Maze
//
//  Created by crossibc on 4/1/18.
//  Copyright © 2018 crossibc. All rights reserved.
//

import Foundation
import SpriteKit

class Helper{
    static func switchScene(sceneName: String, gameDelegate: GameDelegate?, view: SKView){
        if let gestures = view.gestureRecognizers{
            for gesture in gestures{
                if let recognizer = gesture as? UISwipeGestureRecognizer {
                    view.removeGestureRecognizer(recognizer)
                }
            }
        }
        if let scene = SKScene(fileNamed: sceneName) {
            scene.scaleMode = .aspectFill
            scene.delegate = gameDelegate as? SKSceneDelegate
            view.presentScene(scene, transition: GameStyle.shared.sceneTransition)
        }
    }
}
