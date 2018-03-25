//
//  GameScene.swift
//  Dark Maze
//
//  Created by crossibc on 12/5/17.
//  Copyright © 2017 crossibc. All rights reserved.
//

import SpriteKit
import GameplayKit

protocol TestDelegate {
    func gameOver()
    func levelSelect()
}

class MenuScene: SKScene {
    var darkMaze = SKLabelNode()
    var tapToBegin = SKLabelNode()
    
    var blockPoints = [CGPoint]()
    var tileLoop = 20
    var currentTile: GridTile?
    var blocksize: CGFloat = 100
    
    override func didMove(to view: SKView) {
        darkMaze = self.childNode(withName: "DarkMaze") as! SKLabelNode
        tapToBegin = self.childNode(withName: "TapToBegin") as! SKLabelNode

        let actionList = SKAction.sequence(
            [SKAction.fadeIn(withDuration: 2.0),
            SKAction.fadeOut(withDuration: 2.0)]
        )
        darkMaze.run(SKAction.repeatForever(actionList))
        tapToBegin.run(SKAction.repeatForever(actionList))
        createNewStartPoint()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if tileLoop < 30{
            tileLoop += 1
        }
        else{
            print(blockPoints)
            let prevBlock = blockPoints.first
            blockPoints.remove(at: 0)
            var newPoint = blockRandomPoint(prevPoint: blockPoints.first!)
            while newPoint.x == prevBlock?.x && newPoint.y == prevBlock?.y{
                newPoint = blockRandomPoint(prevPoint: blockPoints.first!)
            }
            blockPoints.append(newPoint)
            currentTile = GridTile(parentScene: self, coord: (0,0), width: blocksize, height: blocksize)
            currentTile?.position = newPoint
            addChild(currentTile!)
            let actionList = SKAction.sequence(
                [SKAction.run { self.currentTile?.switchToWhite() },
                 SKAction.fadeOut(withDuration: 1.7),
                 SKAction.removeFromParent()
                ])
            currentTile?.tile.run(actionList){
            }
            tileLoop = 0
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let scene = SKScene(fileNamed: "LevelSelectScene") {
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: GameStyle.shared.sceneTransition)
        }
    }
    func createNewStartPoint(){
        let newX = arc4random_uniform(UInt32(self.frame.width))
        let newY = arc4random_uniform(UInt32(self.frame.height))
        let startingPoint = CGPoint(x: CGFloat(newX), y: CGFloat(newY))
        currentTile = GridTile(parentScene: self, coord: (0,0), width: 50.0, height: 50.0)
        currentTile?.position = startingPoint
        blockPoints.append(CGPoint(x: (currentTile?.tile.frame.midX)!, y: (currentTile?.tile.frame.midY)!)) //first is the prev
        blockPoints.append(CGPoint(x: (currentTile?.tile.frame.midX)!, y: (currentTile?.tile.frame.midY)!)) //second is the current
    }
    
    func blockRandomPoint(prevPoint: CGPoint) -> (CGPoint){
        var offsets: [CGFloat] = [0, blocksize, -blocksize]
        var randomIndex = Int(arc4random_uniform(UInt32(offsets.count)))
        var x = offsets[randomIndex]
        var y: CGFloat
        if x == 0 {
            offsets.remove(at: randomIndex)
            randomIndex = Int(arc4random_uniform(UInt32(offsets.count)))
            y = offsets[randomIndex]
        }
        else {
            y = 0
        }
        if prevPoint.x + x < self.frame.minX || prevPoint.x + x > self.frame.maxX {
            x = x * -1
        }
        if prevPoint.y + y < self.frame.minY || prevPoint.y + y > self.frame.maxY {
            y = y * -1
        }
        return CGPoint(x: prevPoint.x + x, y: prevPoint.y + y)
    }
}

