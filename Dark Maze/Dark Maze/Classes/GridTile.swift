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
    var black: Bool = true
    let gridCoord: (x: Int,y: Int)
    var strokePresent = false
    private var strokeAlpha = 0.0
    private var strokeAppearing = true
    let alphaDecrement = 0.005
    let parentScene: SKScene
    var state = TileState.untouched
    
    enum TileState {
        case untouched
        case touched
        //case availableToTouch
        //case unavailable
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
        //also need to take into account calc accummulated frame

        tile = SKShapeNode(rectOf: CGSize(width: width, height: height))
        tile.position = center //need to figure out actual spot for this
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
        black = true
        tile.alpha = 1.0
        tile.lineWidth = 1
        tile.glowWidth = 1
    }

    func setColor(color: UIColor){
        tile.fillColor = color
    }
    
    func isTouched(point: CGPoint) -> Bool{
        if tile.contains(point) {
            self.touched()
            return true
        }
        else {
            return false
        }
    }
    func updateFrameAlpha(){
        if strokePresent{
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
    func touched(){
        switch state {
        case .untouched:
            print ("turn me white")
            tile.fillColor = UIColor.white
            tile.alpha = 1.0
            self.black = false
            self.state = .touched
        case .touched:
            print ("touched block is touched again")
//            tile.fillColor = UIColor.black
//            tile.alpha = 1.0
//            self.black = true
        }
    }
    func switchToWhite(){
            tile.fillColor = UIColor.white
            tile.alpha = 1.0
            self.black = false
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func blowUp (){
        tile.fillColor = UIColor.black
        tile.zPosition += 5 // need a better number here
        strokeAlpha = 1.0
        let new_tile = tile as SKShapeNode
        let embiggen = SKAction.scale(to: 20, duration: 2.0)
        let rotate = SKAction.rotate(byAngle: 10, duration: 2.0)
        let group = SKAction.group([embiggen,rotate])
        
        new_tile.run(group){
            if let parent = self.parentScene as? Level1Scene{
                print ("made it")
                parent.endGame()
            }
        }

    }
}
