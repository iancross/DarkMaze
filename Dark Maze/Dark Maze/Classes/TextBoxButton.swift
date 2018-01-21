//
//  TextBoxButton.swift
//  Dark Maze
//
//  Created by crossibc on 1/20/18.
//  Copyright © 2018 crossibc. All rights reserved.
//

import Foundation
import SpriteKit

class TextBoxButton: SKNode{
    var text: String
    var labelNode: SKLabelNode
    var outline: SKShapeNode
    var buffer: CGFloat = 15
    
    init(x: CGFloat, y: CGFloat, text: String, font: String, parentScene: SKScene) {
        self.text = text
        labelNode = SKLabelNode(fontNamed: font)
        labelNode.text = text
        labelNode.fontSize = 35
        labelNode.fontColor = SKColor.white
        labelNode.position = CGPoint(x: x, y: y)
        
        parentScene.addChild(labelNode)
        
        //start top right and go counter clockwise
        var points = [CGPoint(x: labelNode.frame.minX - buffer, y: labelNode.frame.maxY + buffer),
                      CGPoint(x: labelNode.frame.maxX + buffer, y: labelNode.frame.maxY + buffer),
                      CGPoint(x: labelNode.frame.maxX + buffer, y: labelNode.frame.minY - buffer),
                      CGPoint(x: labelNode.frame.minX - buffer, y: labelNode.frame.minY - buffer),
                      CGPoint(x: labelNode.frame.minX - buffer, y: labelNode.frame.maxY + buffer)
        ]
        outline = SKShapeNode(points: &points, count: points.count)
        /*tile.lineWidth = 1
        tile.glowWidth = 1
        tile.fillColor = UIColor.black
        tile.name = "Grid Tile"
        tile.strokeColor = UIColor(displayP3Red: 0.40, green: 0.40, blue: 0.40, alpha: 0.0 )
        //add the tile to the parent scene*/
        parentScene.addChild(outline)
        super.init()

    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
