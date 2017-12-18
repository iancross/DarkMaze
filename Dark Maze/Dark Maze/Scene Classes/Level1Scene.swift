//
//  Level1Scene.swift
//  Dark Maze
//
//  Created by crossibc on 12/17/17.
//  Copyright © 2017 crossibc. All rights reserved.
//

import SpriteKit

class Level1Scene: SKScene {
    let gridSize = 4
    let blockBuffer = 2
    
    override func didMove(to view: SKView) {
        initializeGrid()
    }
    /*override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

    }*/
    private func initializeGrid(){
        let blocksize = self.frame.maxX / CGFloat(gridSize + blockBuffer)
        
        
        for index in (blockBuffer-1)...gridSize{
            let cgI = CGFloat(index)
            var points = [CGPoint(x:cgI * blocksize, y: 400),
                          CGPoint(x:cgI * blocksize + blocksize, y: 400),
                          CGPoint(x:cgI * blocksize + blocksize, y: 400-blocksize),
                          CGPoint(x:cgI * blocksize, y: 400-blocksize),
                          CGPoint(x:cgI * blocksize, y: 400)
            ]

            var tile = SKShapeNode(points: &points, count: points.count)
            tile.lineWidth = 2
            tile.glowWidth = 2
            self.addChild(tile)
        }

        //tempNode.run(action)
    }
}
