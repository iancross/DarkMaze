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
    var black: Bool = true
    
    init(parentScene: SKScene, pointArr: [CGPoint]) {
        var points = pointArr
        
        //add the first point to the end
        points.append(points[0])
        
        //create the tile
        tile = SKShapeNode(points: &points, count: points.count)
        tile.lineWidth = 1
        tile.glowWidth = 2
        tile.fillColor = UIColor.black
        tile.name = "Grid Tile"
        //add the tile to the parent scene
        parentScene.addChild(tile)
        super.init()
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
    func touched(){
        if self.black {
            tile.fillColor = UIColor.white
            self.black = false
        }
        else{
            tile.fillColor = UIColor.black
            self.black = true
        }
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
