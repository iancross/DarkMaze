//
//  Level1Scene.swift
//  Dark Maze
//
//  Created by crossibc on 12/17/17.
//  Copyright © 2017 crossibc. All rights reserved.
//

import SpriteKit

enum Jumps {
    case diamond
    case circle
    case square
    case plus
}

class Level1Scene: SKScene {
    var tile2DArray = [[GridTile]]()
    var gameActive = false
    var skipButton: TextBoxButton?
    let blockBuffer: CGFloat = 2
    var countdownTime = 3
    var gridViewable = false
    var touchedTiles = 0
    var lastTouchedTile: GridTile?
    var blocksize: CGFloat = 0
    var cam: SKCameraNode?
    var blockAlphaIncrement: CGFloat = 0
    var blockAlphaMin: CGFloat = 0.35
    let Level = LevelsData.shared.levelGroups[LevelsData.shared.selectedLevel.page].levels[LevelsData.shared.selectedLevel.level]
    var currentLevel = LevelsData.shared.selectedLevel.level
    let currentPage = LevelsData.shared.selectedLevel.page
    var gridNode =  SKNode()
    private var crack = SKSpriteNode()
    private var crackingFrames: [SKTexture] = []
    let endArrow = SKSpriteNode(imageNamed: "right_arrow_sprite")
    let startArrow = SKSpriteNode(imageNamed: "right_arrow_sprite")
    var categoryNode: CategoryHeader?
    var jumpsTypes: [Jumps] = [.diamond, .circle, .square, .plus]
    //var jumpTiles = [(Jumps,[(x: Int, y: Int)])]()
    var jumpsToDraw = [Jumps]()
    
    override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = UIColor.black
        anchorPoint = CGPoint(x: 0, y:0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        blocksize = max(self.frame.maxX / (CGFloat(Level.gridX) + blockBuffer),
                            self.frame.maxX / (CGFloat(Level.gridY) + blockBuffer))
        let botOfGridY =  -CGFloat(Level.gridY) / 2.0 * blocksize
        let leftOfGridX = -((CGFloat(Level.gridX) / 2.0) * blocksize)
        
        for row in 0...Level.gridY-1{
            let offsetY = blocksize * CGFloat(row) + blocksize/2
            tile2DArray.append([GridTile]())
            for col in 0...Level.gridX-1{
                let offsetX = blocksize * CGFloat(col) + blocksize/2
                let coord = (col,row)
                let tile = GridTile(coord: coord, width: blocksize, height: blocksize)
                tile.position = CGPoint(x: leftOfGridX + offsetX, y: botOfGridY + offsetY)
                gridNode.addChild(tile)
                tile2DArray[row].append(tile)
            }
        }
        gridNode.position = CGPoint(x: frame.midX, y: frame.midY)
        self.addChild(gridNode)

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
        insertLevelTitle()
        let firstTile = self.tile2DArray[(Level.solutionCoords.first?.y)!][(Level.solutionCoords.first?.x)!]
        drawArrows(firstTile: firstTile)
        firstTile.firstTile()
        let numSolutionBlocks = Level.solutionCoords.count
        blockAlphaIncrement = (1.0 - blockAlphaMin) / CGFloat(numSolutionBlocks)
        modifyGrid()
    }
    
    func insertLevelTitle(){
        let progress = LevelsData.shared.selectedLevel.level + 1
        let outOfTotal = LevelsData.shared.levelGroups[currentPage].levels.count
        let category = LevelsData.shared.levelGroups[currentPage].category
        let title = "\(category) \(progress)/\(outOfTotal)"
        
        categoryNode = CategoryHeader(string: title, fontSize: GameStyle.shared.SmallTextBoxFontSize, frameWidth: frame.width)
        categoryNode?.position = CGPoint(x: frame.midX, y: frame.maxY - 100)
        addChild(categoryNode!)
    }
    
/*---------------------------------------------------------------*/
/*---------------------- Grid Modification ----------------------*/
    func modifyGrid(){
        if let mods = Level.modifications{
            for modification in mods{
                switch modification {
                case .flip:
                    flipGrid()
                }
            }
        }
    }
    func flipGrid(){
        let sequence = SKAction.sequence(
            [SKAction.run { self.gameActive = false },
            SKAction.wait(forDuration: 0.2),
            SKAction.scaleX(to: -1.0, duration: 1.0),
            SKAction.wait(forDuration: 0.3)])
        gridNode.run(sequence){
            self.gameActive = true
        }
    }
/*---------------------- End Grid Modification ----------------------*/

    
    private func drawGridLines(){
        for row in tile2DArray{
            for tile in row{
                tile.reInit()
            }
        }
        gridViewable = true
    }
    
    
/*----------------------------------------------------*/
/*---------------------- Touches ----------------------*/

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //can we handle just first touch here?
        for t in touches {
            if gameActive {
                handleTouch(t.location(in: gridNode))
                break //not sure if i need this
            }
            else{
                skip(touch: t.location(in: self))
            }
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let point = touches.first
        let positionInScene = point?.location(in: gridNode)
        if gameActive {
            handleTouch(positionInScene!)
        }
    }
    
