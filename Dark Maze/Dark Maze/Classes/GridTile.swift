//
//  GridTile.swift
//  Dark Maze
//
//  Created by crossibc on 12/19/17.
//  Copyright © 2017 crossibc. All rights reserved.
//

import Foundation

import SpriteKit

class GridTile: SKShapeNode{
    var tile: SKShapeNode
    var originColor = UIColor.black
    var black: Bool = true
    var points: [CGPoint]
    let gridCoord: (x: Int,y: Int)
    var strokePresent = false
    private var strokeAlpha = 0.0
    private var strokeAppearing = true
    let alphaDecrement = 0.005
    
    
    /*initialized with the points/lines in this order:
        Bot
        Right
        Top
        Left (repeated)
    */
    init(parentScene: SKScene, coord: (Int,Int), pointArr: [CGPoint]) {
        points = pointArr
        gridCoord = coord
        
        //add the first point to the end
        points.append(points[0])
        
        //create the tile
        tile = SKShapeNode(points: &points, count: points.count)
        tile.lineWidth = 1
        tile.glowWidth = 1
        tile.fillColor = UIColor.black
        tile.name = "Grid Tile"
        tile.strokeColor = UIColor(displayP3Red: 0.40, green: 0.40, blue: 0.40, alpha: 0.0 )
        //add the tile to the parent scene
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
        if self.black {
            tile.fillColor = UIColor.white
            tile.alpha = 1.0
            self.black = false
        }
        else{
            tile.fillColor = UIColor.black
            tile.alpha = 1.0
            self.black = true
        }
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
