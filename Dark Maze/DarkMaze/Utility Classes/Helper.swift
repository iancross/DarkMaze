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

// MARK: Double Extension

public extension Double {
    
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    public static var random: Double {
        return Double(arc4random()) / 0xFFFFFFFF
    }
    
    /// Random double between 0 and n-1.
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random double point number between 0 and n max
    public static func random(min: Double, max: Double) -> Double {
        return Double.random * (max - min) + min
    }
}


/* use to draw a circle at a location
 
 var Circle = SKShapeNode(circleOfRadius: 10 )
 Circle.fillColor = SKColor.orange
 scene.addChild(Circle)
 
 */
