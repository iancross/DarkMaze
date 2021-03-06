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
    var text: String {
        didSet{
            labelNode.text = text
        }
    }
    var labelNode: SKLabelNode
    var outline: SKShapeNode
    var buffer: CGFloat = 40
    
    init(x: CGFloat, y: CGFloat, text: String, fontsize: CGFloat, buffers: (x: CGFloat, y: CGFloat)) {
        labelNode = SKLabelNode(fontNamed: GameStyle.shared.mainFontString)
        labelNode.text = text
        labelNode.fontSize = fontsize
        labelNode.fontColor = .white
        labelNode.verticalAlignmentMode = .center
        
        
        outline = SKShapeNode(rectOf: CGSize(width: labelNode.frame.width + buffers.x, height: labelNode.frame.height + buffers.y))
        outline.lineWidth = 2 + fontsize/70.0
//        outline.position = CGPoint(x: x, y: y)
//        labelNode.position = CGPoint(x: x, y: y)
        self.text = text
        super.init()
        self.position = CGPoint(x: x, y: y)
        self.addChild(outline)
        self.addChild(labelNode)
    }
    
    func within(point: CGPoint) -> Bool{
        if self.contains(point) {
//            AudioController.shared.playButtonClick()
            return true
        }
        else {
            return false
        }
    }
    func updateText(_ text: String){
        self.text = text
        labelNode.text = self.text
    }
    
    func setAlpha(_ alpha: CGFloat){
        labelNode.alpha = alpha
        outline.alpha = alpha
    }
    func markAsCompletedLevel(){
        labelNode.fontColor = .black
        outline.fillColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hide(){
        outline.isHidden = true
        labelNode.isHidden = true
    }
    func unhide(){
        outline.isHidden = false
        labelNode.isHidden = false
    }
    
    override func run(_ action: SKAction) {
        outline.run(action)
        labelNode.run(action)
    }
    
    override func hasActions() -> Bool {
        return outline.hasActions()
    }
    
    func runWithBlock(_ action: SKAction, block: @escaping () -> Void) {
        outline.run(action, completion: block)
        labelNode.run(action)
    }
    
    func tappedState(){
        outline.fillColor = UIColor.white
        labelNode.fontColor = UIColor.black
    }
    
    func originalState(){
        outline.fillColor = UIColor.black
        labelNode.fontColor = UIColor.white
    }
    
    deinit {
        outline.removeFromParent()
        labelNode.removeFromParent()
        self.removeFromParent()
    }
}


//var Circle = SKShapeNode(circleOfRadius: 3 ) // Size of Circle
//Circle.position = outline.position  //Middle of Screen
//Circle.fillColor = SKColor.orange
//parentScene.addChild(Circle)

//        //start top right and go counter clockwise
//        var points = [CGPoint(x: labelNode.frame.minX - buffer, y: labelNode.frame.maxY + buffer),
//                      CGPoint(x: labelNode.frame.maxX + buffer, y: labelNode.frame.maxY + buffer),
//                      CGPoint(x: labelNode.frame.maxX + buffer, y: labelNode.frame.minY - buffer),
//                      CGPoint(x: labelNode.frame.minX - buffer, y: labelNode.frame.minY - buffer),
//                      CGPoint(x: labelNode.frame.minX - buffer, y: labelNode.frame.maxY + buffer)
//        ]
//        outline = SKShapeNode(points: &points, count: points.count)

