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
    //var tapToBegin: SKLabelNode?
    var countdownTime = 3
    var gridViewable = false
    var touchedTiles = 0
    var lastTouchedTile: GridTile?
    var blocksize: CGFloat = 0
    var cam: SKCameraNode?
    
    let right_arrow = SKSpriteNode(imageNamed: "right_arrow_sprite")

    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        cam = SKCameraNode()
        self.camera = cam
        self.addChild(cam!)
        cam?.position = CGPoint(x: frame.midX,y: frame.midY)

        countdown()
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
        let l = LevelsData.shared.levels[LevelsData.shared.currentLevel-1]
        blocksize = max(self.frame.maxX / CGFloat(l.gridSizeX + l.blockBuffer),
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
        let l = LevelsData.shared.levels[LevelsData.shared.currentLevel-1]

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
                    //marking the first tile as available
                    self.beginGame()
                }
            }
        }
    }
    
    func beginGame(){
        let l = LevelsData.shared.levels[LevelsData.shared.currentLevel-1]
        let tile = self.tile2DArray[(l.solutionCoords.first?.y)!][(l.solutionCoords.first?.x)!]
        tile.firstTile()
        
        right_arrow.position = CGPoint(x: tile.tile.frame.minX - (blocksize/2.0), y: tile.tile.frame.midY)
        addChild(right_arrow)
        
        let end_arrow = right_arrow.copy() as! SKSpriteNode
        let end_tile = self.tile2DArray[(l.solutionCoords.last?.y)!][(l.solutionCoords.last?.x)!]
        end_arrow.position = CGPoint(x: end_tile.tile.frame.maxX + (blocksize/2.0), y: end_tile.tile.frame.midY)
        addChild(end_arrow)
    }
    private func drawGridLines(){
        for row in tile2DArray{
            for tile in row{
                tile.reInit()
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
        for row in tile2DArray{
            for tile in row{
                if tile.isTouched(point: point){
                    //print ("(\(tile.gridCoord.x),\(tile.gridCoord.y)),",terminator:"")
                    //return //comment out to get grid coords for levels
                    lastTouchedTile = tile
                    tile.touched()
                }
            }
        }
    }
    
    // If all the solutions coords are filled (and there wasn't a
    // failure) show the end game success (failure = false). Otherwise,
    // show the end game failure (failure = true)
    func endGame (success: Bool){
        if LevelsData.shared.currentLevel == LevelsData.shared.nextLevelToComplete {
            if LevelsData.shared.levels.count > LevelsData.shared.nextLevelToComplete && success{
                LevelsData.shared.nextLevelToComplete += 1
            }
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

    
    func updateGridState(){
        if let coord = (lastTouchedTile?.gridCoord){
            for row in tile2DArray{
                for tile in row{
                    tile.resetState()
                }
            }
            if isGameOver(){
                return
            }
            if coord.x - 1 >= 0{
                checkTile(x: coord.x-1,y: coord.y)
            }
            if coord.x + 1 < tile2DArray[0].count{
                checkTile(x: coord.x+1, y: coord.y)
            }
            if coord.y - 1 >= 0{
                checkTile(x: coord.x,y: coord.y-1)
            }
            if coord.y + 1 < tile2DArray[0].count{
                checkTile(x: coord.x, y: coord.y+1)
            }
        }
    }
    
    func checkTile(x: Int, y: Int){
        tile2DArray[y][x].updateTileState()
    }
    
    //return true if game is over
    func isGameOver()->Bool{
        let l = LevelsData.shared.levels[LevelsData.shared.currentLevel-1]
        if tupleContains(a: l.solutionCoords, v: (lastTouchedTile?.gridCoord)!){
            touchedTiles += 1
            if touchedTiles == l.solutionCoords.count {
                LevelsData.shared.currentLevelSuccess = true
                self.isUserInteractionEnabled = false
                lastTouchedTile?.tile.run(SKAction.wait(forDuration: 1.0)){
                    self.endGame(success: true)
                }
                return true
            }
        }
        else{
            LevelsData.shared.currentLevelSuccess = false
            lastTouchedTile?.switchToBlack()
            lastTouchedTile?.strokeAppearing = false
            let scale = (SKAction.scale(by: 0.005, duration: 1))
            let move = (SKAction.move(to: (lastTouchedTile?.tile.position)!, duration: 1))
            cam?.run(SKAction.group([scale,move])){
                self.endGame(success: false)
            }
            return true
        }
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
    
    /*checks an array of tuples for one in particular
     https://stackoverflow.com/questions/29736244/how-do-i-check-if-an-array-of-tuples-contains-a-particular-one-in-swift
     */
    func tupleContains(a:[(Int, Int)], v:(Int,Int)) -> Bool {
        let (c1, c2) = v
        for (v1, v2) in a { if v1 == c1 && v2 == c2 { return true } }
        return false
    }
}