    func skip(touch: CGPoint){
        if let within = skipButton?.within(point: touch){
            if within{
                for col in tile2DArray {
                    for tile in col {
                        tile.tile.removeAllActions()
                        tile.reInit()
                    }
                }
                self.drawGridLines()
                self.beginGame()
                self.gameActive = true
                skipButton?.hide()
            }
        }
    }
    
    private func handleTouch(_ point: CGPoint){
        for row in tile2DArray{
            for tile in row{
                if tile.pointIsWithin(point){
                    tile.removeAllActions()
                    startArrow.removeAllActions()
//                    print ("(\(tile.gridCoord.x),\(tile.gridCoord.y)),",terminator:"")
//                    tile.tile.fillColor = UIColor.green
//                    return //comment out to get grid coords for levels
                    lastTouchedTile = tile
                    touchTile(tile: lastTouchedTile!, alpha: blockAlphaMin + CGFloat(touchedTiles + 1) * blockAlphaIncrement)
                    return
                }
            }
        }
    }
    
    func touchTile(tile: GridTile, alpha: CGFloat){
        if let successfulTouch = tile.touched(alpha: alpha){
            if successfulTouch{
                if let gameOver = gameOverSuccessOrFailure(){
                    if gameOver{
                        flipTile(tile: tile, a: alpha)
                    }
                    return
                }
                flipTile(tile: tile, a: alpha)
                updateGridState()
            }
            else{
                giveHint()
            }
        }
        //if nil was returned, it means we've already
        //highlighted this tile
        else{
            if tupleContains(a: tile.gridCoord,
                             v: Level.solutionCoords[touchedTiles]){
                tile.switchToWhite()
                tile.setAlpha(alpha: alpha)
                if gameOverSuccessOrFailure() != nil{
                    return
                }
                updateGridState()
            }
        }
    }
    
/*---------------------- End Touches ----------------------*/
    func updateGridForPotentialJump(){
        if touchedTiles < Level.solutionCoords.count - 1 && lastTouchedTile?.state == .touched{
            let currCoord = Level.solutionCoords[touchedTiles-1]
            let nextCoord = Level.solutionCoords[touchedTiles]
            let xDiff = abs(nextCoord.x - currCoord.x)
            let yDiff = abs(nextCoord.y - currCoord.y)
            
            //we have an upcoming jump
            if xDiff > 1 || yDiff > 1 {
                let coords = [currCoord, nextCoord]
                let j = jumpsTypes.removeFirst()
                jumpsToDraw.append(contentsOf: [j,j])
                //addJumpIndication(t: lastTouchedTile!)

                for row in tile2DArray{
                    for tile in row{
                        switch tile.state{
                        case .touched:
                            break
                        default:
                            tile.state = .availableToTouch
                        }
                    }
                }
            }
        }
    }
    
    func addJumpIndication(t: GridTile){
        if !jumpsToDraw.isEmpty{
            let jumpType = jumpsToDraw.removeFirst()
            addSymbol(t: t, j: jumpType)
        }
    }
    
    func addSymbol(t: GridTile, j: Jumps){
        switch j{
        default:
            let circle = SKShapeNode(circleOfRadius: 10)
            circle.fillColor = UIColor.black
            
            t.addChild(circle)
            circle.position = CGPoint.zero
            circle.zPosition = 5
        }
    }
    
    func flipTile(tile: GridTile, a: CGFloat){
        tile.setColor(color: UIColor.black)
        tile.restoreOutline()
        tile.setLineWidth(w: 7.0)
        var flip = SKAction()
        let duration = 0.16
        if touchedTiles > 1 {
            let currCoord = Level.solutionCoords[touchedTiles - 1]
            let prevCoord = Level.solutionCoords[touchedTiles - 2]
            let xDiff = abs(prevCoord.x - currCoord.x)
            let yDiff = abs(prevCoord.y - currCoord.y)
            if xDiff > 0{
                flip = SKAction.scaleX(to: 0, y: 1, duration: duration)
            }
            else if yDiff > 0{
                flip = SKAction.scaleX(to: 1, y: 0, duration: duration)
            }
        }
        else{
            if lastTouchedTile?.gridCoord.x == 0{
                flip = SKAction.scaleX(to: 0, y: 1, duration: duration)
            }
            else {
                flip = SKAction.scaleX(to: 1, y: 0, duration: duration)
            }
        }
        tile.run(flip) {
            tile.removeOutline()
            tile.switchToWhite()
            tile.setAlpha(alpha: a)
            self.addJumpIndication(t: tile)
            tile.run(SKAction.scaleX(to: 1, y: 1, duration: duration))
        }
    }
    
