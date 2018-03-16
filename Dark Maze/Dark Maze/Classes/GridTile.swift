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

class GridTile: SKShapeNode{
    var tile: SKShapeNode
    var originColor = UIColor.black
    let gridCoord: (x: Int,y: Int)
    private var strokeAlpha = 0.2
    var strokeAppearing = true
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
    init (parentScene: SKScene, center: CGPoint, coord: (Int, Int), width: CGFloat, height: CGFloat) {
        gridCoord = coord
        
        //new plan, just create a tile with generic widths then move it to the right position?
        //SUCCESS! don't use the point array, not sure why i was making it that way. Just use rectOf

        tile = SKShapeNode(rectOf: CGSize(width: width, height: height))
        tile.position = center
        tile.lineWidth = 1
        tile.glowWidth = 1
        tile.fillColor = UIColor.black
        tile.name = "Grid Tile"
        tile.strokeColor = UIColor(displayP3Red: 0.40, green: 0.40, blue: 0.40, alpha: 0.0 )
        
        //add the tile to the parent scene
        self.parentScene = parentScene
        parentScene.addChild(tile)
        super.init()

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
        if tile.contains(point) {
            return true
        }
        else {
            return false
        }
    }
    
    func updateFrameAlpha(){
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
    
    func touched(){
        switch state {
        case .availableToTouch:
            switchToWhite()
            self.state = .touched
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
    
    func switchToWhite(){
        tile.fillColor = UIColor.white
        tile.alpha = 1.0
    }
    
    func switchToBlack(){
        tile.fillColor = UIColor.black
        tile.alpha = 1.0
    }
    
    func switchToGray(){
        state = .availableToTouch
        tile.fillColor = UIColor.gray
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
//            [SKAction.colorize(with: UIColor.gray, colorBlendFactor: 1.0, duration: 3.0),
//            SKAction.colorize(with: UIColor.black, colorBlendFactor: 1.0, duration: 3.0)]
        
            [SKAction.run({
                self.tile.alpha = 0;
                self.tile.fillColor = UIColor.gray;
            }),
            //SKAction.fadeAlpha(by: 0.7, duration: 0.4),
            //SKAction.fadeAlpha(by: -0.7, duration: 3.0),
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
