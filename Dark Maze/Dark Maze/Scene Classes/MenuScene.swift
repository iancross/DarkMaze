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
    var floatingStartButton = SKLabelNode()
    var blockPoints = [CGPoint]()
    var tileLoop = 20
    var currentTile: GridTile?
    var blocksize: CGFloat = 100
    
    override func didMove(to view: SKView) {
        floatingStartButton = self.childNode(withName: "FloatingStartGameButton") as! SKLabelNode
//        floatingStartButton.position = CGPoint(
//            x: CGFloat(arc4random_uniform(UInt32(frame.width - floatingStartButton.frame.width))),
//            y: CGFloat(arc4random_uniform(UInt32(frame.height - floatingStartButton.frame.height)))
//        )
        //floatingStartButton.position = CGPoint(x: frame.midX, y: frame.midY)
        let actionList = SKAction.sequence(
            [SKAction.fadeIn(withDuration: 2.0),
            SKAction.fadeOut(withDuration: 2.0),
            SKAction.run(moveLabel)]
        )
        floatingStartButton.run(SKAction.repeatForever(actionList))
        createNewStartPoint()
    }
    
    func moveLabel(){
//        let newX = arc4random_uniform(UInt32(self.frame.width - self.floatingStartButton.frame.size.width))
//        let newY = arc4random_uniform(UInt32(self.frame.height - self.floatingStartButton.frame.size.height)) + UInt32(self.floatingStartButton.frame.size.height)
//        let newPoint = CGPoint(x: CGFloat(newX), y: CGFloat(newY))
//        self.floatingStartButton.position = newPoint
        
    }
    override func update(_ currentTime: TimeInterval) {
        if tileLoop < 30{
            tileLoop += 1
        }
        else{
            let prevBlock = blockPoints.first
            blockPoints.remove(at: 0)
            var newPoint = blockRandomPoint(prevPoint: blockPoints.first!)
            while newPoint.x == prevBlock?.x && newPoint.y == prevBlock?.y{
                newPoint = blockRandomPoint(prevPoint: blockPoints.first!)
            }
            blockPoints.append(newPoint)
            self.currentTile?.removeFromParent()
            currentTile = GridTile(parentScene: self, center: newPoint, coord: (0,0), width: blocksize, height: blocksize)
                        
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
            view?.presentScene(scene)
        }
    }
    func createNewStartPoint(){
        let newX = arc4random_uniform(UInt32(self.frame.width))
        let newY = arc4random_uniform(UInt32(self.frame.height))
        let startingPoint = CGPoint(x: CGFloat(newX), y: CGFloat(newY))
        currentTile = GridTile(parentScene: self, center: startingPoint, coord: (0,0), width: 50.0, height: 50.0)
        print(currentTile!.tile)
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

//func drawSolution(){
//    self.isUserInteractionEnabled = false
//    let l = LevelsData.shared.levels[LevelsData.shared.currentLevel-1]
//
//    for (index,coord) in l.solutionCoords.enumerated(){
//        let tile = tile2DArray[coord.y][coord.x]
//        let actionList = SKAction.sequence(
//            [SKAction.wait(forDuration: l.delayTime * Double(index)),
//             SKAction.run { tile.switchToWhite() },
//             SKAction.fadeOut(withDuration: 2)
//            ])
//        tile.tile.run(actionList){
//            if index == l.solutionCoords.count-1{
//                self.drawGridLines()
//                self.isUserInteractionEnabled = true
//                //marking the first tile as available
//                self.beginGame()
//            }
//        }
//}

