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
    
    static func intTupleIsEqual(_ rhs: (x: Int, y: Int), _ lhs: (x: Int,y: Int)) -> Bool{
        if (lhs.x == rhs.x) && (lhs.y == rhs.y){
            return true
        }
        return false
    }
}

/* use to draw a circle at a location
 
 var Circle = SKShapeNode(circleOfRadius: 10 )
 Circle.fillColor = SKColor.orange
 scene.addChild(Circle)
 
 */