    // If all the solutions coords are filled (and there wasn't a
    // failure) show the end game success (failure = false). Otherwise,
    // show the end game failure (failure = true)
    func endGame (success: Bool){
        _ = LevelsData.shared
        if success{
        LevelsData.shared.levelGroups[LevelsData.shared.selectedLevel.page].levels[LevelsData.shared.selectedLevel.level].levelCompleted = true
        }
        for child in self.children {
            child.removeFromParent()
        }
        switchToEndGameScene()
    }
    
    private func switchToEndGameScene(){
        (self.delegate as? GameDelegate)?.gameOver()
    }
    
    
    func updateGridState(){
        if let coord = (lastTouchedTile?.gridCoord){
            for row in tile2DArray{
                for tile in row{
                    tile.resetState()
                }
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
            updateGridForPotentialJump()
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
    
    //return true if game over as a success
    //return false if game over as a failure
    //return nil if game not over
    func gameOverSuccessOrFailure()->Bool?{
        if tupleContains(a: Level.solutionCoords[touchedTiles], v: (lastTouchedTile?.gridCoord)!){
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
            lastTouchedTile?.restoreOutline()
            let positionInScene = lastTouchedTile?.scene?.convert((lastTouchedTile?.position)!, from: (lastTouchedTile?.parent)!)
            crackAnimation(point: positionInScene!)
            return false
        }
        return nil
    }

    func successHighlightPath(){
        let numSolutionBlocks = Double(Level.solutionCoords.count)
        for (i,coord) in Level.solutionCoords.enumerated(){
            let tile = tile2DArray[coord.y][coord.x]
            tile.tile.removeAllActions()
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
    
    func crackAnimation(point: CGPoint){
        let crackingAtlas = SKTextureAtlas(named: "cracking")
        var frames: [SKTexture] = []
        let numImages = crackingAtlas.textureNames.count-1
        for i in 0...numImages{
            let crackingTextureName = "sprite_\(i)"
            frames.append(crackingAtlas.textureNamed(crackingTextureName))
        }
        crackingFrames = frames
        let firstFrameTexture = crackingFrames[0]
        crack = SKSpriteNode(texture: firstFrameTexture)
        addChild(crack)
        crack.position = point
        crack.scale(to: CGSize(width: blocksize, height: blocksize))
        crack.run(
            SKAction.sequence(
                [SKAction.animate(with: crackingFrames, timePerFrame: 2/Double(numImages), resize: false, restore: false),
                     SKAction.run({ [weak self] in
                        self?.gridNode.isHidden = true
                        self?.categoryNode?.isHidden = true
                     })
                ])
            ){
                self.disappearGrid()
            }
    }
    
    func disappearGrid(){
        gridNode.run(SKAction.fadeOut(withDuration: 0.6)){
            self.endGame(success: false)
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
    
    func crackAllTiles(){
        for coord in Level.solutionCoords.reversed(){
            let tile = tile2DArray[coord.y][coord.x]
            switch tile.state {
            case .touched:
                let center = tile.scene?.convert((tile.position), from: tile.parent!)
                crackAnimation(point: center!)
            default:
                break
            }
        }
    }
    
    
/*----------------------------------------------------------*/
/*------------------------- Arrows -------------------------*/
    func drawArrows(firstTile: GridTile){
        let endTile = self.tile2DArray[(Level.solutionCoords.last?.y)!][(Level.solutionCoords.last?.x)!]
        placeArrow(tile: firstTile, arrow: startArrow, orient: -1)
        placeArrow(tile: endTile, arrow: endArrow, orient: 1)
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
            point = CGPoint(x: tile.frame.midX + blocksize, y: tile.frame.midY)
            rotation = CGFloat(.pi/2.0) - (orient * .pi/2.0)
        }
        //ends on the left. rotate 180
        else if tile.gridCoord.x == 0{
            point = CGPoint(x: tile.frame.midX - blocksize, y: tile.frame.midY)
            rotation = CGFloat(.pi/2.0) + (orient * .pi/2.0)
        }
        //ends on top of the grid and rotate 90 left
        else if tile.gridCoord.y == 0{
            point = CGPoint(x: tile.frame.midX, y: tile.frame.midY - blocksize)
            rotation = -1 * (orient * .pi/2.0)
        }
        //ends bot of grid and rotate 90 right
        else if tile.gridCoord.y == tile2DArray.count - 1{
            point = CGPoint(x: tile.frame.midX, y: tile.frame.midY + blocksize)
            rotation = (orient * .pi/2.0)
        }
        arrow.position = point
        arrow.zRotation += rotation
        gridNode.addChild(arrow)
    }
/*---------------------- End Arrows ----------------------*/
    

    
    /*checks an array of tuples for one in particular
     https://stackoverflow.com/questions/29736244/how-do-i-check-if-an-array-of-tuples-contains-a-particular-one-in-swift
     */
    func tupleContains(a:(Int, Int), v:(Int,Int)) -> Bool {
        let (c1, c2) = v
        let (v1, v2) = a
        if v1 == c1 && v2 == c2 { return true } 
        return false
    }
}
