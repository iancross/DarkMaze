//
//  Level1Scene.swift
//  Dark Maze
//
//  Created by crossibc on 12/17/17.
//  Copyright © 2017 crossibc. All rights reserved.
//

import SpriteKit

class Level1Scene: SKScene {
    let gridSize = 2
    var tile2DArray = [[GridTile]]()
    
    //This is the number of blocks that fit on the side. Each side would be blockBuffer/2
    let blockBuffer = 3
    
    override func didMove(to view: SKView) {
        initializeGrid()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            //tile2DArray[0][0].setColor(color: UIColor.purple)
            let nodesAtLocation = self.nodes(at: t.location(in: self))
            for node in nodesAtLocation{
                print ("within for loop")
                print (node.parent)
                /*if let tile = node as? GridTile {
                    print ("made it here")
                    tile.touched()
                }*/
            }
        }
    }
    private func initializeGrid(){
        let blocksize = self.frame.maxX / CGFloat(gridSize + blockBuffer)
        
        //there will be an outsid for loop here
        tile2DArray.append([GridTile]())
        for index in 0...gridSize-1{
            let indexX = CGFloat(Float(index) + Float(blockBuffer)/2) //need to add 1 here to offs
            tile2DArray[0].append(GridTile(
                parentScene: self,
                pointArr: [CGPoint(x:indexX * blocksize, y: 400),
                     CGPoint(x:indexX * blocksize + blocksize, y: 400),
                     CGPoint(x:indexX * blocksize + blocksize, y: 400-blocksize),
                     CGPoint(x:indexX * blocksize, y: 400-blocksize)]
            ))
        }
    }
}
