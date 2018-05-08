//
//  CategoryHeader.swift
//  Dark Maze
//
//  Created by crossibc on 3/30/18.
//  Copyright © 2018 crossibc. All rights reserved.
//

import Foundation
import SpriteKit

class CategoryHeader: SKNode{
    var container = SKNode()
    let labelBuffer: CGFloat = 20.0
    var parentFrameWidth: CGFloat = 0.0

    init(string: String, fontSize: CGFloat, frameWidth: CGFloat){
        super.init()

        let categoryLabel = SKLabelNode(text: string)
        categoryLabel.position = CGPoint(x: 0, y: 0)
        categoryLabel.fontName = GameStyle.shared.mainFontString
        categoryLabel.fontSize = fontSize
        parentFrameWidth = frameWidth
        categoryLabel.verticalAlignmentMode = .center
        addToScene(node: categoryLabel)
        drawCategoryStyleLines(labelWidth: categoryLabel.frame.width)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func drawCategoryStyleLines(labelWidth: CGFloat){
        
        var rightPoints = [CGPoint(x: labelWidth/2 + labelBuffer, y: 0),
                           CGPoint(x: parentFrameWidth/2 - labelBuffer, y: 0)]
        let rightLine = SKShapeNode(points: &rightPoints,
                                    count: rightPoints.count)
        var leftPoints = [CGPoint(x: -labelWidth/2 - labelBuffer, y: 0),
                          CGPoint(x: -parentFrameWidth/2 + labelBuffer, y: 0)]
        let leftLine = SKShapeNode(points: &leftPoints,
                                   count: leftPoints.count)
        addToScene(node: leftLine)
        addToScene(node: rightLine)
    }
    
    func addToScene(node: Any){
        if let label = node as? SKLabelNode{
            self.addChild(label)
        }
        else if let line = node as? SKShapeNode{
            self.addChild(line)
        }
    }
    
    deinit{
        removeAllChildren()
    }
}
