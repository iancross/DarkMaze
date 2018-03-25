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
    private var strokeAlpha = 0.2
    var strokeActive = true
    var strokeAppearing = true //used to have the grid fade in and out
    let alphaDecrement = 0.005
    let parentScene: SKScene
    var state = TileState.unavailable
    
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
    init (parentScene: SKScene, coord: (Int, Int), width: CGFloat, height: CGFloat) {
        gridCoord = coord
        
        //new plan, just create a tile with generic widths then move it to the right position?
        //SUCCESS! don't use the point array, not sure why i was making it that way. Just use rectOf

        tile = SKShapeNode(rectOf: CGSize(width: width, height: height))
        tile.lineWidth = 1
        tile.glowWidth = 1
        tile.fillColor = UIColor.black
        tile.name = "Grid Tile"
        tile.strokeColor = UIColor(displayP3Red: 0.40, green: 0.40, blue: 0.40, alpha: 0.0 )
        
        var Circle = SKShapeNode(circleOfRadius: 10 ) // Size of Circle
        Circle.position = tile.position  //Middle of Screen
        Circle.fillColor = SKColor.orange

        
        //add the tile to the parent scene
        self.parentScene = parentScene
        super.init()
        self.addChild(tile)
        self.addChild(Circle)
    }
    
    func reInit(){
        tile.fillColor = originColor
        tile.alpha = 1.0
        state = .unavailable
    }

    func setColor(color: UIColor){
        tile.fillColor = color
    }
    
    func isTouched(point: CGPoint) -> Bool{
        if self.contains(point) {
            print ("weee")
            return true
        }
        else {
            return false
        }
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
    
    func touched(alpha: CGFloat){
        switch state {
        case .availableToTouch:
            switchToWhite()
            tile.alpha = alpha
            self.state = .touched
            removeOutline() //remove this if the path should have grid lines
            if let parent = self.parentScene as? Level1Scene{
                parent.updateGridState()
            }
        case .touched:
            return
        case .unavailable:
            //jiggle the available tiles
            if let parent = self.parentScene as? Level1Scene{
                parent.giveHint()
            }
        }
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
        //self.switchToWhite()
        //tile.alpha = 0.3
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
        switchToGray()
        tile.zPosition += 5
        let rotateSequence = [SKAction.rotate(byAngle: 0.2, duration: 0.3),
                        SKAction.rotate(byAngle: -0.4, duration: 0.3),
                        SKAction.rotate(byAngle: 0.2, duration: 0.3)]
        
        let graySequence =
            [SKAction.run({
                self.tile.alpha = 0;
                self.tile.fillColor = .gray;
            }),
            SKAction.fadeIn(withDuration: 0.4),
            SKAction.fadeOut(withDuration: 0.4)
        ]
        
        tile.run(SKAction.sequence(graySequence)){
            self.switchToBlack()
            self.tile.zPosition -= 5
        }
    }
    
    func firstTile(){
        self.state = .availableToTouch
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
