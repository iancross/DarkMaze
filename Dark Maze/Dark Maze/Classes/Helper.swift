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
            scene.delegate = gameDelegate!
            view.presentScene(scene)//, transition: GameStyle.shared.sceneTransition)
        }
    }
    
    //creates a label with the normal font, color, alignment
    //must pass in the fontsize and the actual text to be displayed
    static func createGenericLabel(_ label: String, fontsize: CGFloat) -> SKLabelNode{
        let labelNode = SKLabelNode(fontNamed: GameStyle.shared.mainFontString)
        labelNode.fontSize = fontsize
        labelNode.text = label
        labelNode.fontColor = .white
        labelNode.verticalAlignmentMode = .center
        
        return labelNode
    }
}

/* use to draw a circle at a location
 
 var Circle = SKShapeNode(circleOfRadius: 10 )
 Circle.fillColor = SKColor.orange
 scene.addChild(Circle)
 
 */
