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
    var buttonsNode: SKNode? = nil
    var levelSelectButton: TextBoxButton? = nil
    var settingsButton: TextBoxButton? = nil
    var aboutButton: TextBoxButton? = nil
    var blockPoints = [CGPoint]()
    var tileLoop = 20
    var currentTile: GridTile?
    var blocksize: CGFloat = screenWidth/7.0
    let spacingInterval: CGFloat = 0.11
    
    
    override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = UIColor.black
        anchorPoint = CGPoint(x: 0, y:0)
        _ = LevelsData.shared.currentLevelSuccess
        AudioController.shared.reInitPlayersAndSounds()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        createButtons()
        let actionList = SKAction.sequence(
            [SKAction.fadeAlpha(to: 1, duration: 2.5),
            SKAction.fadeAlpha(to: 0.3, duration: 2.5)]
        )
        darkMaze?.run(SKAction.repeatForever(actionList))
        buttonsNode?.run(SKAction.repeatForever(actionList))
        createNewStartPoint()
    }
    
    
    private func createButtons(){
        let font = screenWidth*0.09
        buttonsNode = SKNode()
        buttonsNode!.position = CGPoint(x: screenWidth/2.0, y: screenHeight*0.05)
        
        levelSelectButton = TextBoxButton(x: 0, y: screenHeight*spacingInterval*4, text: "Level Select", fontsize:font, buffers: buffers)
        settingsButton = TextBoxButton(x: 0, y: screenHeight*spacingInterval*3, text: "Settings", fontsize:font, buffers: buffers)
        aboutButton = TextBoxButton(x: 0, y: screenHeight*spacingInterval*2, text: "About", fontsize:font, buffers: buffers)
        buttonsNode!.addChild(levelSelectButton!)
        buttonsNode!.addChild(settingsButton!)
        //buttonsNode!.addChild(aboutButton!)
        
        darkMaze = SKLabelNode(text: "Dark Maze")
        darkMaze!.position = CGPoint(x: 0, y: screenHeight*0.65)
        darkMaze!.fontName = GameStyle.shared.mainFontString
        darkMaze!.fontSize = screenWidth*0.15
        
        buttonsNode?.addChild(darkMaze!)
        self.addChild(buttonsNode!)
    }

    override func update(_ currentTime: TimeInterval) {
        if tileLoop < 15{
            tileLoop += 1
        }
        else{
//            let tile = GridTile(coord: (0,0), width: blocksize, height: blocksize)
//            tile.position = CGPoint(x: screenWidth, y: spacingInterval * screenHeight / 2.0)
            let prevBlock = blockPoints.first
            blockPoints.remove(at: 0)
            var newPoint = blockRandomPoint(prevPoint: blockPoints.first!)
            while newPoint.x == prevBlock?.x && newPoint.y == prevBlock?.y{
                newPoint = blockRandomPoint(prevPoint: blockPoints.first!)
            }
            blockPoints.append(newPoint)
            currentTile = GridTile(coord: (0,0), width: blocksize, height: blocksize)
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
        for child in self.children{
            child.removeAllActions()
            child.alpha = 1.0
        }
        for i in buttonsNode?.children ?? []{
            if let child = i as? TextBoxButton{
                if !child.within(point: (touches.first?.location(in: buttonsNode!))!){
                    child.originalState()
                }
                else{
                    child.tappedState()
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for i in buttonsNode?.children ?? []{
            if let child = i as? TextBoxButton{
                if !child.within(point: (touches.first?.location(in: buttonsNode!))!){
                    child.originalState()
                }
                else{
                    child.tappedState()
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let t = touches.first?.location(in: buttonsNode ?? self)
        for i in buttonsNode?.children ?? []{
            if let child = i as? TextBoxButton{
                if child.within(point: (touches.first?.location(in: buttonsNode!))!){
                    handleButtonTouch(t!)
                    AudioController.shared.playButtonClick()
                }
            }
        }
    }
    
    func handleButtonTouch(_ point: CGPoint){
        if levelSelectButton!.within(point: point){
            (self.delegate as? GameDelegate)?.levelSelect()
        }
        else if settingsButton!.within(point: point){
            (self.delegate as? GameDelegate)?.settings()
        }
        else if let b = aboutButton{
            if b.within(point: point){
                (self.delegate as? GameDelegate)?.levelSelect()
            }
        }
    }
    func createNewStartPoint(){
        print ("create new Start point is being called")
        let newX = arc4random_uniform(UInt32(self.frame.width))
        let newY = arc4random_uniform(UInt32(self.frame.height))
        let startingPoint = CGPoint(x: CGFloat(newX), y: CGFloat(newY))
        currentTile = GridTile(coord: (0,0), width: blocksize, height: blocksize)
        let point = calcMidPointOf(a: buttonsNode?.position ?? CGPoint.zero, b: CGPoint(x: frame.midX, y: 0))
        print("midpoint is \(point)")
        currentTile?.position = startingPoint
        currentTile?.position = point
        blockPoints.append(point)
        blockPoints.append(point)
    
        
//        blockPoints.append(CGPoint(x: (currentTile?.frame.midX)!, y: (currentTile?.frame.midY)!)) //first is the prev
//        blockPoints.append(CGPoint(x: (currentTile?.frame.midX)!, y: (currentTile?.frame.midY)!)) //second is the current
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

