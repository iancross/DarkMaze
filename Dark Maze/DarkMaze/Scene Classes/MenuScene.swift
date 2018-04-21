//
//  GameScene.swift
//  Dark Maze
//
//  Created by crossibc on 12/5/17.
//  Copyright © 2017 crossibc. All rights reserved.
//

import SpriteKit
import GameplayKit


class MenuScene: SKScene {
    var darkMaze: SKLabelNode? = nil
    var tapToBegin: SKLabelNode? = nil
    
    var blockPoints = [CGPoint]()
    var tileLoop = 20
    var currentTile: GridTile?
    var blocksize: CGFloat = 100
    
    override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = UIColor.black
        anchorPoint = CGPoint(x: 0, y:0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        initDarkMazeLabel()
        let actionList = SKAction.sequence(
            [SKAction.fadeIn(withDuration: 2.0),
            SKAction.fadeOut(withDuration: 2.0)]
        )
        darkMaze?.run(SKAction.repeatForever(actionList))
        tapToBegin?.run(SKAction.repeatForever(actionList))
        createNewStartPoint()
    }
    
    func initDarkMazeLabel(){
        darkMaze = SKLabelNode(text: "Dark Maze")
        darkMaze!.position = CGPoint(x: frame.midX, y: frame.midY)
        darkMaze!.fontName = GameStyle.shared.mainFontString
        darkMaze!.fontSize = GameStyle.shared.TextBoxFontSize
        addChild(darkMaze!)
        
        tapToBegin = SKLabelNode(text: "Tap to begin")
        tapToBegin!.position = CGPoint(x: frame.midX, y: frame.midY - 100)
        tapToBegin!.fontName = GameStyle.shared.mainFontString
        tapToBegin!.fontSize = GameStyle.shared.SmallTextBoxFontSize
        addChild(tapToBegin!)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if tileLoop < 15{
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
            currentTile = GridTile(parentScene: self, coord: (0,0), width: blocksize, height: blocksize)
            currentTile?.position = newPoint
            addChild(currentTile!)
            let actionList = SKAction.sequence(
                [SKAction.run { [weak self] in self?.currentTile?.switchToWhite() },
                 SKAction.fadeOut(withDuration: 1.7),
                 SKAction.removeFromParent()
                ]
            )
            currentTile?.run(actionList)
            tileLoop = 0
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Helper.switchScene(sceneName: "LevelSelectScene", gameDelegate: self.delegate as? GameDelegate, view: self.view!)
        (self.delegate as? GameDelegate)?.levelSelect()

//        (self.delegate as? GameDelegate)?.switchToViewController()
        //view?.presentScene(nil)
    }
    func createNewStartPoint(){
        let newX = arc4random_uniform(UInt32(self.frame.width))
        let newY = arc4random_uniform(UInt32(self.frame.height))
        let startingPoint = CGPoint(x: CGFloat(newX), y: CGFloat(newY))
        currentTile = GridTile(parentScene: self, coord: (0,0), width: 50.0, height: 50.0)
        currentTile?.position = startingPoint
        blockPoints.append(CGPoint(x: (currentTile?.frame.midX)!, y: (currentTile?.frame.midY)!)) //first is the prev
        blockPoints.append(CGPoint(x: (currentTile?.frame.midX)!, y: (currentTile?.frame.midY)!)) //second is the current
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

