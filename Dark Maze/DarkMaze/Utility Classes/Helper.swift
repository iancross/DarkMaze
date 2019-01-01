//
//  Helper.swift
//  Dark Maze
//
//  Created by crossibc on 4/1/18.
//  Copyright © 2018 crossibc. All rights reserved.
//

import Foundation
import SpriteKit
import GoogleMobileAds

class Helper{
    static let shared = Helper()

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

public func getAddSizeForScreen()->GADAdSize{
    return GADAdSizeFromCGSize(CGSize(width: screenWidth, height: screenHeight * 0.15))
}

public func calcMidPointOf(a: CGPoint, b: CGPoint) -> CGPoint{
    print("midpoint of \(a) and \(b) is \(CGPoint(x: (a.x + b.x)/2, y: (a.y + b.y)/2))")
    return CGPoint(x: (a.x + b.x)/2, y: (a.y + b.y)/2)
}

public func calcDistanceBetweenPoints(a: CGPoint, b: CGPoint) -> CGFloat{
    return (pow((a.x - b.x), 2) + pow((a.y - b.y), 2)).squareRoot()
}

public func calcSidesOfPerfectRightTriangleGiven(hypotenuse: CGFloat)->CGFloat{
    return (pow(hypotenuse,2)/2).squareRoot()
}

public func calcSideOfRightTriangle(hypotenuse: CGFloat, side: CGFloat) -> CGFloat{
    return (pow(hypotenuse,2) - pow(side,2)).squareRoot()
}

public func calcSlopeOf(a: CGPoint, b: CGPoint) -> CGFloat{
    print ("slope is \((a.y - b.y)/(a.x-b.x))")
    return (a.y - b.y)/(a.x-b.x)
}

public func calcPointsGiven(source: CGPoint, slope: CGFloat, distance: CGFloat) -> [CGPoint]{
    let p = distance * (1/1+pow(slope, 2)).squareRoot()

    var x1 = source.x + p
    var x2 = source.x - p
    var y1 = source.y + slope * p
    var y2 = source.y - slope * p
    
    print ("the points are \([CGPoint(x: x1, y: y1), CGPoint(x: x2, y: y2)])")
    return [CGPoint(x: x1, y: y1), CGPoint(x: x2, y: y2)]
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

//Screen width
public var screenWidth: CGFloat {
    return UIScreen.main.bounds.width
}

// Screen height.
public var screenHeight: CGFloat {
    return UIScreen.main.bounds.height
}


/* use to draw a circle at a location
 
 var Circle = SKShapeNode(circleOfRadius: 10 )
 Circle.fillColor = SKColor.orange
 scene.addChild(Circle)
 
 */
