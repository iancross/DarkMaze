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
    var gameActive = false
    var touchedTiles = 0
    var mainFontString = "My Scars" //probably should change this sometime
    
    var repeatOrNextButton: TextBoxButton? = nil
    var levelSelectButton: TextBoxButton? = nil
    var mainMenuButton: TextBoxButton? = nil

    
    override func didMove(to view: SKView) {
        //initializeTapToBegin() //disabling temporarily so that i can go straight to the solution (skip countdown)
        self.initializeGrid()
        self.drawSolution()

    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //can we handle just first touch here?
        for t in touches {
            if gameActive {
                handleTouch(t.location(in: self))
                break
            }
            else {
                handleTouchForEndGameMenu(t.location(in: self))
                break
            }
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
        let tapLabel = SKLabelNode(fontNamed: mainFontString)
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
    
    //does a 3 2 1 countdown on the screen and then
    //starts drawing the solution
    func countdown(){
        let number = SKLabelNode(fontNamed: mainFontString)
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
                    self.gameActive = true // <-left off here
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
        for row in tile2DArray{
            for tile in row{
                if tile.isTouched(point: point) {
                    if tupleContains(a: l.solutionCoords, v: tile.gridCoord){
                        touchedTiles += 1
                        if touchedTiles == l.solutionCoords.count {
                            gameActive = false
                            endGame(failure: false)
                        }
                    }
                    //display the end game screen with failure parameters
                    else{
                        print("end game was realized")
                        gameActive = false
                        endGame(failure: true)
                    }
                }
            }
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
    
    func handleTouchForEndGameMenu(_ point: CGPoint){
        if repeatOrNextButton!.within(point: point){
            if repeatOrNextButton?.text == "Try Again"{
                reInitGame()
            }
            else{
                //do something for next level
                print ("next level")
            }
        }
        else if levelSelectButton!.within(point: point){
            print ("level select scene")
            let gameSceneTemp = SKScene(fileNamed: "LevelSelectScene")
            view?.presentScene(gameSceneTemp!, transition: SKTransition.doorsCloseHorizontal(withDuration: 0.5))
        }
        else if mainMenuButton!.within(point: point){
            print ("menu scene")
            if let scene = SKScene(fileNamed: "MenuScene") {
                scene.scaleMode = .aspectFill
                view?.presentScene(scene)
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
            self.openEndGameOptions(failure: failure)
        })
    }
    
    //first open the option modal
    //then direct the user based on selection
    //Main menu, level select, or next level?
    func openEndGameOptions (failure: Bool){
        var variableText: String
        if failure {
            print ("the variable text is try again")
            variableText = "Try Again"
        }
        else {
            variableText = "Next Level"
        }
        
        repeatOrNextButton = TextBoxButton(x: frame.midX, y: frame.midY + frame.midY/4, text: variableText, font: mainFontString, parentScene: self)
        levelSelectButton = TextBoxButton(x: frame.midX, y: frame.midY, text: "Level Select", font: mainFontString, parentScene: self)
        mainMenuButton = TextBoxButton(x: frame.midX, y: frame.midY - frame.midY/4, text: "Main Menu", font: mainFontString, parentScene: self)

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
        gameActive = false
        touchedTiles = 0
        initializeGrid()
        drawSolution()
    }
}
