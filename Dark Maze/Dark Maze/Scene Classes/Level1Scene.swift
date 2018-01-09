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
    var tapToBegin: SKLabelNode?
    var countdownTime = 3
    var gridViewable = false
    var gameHasBegun = false
    var touchedTiles = 0

    
    override func didMove(to view: SKView) {
        initializeTapToBegin()

    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            handleTouch(t.location(in: self))
            /*let nodesAtLocation = self.nodes(at: t.location(in: self))
            for node in nodesAtLocation{
             
            }*/
        }
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
        let tapLabel = SKLabelNode(fontNamed: "My Scars")
        tapLabel.text = "Tap to begin"
        tapLabel.fontSize = 40
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
    func countdown(){
        let number = SKLabelNode(fontNamed: "My Scars")
        number.text = "\(countdownTime)"
        number.fontSize = 40
        number.fontColor = SKColor.white
        number.position = CGPoint(x: frame.midX, y: frame.midY + frame.midY/2)
        addChild(number)
        let actionList = SKAction.sequence(
            [SKAction.fadeIn(withDuration: 0.5),
             SKAction.fadeOut(withDuration: 0.5),
             SKAction.moveTo(y: frame.midY, duration: 0),
             SKAction.run({ self.decrementCountdown(number) }),
            SKAction.fadeIn(withDuration: 0.5),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.moveTo(y: frame.midY - frame.midY/2, duration: 0),
            SKAction.run({ self.decrementCountdown(number) }),
            SKAction.fadeIn(withDuration: 0.5),
            SKAction.fadeOut(withDuration: 0.5),
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
    
    //Once the solution is finished drawing and the grid appears,
    //the game begins.
    func drawSolution(){
        self.isUserInteractionEnabled = false
        let l = levelsData.levels[currentLevel]
        
        for (index,coord) in l.solutionCoords.enumerated(){
            print ("made it to the for loop")
            let tile = tile2DArray[coord.y][coord.x]
            let actionList = SKAction.sequence(
                [SKAction.wait(forDuration: l.delayTime * Double(index)),
                 SKAction.run { tile.touched() },
                 SKAction.fadeOut(withDuration: 2)
                ])
            tile.tile.run(actionList){
                if index == l.solutionCoords.count-1{
                    self.drawGridLines()
                    self.isUserInteractionEnabled = true
                    print("Touches Enabled")
                    self.gameHasBegun = true // <-left off here
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
    private func handleTouch(_ point: CGPoint){
        let l = levelsData.levels[currentLevel]
        
        var tile: GridTile
        for row in tile2DArray{
            for tile in row{
                if tile.isTouched(point: point) {
                    print(l.solutionCoords, tile.gridCoord)
                    
                    if tupleContains(a: l.solutionCoords, v: tile.gridCoord){
                        touchedTiles += 1
                    }
                    else{
                        //display the end game screen with failure parameters
                    }
                }
            }
        }
        if touchedTiles == l.solutionCoords.count {
            endGame(failure: false)
        }
        
        //if begin is touched
        if let temp = tapToBegin {
            if temp.contains(point){
                temp.run(SKAction.fadeOut(withDuration: 2.0)){
                    temp.removeFromParent()
                    self.countdown()
                }
            }
        }
    }
    
    // If all the solutions coords are filled (and there wasn't a
    // failure) show the end game success (failure = false). Otherwise,
    // show the end game failure (failure = true)
    func endGame (failure: Bool){
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            for child in self.children {
                child.removeFromParent()
            }
            self.initGameVariables()
            self.initializeTapToBegin()
        })
    }
    
    /*checks an array of tuples for one in particular
    https://stackoverflow.com/questions/29736244/how-do-i-check-if-an-array-of-tuples-contains-a-particular-one-in-swift
    */
    func tupleContains(a:[(Int, Int)], v:(Int,Int)) -> Bool {
        let (c1, c2) = v
        for (v1, v2) in a { if v1 == c1 && v2 == c2 { return true } }
        return false
    }
    
    func initGameVariables (){
        countdownTime = 3
        gridViewable = false
        gameHasBegun = false
        touchedTiles = 0
    }
}
