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
    var gameActive = false
    var skipButton: TextBoxButton?
    //var tapToBegin: SKLabelNode?
    var countdownTime = 3
    var gridViewable = false
    var touchedTiles = 0
    var lastTouchedTile: GridTile?
    var blocksize: CGFloat = 0
    var cam: SKCameraNode?
    var blockAlphaIncrement: CGFloat = 0
    var blockAlphaMin: CGFloat = 0.35
    let Level = LevelsData.shared.levels[LevelsData.shared.currentLevel]

    let endArrow = SKSpriteNode(imageNamed: "right_arrow_sprite")
    let startArrow = SKSpriteNode(imageNamed: "right_arrow_sprite")

    
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
        blocksize = max(self.frame.maxX / CGFloat(Level.gridX + Level.blockBuffer),
                            self.frame.maxX / CGFloat(Level.gridY + Level.blockBuffer))
        let botOfGridY = frame.midY - ((CGFloat(Level.gridY) / 2.0) * blocksize)
        let leftOfGridX = frame.midX - ((CGFloat(Level.gridX) / 2.0) * blocksize) + blocksize/4
        
        for row in 0...Level.gridY-1{
            let offsetY = botOfGridY + blocksize * CGFloat(row) + blocksize/4
            tile2DArray.append([GridTile]())
            for col in 0...Level.gridX-1{
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
        gameActive = false
        skipButton = TextBoxButton(x: 150, y: 100, text: "Skip", fontsize: GameStyle.shared.SmallTextBoxFontSize, buffers: (20.0,20.0), parentScene: self)

        for (index,coord) in Level.solutionCoords.enumerated(){
            let tile = tile2DArray[coord.y][coord.x]
            let actionList = SKAction.sequence(
                [SKAction.wait(forDuration: Level.delayTime * Double(index)),
                 SKAction.run { tile.switchToWhite() },
                 SKAction.fadeOut(withDuration: 2)
                ])
            tile.tile.run(actionList){
                if index == self.Level.solutionCoords.count-1{
                    self.drawGridLines()
                    //marking the first tile as available
                    self.beginGame()
                    self.gameActive = true
                    self.skipButton?.hide()
                }
            }
        }
    }
    
    func beginGame(){
        let firstTile = self.tile2DArray[(Level.solutionCoords.first?.y)!][(Level.solutionCoords.first?.x)!]
        drawArrows(firstTile: firstTile)
        firstTile.firstTile()
        let numSolutionBlocks = Level.solutionCoords.count
        blockAlphaIncrement = (1.0 - blockAlphaMin) / CGFloat(numSolutionBlocks)
    }
    
    func drawArrows(firstTile: GridTile){
        let endTile = self.tile2DArray[(Level.solutionCoords.last?.y)!][(Level.solutionCoords.last?.x)!]
        placeArrow(tile: firstTile, arrow: startArrow, orient: -1)
        placeArrow(tile: endTile, arrow: endArrow, orient: 1)
        print(startArrow.zPosition)
        print (endArrow.zPosition)
        startArrowSequence(tile: firstTile)
    }
    
    func startArrowSequence(tile: GridTile){
        var vector = CGVector()
        if tile.gridCoord.x == 0 || tile.gridCoord.x == tile2DArray[0].count - 1{
            vector = CGVector(dx: -20.0,dy: 0)
        }
        else{
            vector = CGVector(dx: 0, dy: -20)
        }
        let sequence = SKAction.sequence(
            [SKAction.move(by: vector, duration: 0.4),
             SKAction.move(by: CGVector(dx: -vector.dx,dy: -vector.dy), duration: 0.4)])
        startArrow.run(SKAction.repeatForever(sequence))
    }
    //orientation is either 1 or -1
    //1 means that it's the end arrow
    //-1 means it's the begin arrow so the arro
    func placeArrow(tile: GridTile, arrow: SKSpriteNode, orient: CGFloat){
        //ends on the right. default arrow orientation
        var point = CGPoint(x: 0, y: 0)
        var rotation: CGFloat = 0
        if tile.gridCoord.x == tile2DArray[0].count - 1{
            point = CGPoint(x: tile.tile.frame.midX + blocksize, y: tile.tile.frame.midY)
            rotation = CGFloat(.pi/2.0) - (orient * .pi/2.0)
        }
        //ends on the left. rotate 180
        else if tile.gridCoord.x == 0{
            point = CGPoint(x: tile.tile.frame.midX - blocksize, y: tile.tile.frame.midY)
            rotation = CGFloat(.pi/2.0) + (orient * .pi/2.0)
        }
        //ends on top of the grid and rotate 90 left
        else if tile.gridCoord.y == 0{
            point = CGPoint(x: tile.tile.frame.midX, y: tile.tile.frame.midY - blocksize)
            rotation = -1 * (orient * .pi/2.0)
        }
        //ends bot of grid and rotate 90 right
        else if tile.gridCoord.y == tile2DArray.count - 1{
            print("here")
            point = CGPoint(x: tile.tile.frame.midX, y: tile.tile.frame.midY + blocksize)
            rotation = (orient * .pi/2.0)
        }
        arrow.position = point
        arrow.zRotation += rotation
        print(arrow.zRotation)
        addChild(arrow)
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
            if gameActive {
                handleTouch(t.location(in: self))
                break //not sure if i need this
            }
            else{
                isMenuTouched(touch: t.location(in: self))
            }
        }
    }
    
    func isMenuTouched(touch: CGPoint){
        if (skipButton?.within(point: touch))!{
            for col in tile2DArray {
                for tile in col {
                    tile.tile.removeAllActions()
                    tile.reInit()
                }
            }
        self.drawGridLines()
        //marking the first tile as available
        self.beginGame()
        self.gameActive = true
        skipButton?.hide()
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
                    startArrow.removeAllActions()
//                    print ("(\(tile.gridCoord.x),\(tile.gridCoord.y)),",terminator:"")
//                    return //comment out to get grid coords for levels
                    lastTouchedTile = tile
                    tile.touched(alpha: blockAlphaMin + CGFloat(touchedTiles + 1) * blockAlphaIncrement)
                }
            }
        }
    }
    
    // If all the solutions coords are filled (and there wasn't a
    // failure) show the end game success (failure = false). Otherwise,
    // show the end game failure (failure = true)
    func endGame (success: Bool){
        let L = LevelsData.shared
        if L.currentLevel == L.nextLevelToComplete {
            if L.levels.count > L.nextLevelToComplete && success{
                L.nextLevelToComplete += 1
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
            view?.presentScene(scene, transition: GameStyle.shared.sceneTransition)
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
            if coord.y + 1 < tile2DArray.count{
                checkTile(x: coord.x, y: coord.y+1)
            }
        }
    }
    
    func checkTile(x: Int, y: Int){
        let tile = tile2DArray[y][x]
        switch tile.state{
        case .touched:
            return
        default:
            tile.state = .availableToTouch
            //tile.switchToGrey() //enable this line if we want to give them a preview
        }
    }
    
    func giveHint(){
        for row in tile2DArray{
            for tile in row{
                switch tile.state{
                case .availableToTouch:
                    tile.jiggle()
                default:
                    break
                }
            }
        }
    }
    
    //return true if game is over
    func isGameOver()->Bool{
        if tupleContains(a: Level.solutionCoords, v: (lastTouchedTile?.gridCoord)!){
            touchedTiles += 1
            if touchedTiles == Level.solutionCoords.count {
                LevelsData.shared.currentLevelSuccess = true
                self.gameActive = false
                successHighlightPath()
                return true
            }
        }
        else{
            self.gameActive = false
            LevelsData.shared.currentLevelSuccess = false
            lastTouchedTile?.switchToBlack()
            lastTouchedTile?.strokeAppearing = false
            lastTouchedTile?.tile.zPosition += 5
            let rotateSequence = SKAction.sequence(
                [SKAction.rotate(byAngle: 0.4, duration: 0.1),
                 SKAction.rotate(byAngle: -0.8, duration: 0.1),
                 SKAction.rotate(byAngle: 0.4, duration: 0.1)])
            lastTouchedTile!.tile.run(SKAction.repeatForever(rotateSequence))
            
            let scale = (SKAction.scale(by: 0.005, duration: 1))
            let move = (SKAction.move(to: (lastTouchedTile?.tile.position)!, duration: 1))
            cam?.run(SKAction.group([scale,move])){
                self.endGame(success: false)
            }
            return true
        }
        return false
    }

    func successHighlightPath(){
        let numSolutionBlocks = Double(Level.solutionCoords.count)
        for (i,coord) in Level.solutionCoords.enumerated(){
            let tile = tile2DArray[coord.y][coord.x]
            let sequence = SKAction.sequence(
                [SKAction.wait(forDuration: Double(i) * 1.5/numSolutionBlocks),
                SKAction.fadeAlpha(to: 1.0, duration: 0.2),
                SKAction.run({
                    tile.tile.glowWidth = 15.0
                    tile.tile.zPosition += 5
                    tile.tile.strokeColor = .white
                })
            ])
            if i == Level.solutionCoords.count - 1 {
                tile.tile.run(SKAction.sequence([sequence,SKAction.wait(forDuration: 1.0)])){
                    self.endGame(success: true)
                }
            }
            else{
                tile.tile.run(sequence)
            }
        }
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
