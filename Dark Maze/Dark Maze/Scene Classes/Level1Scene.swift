//
//  Level1Scene.swift
//  Dark Maze
//
//  Created by crossibc on 12/17/17.
//  Copyright © 2017 crossibc. All rights reserved.
//

import SpriteKit

class Level1Scene: SKScene {
    var tile2DArray = [[GridTile]]()
    var levelsData = LevelsData()
    var currentLevel = 0
    
    //This is the number of blocks that fit on the side. Each side would be blockBuffer/2
    
    override func didMove(to view: SKView) {
        initializeGrid()
        drawSolution()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            handleTouch(t.location(in: self))
            print (t.location(in: self))
            /*let nodesAtLocation = self.nodes(at: t.location(in: self))
            for node in nodesAtLocation{
             
            }*/
        }
    }
    private func initializeGrid(){
        let l = levelsData.levels[currentLevel]
        let blocksize = max(self.frame.maxX / CGFloat(l.gridSizeX + l.blockBuffer),
                            self.frame.maxX / CGFloat(l.gridSizeY + l.blockBuffer))
        let botOfGridY = frame.midY - ((CGFloat(l.gridSizeY) / 2.0) * blocksize)
        let leftOfGridX = frame.midX - ((CGFloat(l.gridSizeX) / 2.0) * blocksize)
        
        for row in 0...l.gridSizeY-1{
            let offsetY = botOfGridY + blocksize * CGFloat(row)
            tile2DArray.append([GridTile]())
            for col in 0...l.gridSizeX-1{
                let offsetX = leftOfGridX + blocksize * CGFloat(col)
                let coord = (col,row)
                let tile = GridTile(parentScene: self, coord: coord,
                          pointArr: [CGPoint(x:offsetX, y: offsetY),
                                     CGPoint(x:offsetX + blocksize, y: offsetY),
                                     CGPoint(x:offsetX + blocksize, y: offsetY + blocksize),
                                     CGPoint(x:offsetX, y: offsetY + blocksize)]
                )
                tile2DArray[row].append(tile)
            }
        }
    }
    func drawSolution(){
        self.isUserInteractionEnabled = false
        let l = levelsData.levels[currentLevel]
        var actionSequence = [SKAction]()
        let wait1 = SKAction.wait(forDuration: 1)
        for coord in l.solutionCoords{
            let tile = tile2DArray[coord.x][coord.y]
            var tempAction = SKAction.run {
                tile.touched()
            }
            actionSequence.append(wait1)
            actionSequence.append(tempAction)
        }
        let action = SKAction.sequence(actionSequence)
        self.run(action) {
            self.isUserInteractionEnabled = true
            print("Touches Enabled")
        }
    }
    
    private func handleTouch(_ point: CGPoint){
        for row in tile2DArray{
            for tile in row{
                if tile.isTouched(point: point) { print ("WEEEEEE") }
            }
        }
        
    }
}
