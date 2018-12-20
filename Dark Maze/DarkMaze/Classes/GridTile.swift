//
//  GridTile.swift
//  Dark Maze
//
//  Created by crossibc on 12/19/17.
//  Copyright © 2017 crossibc. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class GridTile: SKNode{
    var tile: SKShapeNode
    var originColor = UIColor.black
    let gridCoord: (x: Int,y: Int)
    var strokeAlpha = 0.2
    var strokeActive = true
    var strokeAppearing = true //used to have the grid fade in and out
    let alphaDecrement = 0.005
    var state = TileState.unavailable
    let outline: SKShapeNode
    var path: SKShapeNode? = nil
    var jumpIndication: Jumps?
    
    enum TileState {
        case touched
        case availableToTouch
        case unavailable
    }
    /*initialized with the points/lines in this order:
        Bot
        Right
        Top
        Left (repeated)
    */
    
    init (coord: (Int, Int), width: CGFloat, height: CGFloat) {
        gridCoord = coord
        
        //new plan, just create a tile with generic widths then move it to the right position?
        //SUCCESS! don't use the point array, not sure why i was making it that way. Just use rectOf

        tile = SKShapeNode(rectOf: CGSize(width: width, height: height))
        tile.lineWidth = 1
        tile.glowWidth = 1
        tile.fillColor = UIColor.black
        tile.name = "Grid Tile"
        tile.strokeColor = UIColor(displayP3Red: 0.40, green: 0.40, blue: 0.40, alpha: 0.0 )
        
        outline = SKShapeNode(rectOf: CGSize(width: tile.frame.width-2, height: tile.frame.height-2))
        outline.lineWidth = 1.0
        outline.fillColor = .clear
        outline.strokeColor = .white
        outline.isHidden = true
        
        //add the tile to the parent scene
        super.init()
        self.addChild(tile)
        self.addChild(outline)
    }
    
    func reInit(){
        //outline.isHidden = true
        tile.zPosition = 0
        //tile.removeAllActions()
        tile.fillColor = originColor
        tile.alpha = 1.0
        state = .unavailable
    }

    func setColor(color: UIColor){
        tile.fillColor = color
    }
    
     func pointIsWithin(_ point: CGPoint) -> Bool{
        if self.contains(point) {
            return true
        }
        else {
            return false
        }
    }
    func setLineWidth(w: CGFloat){
        tile.lineWidth = w
    }
    
    func reInitLineWidth(){
        tile.lineWidth = 1
    }
    
    func updateFrameAlpha(){
        if strokeActive{
            if strokeAlpha > 0.2 && !strokeAppearing {
                strokeAlpha -= alphaDecrement
            }
            else if strokeAlpha < 1.0 && strokeAppearing {
                strokeAlpha += alphaDecrement
            }
            else{
                strokeAppearing = !strokeAppearing
            }
            let strokeColor = UIColor(displayP3Red: 0.40, green: 0.40, blue: 0.40, alpha: CGFloat(strokeAlpha) )
            tile.strokeColor = strokeColor
        }
    }
    
    //returns true if available
    //returns false if it's unavailable
    //returns nil if it was already touched
    func touched(alpha: CGFloat) -> Bool?{
        switch state {
        case .availableToTouch:
            self.state = .touched
            removeOutline() //remove this if the path should have grid lines
            return true
        case .touched:
            return nil
        case .unavailable:
            return false
        }
    }
    func restoreOutline(){
        strokeActive = true
        tile.strokeColor = UIColor(displayP3Red: 0.40, green: 0.40, blue: 0.40, alpha: 0 )
    }
    func removeOutline(){
        strokeActive = false
        tile.strokeColor = UIColor(displayP3Red: 0.40, green: 0.40, blue: 0.40, alpha: 0 )
    }
    
    func switchToWhite(){
        tile.fillColor = .white
        tile.alpha = 1.0
    }
    
    func switchToBlack(){
        tile.fillColor = .black
        tile.alpha = 1.0
    }
    
    func switchToGray(){
        state = .availableToTouch
        tile.fillColor = .gray
    }
    
    func setAlpha(alpha: CGFloat){
        tile.alpha = alpha
    }

    func resetState(){
        switch state{
        case .availableToTouch:
            self.reInit()
        case .unavailable:
            self.reInit()
        default:
            return
        }
    }
    
    func jiggle(){
        if !tile.hasActions(){
            let angle: CGFloat = 0.2
            outline.glowWidth = 3
            tile.zPosition += 5
            
            let graySequence = [SKAction.rotate(byAngle: angle, duration: 0.1),
                                SKAction.rotate(byAngle: -angle*2.0, duration: 0.1),
                                SKAction.rotate(byAngle: angle, duration: 0.1)]
            //        let graySequence =
            //            [SKAction.run({ [weak self] in
            //                self?.tile.alpha = 0;
            //                self?.tile.fillColor = .gray;
            //            }),
            //             SKAction.fadeIn(withDuration: 0.4),
            //             SKAction.fadeOut(withDuration: 0.4)
            //        ]
            outline.isHidden = false
            outline.alpha = CGFloat(strokeAlpha)
            tile.run(SKAction.sequence(graySequence)){ [weak self] in
                //self?.tile.fillColor = originalColor
                self?.restoreOutline()
                self?.tile.zPosition -= 5
                self?.outline.isHidden = true
            }
        }
    }
    
    func firstTile(){
        self.state = .availableToTouch
    }
    
    override func removeAllActions() {
        outline.isHidden = true
        tile.removeAllActions()
    }
    
    override func copy() -> Any {
        return GridTile(coord: gridCoord, width: tile.frame.width, height: tile.frame.height)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        tile.removeFromParent()
        self.removeAllChildren()
        self.removeFromParent()
    }
}
