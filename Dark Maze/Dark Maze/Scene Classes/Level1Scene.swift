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
    var currentLevel = 0
    var tapToBegin: SKLabelNode?
    var countdownTime = 3
    var gridViewable = false
    var touchedTiles = 0
    var lastTouchedTile: GridTile?
    


    
    override func didMove(to view: SKView) {
        initializeTapToBegin() //disable to temporarily so that i can go straight to the solution (skip countdown)
        
        //self.initializeGrid() //remove comment to skip countdown
        //self.drawSolution()  //remove comment to skip countdown
    }

    override func update(_ currentTime: TimeInterval) {
        if gridViewable {
            for row in tile2DArray{
                for tile in row{
                    tile.updateFrameAlpha()
                }
            }
        }
    }
    func initializeTapToBegin(){
        self.isUserInteractionEnabled = true
        let tapLabel = SKLabelNode(fontNamed: GameStyle.shared.mainFontString)
        tapLabel.text = "Tap to begin"
        tapLabel.fontSize = GameStyle.shared.textBoxFontSize
        tapLabel.fontColor = SKColor.white
        tapLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(tapLabel)
        let actionList = SKAction.sequence(
            [SKAction.fadeOut(withDuration: 2.0),
             SKAction.fadeIn(withDuration: 2.0)]
        )
        
        tapLabel.run(SKAction.repeatForever(actionList))
        tapToBegin = tapLabel
    }
    
    //does a 3 2 1 countdown on the screen and then
    //starts drawing the solution
    func countdown(){
        let number = SKLabelNode(fontNamed: GameStyle.shared.mainFontString)
        number.text = "\(countdownTime)"
        number.fontSize = 90
        number.fontColor = SKColor.white
        number.position = CGPoint(x: frame.midX, y: frame.midY + frame.midY/2)
        addChild(number)
        let actionList = SKAction.sequence(
            [SKAction.fadeIn(withDuration: 0.4),
             SKAction.fadeOut(withDuration: 0.4),
             SKAction.moveTo(y: frame.midY, duration: 0),
             SKAction.run({ self.decrementCountdown(number) }),
            SKAction.fadeIn(withDuration: 0.4),
            SKAction.fadeOut(withDuration: 0.4),
            SKAction.moveTo(y: frame.midY - frame.midY/2, duration: 0),
            SKAction.run({ self.decrementCountdown(number) }),
            SKAction.fadeIn(withDuration: 0.4),
            SKAction.fadeOut(withDuration: 0.4),
            SKAction.run({
                number.removeFromParent()
                self.countdownTime = 3
                self.initializeGrid()
                self.drawSolution()
                })
            ]
        )
        number.run(actionList)
    }
    private func decrementCountdown(_ label: SKLabelNode) -> Void{
        countdownTime -= 1
        label.text = "\(countdownTime)"
    }
    private func initializeGrid(){
        let l = LevelsData.shared.levels[LevelsData.shared.currentLevel]
        let blocksize = max(self.frame.maxX / CGFloat(l.gridSizeX + l.blockBuffer),
                            self.frame.maxX / CGFloat(l.gridSizeY + l.blockBuffer))
        let botOfGridY = frame.midY - ((CGFloat(l.gridSizeY) / 2.0) * blocksize)
        let leftOfGridX = frame.midX - ((CGFloat(l.gridSizeX) / 2.0) * blocksize) + blocksize/4
        
        for row in 0...l.gridSizeY-1{
            let offsetY = botOfGridY + blocksize * CGFloat(row) + blocksize/4
            tile2DArray.append([GridTile]())
            for col in 0...l.gridSizeX-1{
                let offsetX = leftOfGridX + blocksize * CGFloat(col) + blocksize/4
                let coord = (col,row)
                let tile = GridTile(parentScene: self, center: CGPoint(x: offsetX, y: offsetY),
                                    coord: coord, width: blocksize, height: blocksize)
                tile2DArray[row].append(tile)
            }
        }
    }
    
    //Once the solution is finished drawing and the grid appears,
    //the game begins.
    func drawSolution(){
        self.isUserInteractionEnabled = false
        let l = LevelsData.shared.levels[LevelsData.shared.currentLevel]

        for (index,coord) in l.solutionCoords.enumerated(){
            let tile = tile2DArray[coord.y][coord.x]
            let actionList = SKAction.sequence(
                [SKAction.wait(forDuration: l.delayTime * Double(index)),
                 SKAction.run { tile.switchToWhite() },
                 SKAction.fadeOut(withDuration: 2)
                ])
            tile.tile.run(actionList){
                if index == l.solutionCoords.count-1{
                    self.drawGridLines()
                    self.isUserInteractionEnabled = true
                }
            }
        }
    }
    
    private func drawGridLines(){
        for row in tile2DArray{
            for tile in row{
                tile.reInit()
                tile.strokePresent = true
            }
        }
        gridViewable = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //can we handle just first touch here?
        for t in touches {
            handleTouch(t.location(in: self))
            break //not sure if i need this
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let point = touches.first
        let positionInScene = point?.location(in: self)
        handleTouch(positionInScene!)
    }
    private func handleTouch(_ point: CGPoint){
        let l = LevelsData.shared.levels[LevelsData.shared.currentLevel]
        for row in tile2DArray{
            for tile in row{
                if case .untouched = tile.state, tile.isTouched(point: point) {
                    lastTouchedTile = tile
                    if tupleContains(a: l.solutionCoords, v: tile.gridCoord){
                        print (tile.gridCoord)
                         touchedTiles += 1
                        if touchedTiles == l.solutionCoords.count {
                            LevelsData.shared.currentLevelSuccess = true
                            self.isUserInteractionEnabled = false
                            tile.tile.run(SKAction.wait(forDuration: 1)){
                                self.endGame()
                            }
                        }
                    }
                    else{
                        LevelsData.shared.currentLevelSuccess = false
                        tile.blowUp()
                    }
                }
            }
        }
        //if begin is touched
        if let temp = tapToBegin {
            if temp.contains(point){
                temp.run(SKAction.fadeOut(withDuration: 0.5)){
                    temp.removeFromParent()
                    self.countdown()
                }
            }
        }
    }
    
    // If all the solutions coords are filled (and there wasn't a
    // failure) show the end game success (failure = false). Otherwise,
    // show the end game failure (failure = true)
    func endGame (){
        if LevelsData.shared.currentLevel == LevelsData.shared.nextLevelToComplete {
            LevelsData.shared.nextLevelToComplete += 1
        }
        for child in self.children {
            child.removeFromParent()
        }
        switchToEndGameScene()
    }
    
    private func switchToEndGameScene(){
        if let scene = SKScene(fileNamed: "EndGameScene") {
            scene.scaleMode = .aspectFill
            view?.presentScene(scene)
        }
    }
    
    /*checks an array of tuples for one in particular
    https://stackoverflow.com/questions/29736244/how-do-i-check-if-an-array-of-tuples-contains-a-particular-one-in-swift
    */
    func tupleContains(a:[(Int, Int)], v:(Int,Int)) -> Bool {
        let (c1, c2) = v
        for (v1, v2) in a { if v1 == c1 && v2 == c2 { return true } }
        return false
    }
    
    func reInitGame (){
        removeAllChildren()
        tile2DArray.removeAll()
        countdownTime = 3
        gridViewable = false
        touchedTiles = 0
        initializeGrid()
        drawSolution()
    }
}
