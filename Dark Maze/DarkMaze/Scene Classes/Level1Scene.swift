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
    let testing = false //testing variable controls touches moved and printing the green coords
    
    var tile2DArray = [[GridTile]]()
    var gameActive = false
    var tutorialActive = false
    var countdownActive = false
    var skipButton: TextBoxButton?
    var continueButton: TextBoxButton?
    var continueButtonFunction: (()->())?
    let blockBuffer: CGFloat = 2
    var countdownTime = 3
    var gridViewable = false
    var touchedTiles = 0
    var flippedTiles = 0
    var lastTouchedTile: GridTile?
    var blocksize: CGFloat = 0
    var cam: SKCameraNode?
    var blockAlphaIncrement: CGFloat = 0
    var blockAlphaMin: CGFloat = 0.35
    var Level: LevelData?
    var currentLevel = LevelsData.shared.selectedLevel.level
    let currentPage = LevelsData.shared.selectedLevel.page
    var gridNode =  SKNode()
    private var crack = SKSpriteNode()
    private var crackingFrames: [SKTexture] = []
    let endArrow = SKSpriteNode(imageNamed: "right_arrow_sprite")
    let startArrow = SKSpriteNode(imageNamed: "right_arrow_sprite")
    var categoryNode: CategoryHeader?
    var jumpsTypes: [Jumps] = [.circle, .diamond, .square, .plus]
    var jumpsToDraw = [Jumps]()
    var currOrientationIndex: Int = 0
    var startPathCoord: (x: CGFloat, y: CGFloat) = (x: 0, y: 0)
    var endPathCoord: (x: CGFloat, y: CGFloat) = (x: 0, y: 0)
    var pathLines: [SKShapeNode] = []
    var gridSpinning = false
    var nextPageUnlocked = false
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
        initializeGame()
    }
    
    private func initializeGame(){
        Level = LevelsData.shared.getSelectedLevelData()
        startPathCoord = initPathPoints(coord: (Level?.solutionCoords.first)!)
        endPathCoord = initPathPoints(coord: (Level?.solutionCoords.last)!)
        cam = SKCameraNode()
        self.camera = cam
        self.addChild(cam!)
        cam?.position = CGPoint(x: frame.midX,y: frame.midY)
        if LevelsData.shared.getPageCategory(page: currentPage) == "Intro"{
            tutorialBeforeCountdown()
        }
        else {
            countdown()
        }
    }
    private func initPathPoints(coord: (x: Int, y: Int)) -> (x: CGFloat, y: CGFloat){
        if coord.x == 0{
            return (x: -1, y: 0)
        }
        else if coord.x == (Level?.gridX)! - 1{
            return (x: 1, y: 0)
        }
        else if coord.y == 0{
            return (x: 0, y: -1)
        }
        else if coord.y == (Level?.gridY)! - 1{
            return (x: 0, y: 1)
        }
        return (x: 0, y: 0)
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
    
    private func tutorialBeforeCountdown(){
        
        var text = ""
        if currentLevel == 0{
            text = "After a short countdown, you'll be shown how to escape the maze. Pay attention, you'll need to do it in the dark..."
        }
        else if currentLevel == 1{
            text = "Be warned, the light may play tricks on you. You must prepare yourself for harder mazes yet to come..."
        }
        tutorial(text: text, buttonText: "Continue")
        continueButtonFunction = countdown
    }
    private func tutorial(text: String, buttonText: String){
        tutorialActive = true
        let instructionNode = SKNode()
        instructionNode.addChild(createInstructionBorder())
        instructionNode.addChild(createInstructionText(text: text))
        continueButton = TextBoxButton(x: frame.width/2, y: frame.height * 5/18, text: buttonText, fontsize: frame.width/13, buffers: buffers)
        instructionNode.addChild(continueButton!)
        instructionNode.addChild(addIntroTitle())
        instructionNode.alpha = 0
        addChild(instructionNode)
        instructionNode.run(SKAction.fadeIn(withDuration: 0.5))
    }
    
    private func addIntroTitle() -> SKLabelNode{
        let label = Helper.createGenericLabel("Intro: \(currentLevel + 1)", fontsize: frame.width/13)
        label.horizontalAlignmentMode = .left
        label.position = CGPoint(x: frame.width * 1/6, y: frame.height * 31/36)
        return label
    }
    private func createInstructionBorder()->SKShapeNode{
        let outline = SKShapeNode(rectOf: CGSize(width: frame.width * 2/3, height: frame.height * 2/3))
        outline.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        outline.lineWidth = 2 + frame.width/500.0
        return outline
    }
    private func createInstructionText(text: String)->SKLabelNode{
        let instruction = Helper.createGenericLabel(text, fontsize: frame.width/13.5)
        instruction.verticalAlignmentMode = .top
        instruction.position = CGPoint(x: frame.width / 2, y: frame.height * 0.81)
        instruction.preferredMaxLayoutWidth = frame.width * 0.59
        instruction.numberOfLines = 0
        instruction.lineBreakMode = .byWordWrapping
        return instruction
    }
    
    //does a 3 2 1 countdown on the screen and then
    //starts drawing the solution
    func countdown(){
        tutorialActive = false
        removeAllChildren()
        countdownActive = true
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
            SKAction.fadeOut(withDuration: 0.4)
            ]
        )
        number.run(actionList){
            self.countdownActive = false
            number.removeFromParent()
            self.initializeGrid()
            self.drawSolution()
        }
    }
    
    private func decrementCountdown(_ label: SKLabelNode) -> Void{
        countdownTime -= 1
        label.text = "\(countdownTime)"
    }
    
    private func initializeGrid(){
        blocksize = max(self.frame.maxX / (CGFloat(Level!.gridX) + blockBuffer),
                            self.frame.maxX / (CGFloat(Level!.gridY) + blockBuffer))
        let botOfGridY =  -CGFloat(Level!.gridY) / 2.0 * blocksize
        let leftOfGridX = -((CGFloat(Level!.gridX) / 2.0) * blocksize)
        
        for row in 0...Level!.gridY-1{
            let offsetY = blocksize * CGFloat(row) + blocksize/2
            tile2DArray.append([GridTile]())
            for col in 0...Level!.gridX-1{
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
        addSkipButton()
        if let mods = Level!.modifications{
            for (i, (mod, modData)) in mods.enumerated(){
                switch mod {
                case .divideAndConquer:
                    drawDivideAndConquer()
                case .blockReveal:
                    if let arr = modData as? [Int]{
                        drawBlockReveal(blocksToDisplay: arr)
                    }
                case .jumbled:
                    print ("fuck")
                    if let pairs = modData as? [((x: Int,y: Int),(x: Int,y: Int))]{
                        print ("drawing pairs!!!")
                        drawJumbled(pairs: pairs)
                    }
                    //I think we might have to just DRAW it jumbled and then the graph is later represented as it should be
                    //Leaving off here
                case .splitPath:
                    //drawSplitPath(splitPaths: modData as! [[(Int, Int)]])
                    print ("split path")
                default:
                    print("calling draw normal from default")
                    if i == mods.count - 1{
                        drawNormal()
                    }
                }
            }
        }
        else{
            print("calling draw normal from getting nil in mods")
            drawNormal()
        }
    }
    
    func addSkipButton(){
        let bottomOfGridY = screenHeight/2.0 - (gridNode.calculateAccumulatedFrame().height/2.0)
        let y = bottomOfGridY - bottomOfGridY/2.0
        skipButton = TextBoxButton(x: screenWidth/4.0, y: y, text: "Skip", fontsize: blocksize/3.0, buffers: (blocksize/5.0,blocksize/5.0))
        self.addChild(skipButton!)
    }
    
    func drawNormal(){
        print("drawingNormal")
        for (index,coord) in Level!.solutionCoords.enumerated(){
            let tile = tile2DArray[coord.y][coord.x]
            runDrawingActions(tiles: [tile],
                lastTile: (index == self.Level!.solutionCoords.count-1),
                delay: Level!.delayTime * Double(index)
            )
        }
    }
    
    func drawJumbled(pairs: [((x: Int,y: Int),(x: Int,y: Int))]){
        print ("drawingJumbled")
        for pair in pairs{
            let (coord1, _) = pair
            let (_, coord2) = pair
            let tile1 = tile2DArray[coord1.y][coord1.x]
            let tile2 = tile2DArray[coord2.y][coord2.x]
            tile2DArray[coord1.y][coord1.x] = tile2
            tile2DArray[coord2.y][coord2.x] = tile1
            tile1.gridCoord = coord2
            tile2.gridCoord = coord1
        }
        drawNormal()
    }

    func drawBlockReveal(blocksToDisplay: [Int]){
        print ("drawingBlockedReveal")
        var solutionCoordIndex = 0
        for (i,num) in blocksToDisplay.enumerated(){
            var solutionTiles = [GridTile]()
            var counter = 0
            while counter < num && (solutionCoordIndex + counter) < (Level?.solutionCoords.count)!{
                let coord = Level?.solutionCoords[solutionCoordIndex + counter]
                solutionTiles.append(tile2DArray[coord!.y][coord!.x])
                counter += 1
            }
            runDrawingActions(tiles: solutionTiles, lastTile: false, delay: Level!.delayTime * Double(i))
            solutionCoordIndex += counter
        }
       
    }
    
    
    func drawDivideAndConquer(){
        print ("drawingDivideAndConquer")
        let numTiles = Level!.solutionCoords.count
        var left,right: Int
        if numTiles % 2 == 0 { //even
            left = numTiles/2 - 1
            right = numTiles/2
        }
        else{ //odd
            left = numTiles/2
            right = numTiles/2
        }
        
        for i in 0...left{
            let coord1 = Level!.solutionCoords[left-i]
            let coord2 = Level!.solutionCoords[right+i]
            let tile1 = tile2DArray[coord1.y][coord1.x]
            let tile2 = tile2DArray[coord2.y][coord2.x]
            let tiles = [tile1, tile2]
            runDrawingActions(tiles: tiles, lastTile: (left - i == 0), delay: Level!.delayTime * Double(i))
        }
    }

    
    func runDrawingActions(tiles: [GridTile], lastTile: Bool, delay: Double){
        for (index,t) in tiles.enumerated(){
            let actionList = SKAction.sequence(
                [SKAction.wait(forDuration: delay),
                 SKAction.run { t.switchToWhite() },
                 SKAction.fadeOut(withDuration: 2)
                ])
            t.tile.run(actionList){
                if lastTile && index == tiles.count-1{
                    t.tile.run(SKAction.wait(forDuration: 0.1)){
                        self.drawGridLines()
                        //marking the first tile as available
                        self.beginGame()
                        print ("gameActive = true in 'runDrawingActions'")
                        self.skipButton?.hide()
                    }
                }
            }
        }
    }
    
    func beginGame(){
        gameActive = true
        insertLevelTitle()
        let numSolutionBlocks = Level!.solutionCoords.count
        blockAlphaIncrement = (1.0 - blockAlphaMin) / CGFloat(numSolutionBlocks)
        modifyGrid()
    }
    
    func setFirstTile(){
        print ("setting first tile")
        let firstTile = self.tile2DArray[(Level!.solutionCoords.first?.y)!][(Level!.solutionCoords.first?.x)!]
        firstTile.firstTile()
        drawArrows(firstTile: firstTile)
    }
    
    func insertLevelTitle(){
        let progress = LevelsData.shared.selectedLevel.level + 1
        let outOfTotal = LevelsData.shared.getNumLevelsOnPage(page: LevelsData.shared.selectedLevel.page)
        let category = LevelsData.shared.getPageCategory(page: LevelsData.shared.selectedLevel.page)
        let title = "\(category) \(progress)/\(outOfTotal)"
        
        categoryNode = CategoryHeader(string: title, fontSize: blocksize/3.0, frameWidth: frame.width)
        categoryNode?.position = CGPoint(x: frame.midX, y: frame.maxY - screenHeight*0.05)
        addChild(categoryNode!)
    }
    
/*---------------------------------------------------------------*/
/*---------------------- Grid Modification ----------------------*/
    //it's the responsibility of each modification to set gameActive to false
    //if need be
    func modifyGrid(){
        var actions: [SKAction] = []
        if let mods = Level!.modifications{
            for (mod, modData) in mods{
                switch mod {
                case .flip:
                    actions.append(flipGrid())
                    //we also need to flip the arrows oops
                case .spin:
                    if let r = modData as? CGFloat{
                        actions.append(spinGrid(rotation: r))
                    }
                case .splitPath:
                    print ("splitPath")
                case .jumbled:
                    if let pairs = modData as? [((Int,Int),(Int,Int))]{
                        gameActive = false
                        for (i,(x, y)) in pairs.enumerated(){
                            swapTiles(coord1: x, coord2: y, lastPair: i == pairs.count-1)
                        }
                    }
                default:
                    print ("this is being called")
                    gameActive = true
                    setFirstTile()
                }
            }
            print("actions \(actions)")
            gridNode.run(SKAction.sequence(actions)){
                print ("gridNode running")
                self.gameActive = true
                self.setFirstTile()
                
                //testing
                self.testingFlipAllTiles()
            }
        }
        else{
            gameActive = true
            setFirstTile()
        }
    }
    
    func testingFlipAllTiles(){
        for coord in (Level?.solutionCoords)!{
            tile2DArray[coord.y][coord.x].setColor(color: .purple)
        }
    }
    
    func spinGrid(rotation: CGFloat) -> SKAction{
        gridSpinning = true
        let d = abs(rotation / (CGFloat.pi / 4.0) * 0.3)
        print("\(rotation) / \(CGFloat.pi / 4.0) * 0.4 = \(d)")
        let action = SKAction.rotate(byAngle: rotation, duration: Double(d))
        //setFirstTile()
        return action
//        gridNode.run(sequence){
//            print ("gameActive = true in spinGrid")
//            self.gameActive = true
//        }
    }
    func flipGrid()->SKAction{
        let sequence = SKAction.sequence(
            [SKAction.run { self.gameActive = false },
            SKAction.wait(forDuration: 0.2),
            SKAction.scaleX(to: -1.0, duration: 1.0),
            SKAction.wait(forDuration: 0.3)])
        //setFirstTile()
        return sequence
//        gridNode.run(sequence){
//            print ("gameActive = true in flipGrid")
//            self.gameActive = true
//        }
    }
    private func swapTiles(coord1: (x: Int, y: Int), coord2: (x: Int, y: Int), lastPair: Bool){
        gameActive = false
        let tile1 = tile2DArray[coord1.y][coord1.x]
        let tile2 = tile2DArray[coord2.y][coord2.x]
        let tile1OriginalPosition = tile1.position
        let tile2OriginalPosition = tile2.position
        let controlPointPairs = getBezierControlPoints(a: tile1.position, b: tile2.position)
        runBezierMovement(tile1: tile1, tile2: tile2, controlPointPair: controlPointPairs[0], endPosition: tile2OriginalPosition, lastSwappedPair: false)
        runBezierMovement(tile1: tile2, tile2: tile1, controlPointPair: controlPointPairs[1], endPosition: tile1OriginalPosition, lastSwappedPair: lastPair)
        
        //now swap gridCoords
        let original = tile1.gridCoord
    }
    
    private func runBezierMovement(tile1: GridTile, tile2: GridTile, controlPointPair: [CGPoint], endPosition: CGPoint, lastSwappedPair: Bool){
        let path = UIBezierPath()
        path.move(to:tile1.position )
        path.addCurve(to: tile2.position, controlPoint1: controlPointPair[0], controlPoint2: controlPointPair[1])
        
        //tile1.tile.fillColor = .orange
        let s = SKAction.sequence(
        [SKAction.run({
                tile1.zPosition = 1
            }),
            SKAction.follow(path.cgPath, asOffset: false, orientToPath: false, duration: 5)
        ])
        
        tile1.run(s){
            tile1.position = endPosition
            if lastSwappedPair{
                self.setFirstTile()
                print ("gameActive = true in runBezierMovement")
                self.gameActive = true
            }
        }
    }
    
    private func getBezierControlPoints(a: CGPoint, b: CGPoint)->[[CGPoint]]{
        let mid = calcMidPointOf(a: a, b: b)
        let slope = calcSlopeOf(a: a, b: b)
        print ("slope is \(slope)")
        let hypotenuseD = calcDistanceBetweenPoints(a: a, b: b)
        print("hypotenuse distance between a and b is \(hypotenuseD)")
        let sideDistance = calcSidesOfPerfectRightTriangleGiven(hypotenuse: hypotenuseD)
        print ("sideDistance of a right perfect triangle is \(sideDistance)")
        let distanceFromMidToRightAngle = calcSideOfRightTriangle(hypotenuse: sideDistance, side: hypotenuseD/2)/1.5 //dividing by 2 to make it a bit closer
        let vertexPoints = calcPointsGiven(source: mid, slope: calcPerpendicularSlope(s: slope), distance: distanceFromMidToRightAngle)
        let controlPoints = [calcMidPointOf(a: a, b: vertexPoints[0]), calcMidPointOf(a: b, b: vertexPoints[0])]
        let controlPointsPrime = [calcMidPointOf(a: a, b: vertexPoints[1]), calcMidPointOf(a: b, b: vertexPoints[1])]
        return [controlPoints,controlPointsPrime]
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
                if !countdownActive{
                    if tutorialActive{
                        if(continueButton?.within(point: (t.location(in: self))))!{
                            continueButton!.tappedState()
                        }
                        else{
                            continueButton!.originalState()
                        }
                    }
                    else{
                        if (skipButton?.within(point: (t.location(in: self))))!{
                            skipButton!.tappedState()
                        }
                        else{
                            skipButton!.originalState()
                        }
                    }
                }
                else{ //if count down IS happening, let's clear it
                    self.countdownActive = false
                    removeAllChildren()
                    self.initializeGrid()
                    self.drawSolution()
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            if gameActive {
                break
            }
            else{
                if !countdownActive{
                    if tutorialActive{
                        if(continueButton?.within(point: (t.location(in: self))))!{
                            removeAllChildren()
                            if let f = continueButtonFunction{
                                f()
                            }
                        }
                        else{
                            continueButton!.originalState()
                        }
                    }
                    else{
                        if (skipButton?.within(point: (t.location(in: self))))!{
                            skip(touch: t.location(in: self))
                        }
                        else{
                            skipButton!.originalState()
                        }
                    }
                }
            }
        }
    }
    
    override func  touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //testing
        if !testing{
            let point = touches.first
            let positionInScene = point?.location(in: gridNode)
            if gameActive {
                handleTouch(positionInScene!)
            }
            else{
                if !countdownActive{
                    if !countdownActive{
                        if tutorialActive{
                            if(continueButton?.within(point: (point!.location(in: self))))!{
                                continueButton!.tappedState()
                            }
                            else{
                                continueButton!.originalState()
                            }
                        }
                        else{
                            if (skipButton?.within(point: (point!.location(in: self))))!{
                                skipButton!.tappedState()
                            }
                            else{
                                skipButton!.originalState()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func skip(touch: CGPoint){
        for col in tile2DArray {
            for tile in col {
                tile.removeAllActions()
                tile.reInit()
            }
        }
        self.drawGridLines()
        self.beginGame()
        print ("gameActive = true in skip")
        skipButton?.hide()
    }
    
    private func handleTouch(_ point: CGPoint){
        for row in tile2DArray{
            for tile in row{
                if tile.pointIsWithin(point){
                    startArrow.removeAllActions()

                    //testing
                    if testing{
                        print ("(\(tile.gridCoord.x),\(tile.gridCoord.y)),",terminator:"")
                        tile.tile.fillColor = UIColor.green
                        return //comment out to get grid coords for levels
                    }

                    lastTouchedTile = tile
                    touchTile(tile: lastTouchedTile!, alpha: blockAlphaMin + CGFloat(touchedTiles + 1) * blockAlphaIncrement)
                    return
                }
            }
        }
    }
    
    func touchTile(tile: GridTile, alpha: CGFloat){
        print ("tile state when it's touched is \(tile.state)")
        if let successfulTouch = tile.touched(alpha: alpha){
            if successfulTouch{
                if let gameOver = gameOverSuccessOrFailure(alpha: alpha){
                    if gameOver{
                        flipTile(tile: tile, a: alpha, repeatTile: false, highlightPathAfterFlip: true)
                    }
                    return
                }
                flipTile(tile: tile, a: alpha, repeatTile: false, highlightPathAfterFlip: false)
                updateGridState()
            }
            else{
                giveHint()
            }
        }
        //if nil was returned, it means we've already highlighted this tile
        else{
            print ("nil was returned")
            //if the tile is already touched but it's the bridge
            if isTileAdjacentAndUpcoming(tileToTest: tile){
                if gameOverSuccessOrFailure(alpha: alpha) != nil{
                    flipTile(tile: tile, a: alpha, repeatTile: true, highlightPathAfterFlip: true)
                    return
                }
                flipTile(tile: tile, a: alpha, repeatTile: true, highlightPathAfterFlip: false)
                updateGridState()
            }
        }
    }
/*---------------------- End Touches ----------------------*/
    func isTileAdjacentAndUpcoming(tileToTest: GridTile)->Bool{
        let tiles = adjacentTiles()
        for t in tiles{
            if touchedTiles <= 1 && tupleContains(a: t.gridCoord, v: tileToTest.gridCoord){
                return true
            }
            else if touchedTiles > 1{
                
                if tupleContains(a: (Level?.solutionCoords[touchedTiles-2])!, v: tileToTest.gridCoord){
                    return false
                }
                else {
                    if tupleContains(a: t.gridCoord, v: tileToTest.gridCoord){
                        return true
                    }
                }
            }
        }
        return false
    }
    
    //returns a list of gridTiles that are adjacent to the passed in tile
    // and not the previous tile
    func adjacentTiles()->[GridTile]{
        var tiles: [GridTile] = []
        if touchedTiles == 0{
            let coord = Level!.solutionCoords[0]
            tile2DArray[(coord.y)][coord.x].jiggle()
        }
        else if let coord = Level?.solutionCoords[touchedTiles - 1]{
            if coord.x - 1 >= 0{
                tiles.append(tile2DArray[coord.y][coord.x-1])
            }
            if coord.x + 1 < tile2DArray[0].count{
                tiles.append(tile2DArray[coord.y][coord.x+1])
            }
            if coord.y - 1 >= 0{
                tiles.append(tile2DArray[coord.y-1][coord.x])
            }
            if coord.y + 1 < tile2DArray.count{
                tiles.append(tile2DArray[coord.y+1][coord.x])
            }
        }
        return tiles
    }
    
    func jiggleNew(){
        let tiles = adjacentTiles()
        for tile in tiles{
            if touchedTiles <= 1{
                tile.jiggle()
            }
            else if touchedTiles > 1 && !tupleContains(a: (Level?.solutionCoords[touchedTiles-2])!, v: tile.gridCoord){
                tile.jiggle()
            }
        }
    }
        
    func updateGridForPotentialJump(){
        if nextTileIsJump(fromTileNumber: touchedTiles){
            //print ("this tile need a jump indication \(Level?.solutionCoords[touchedTiles-1])")
            let j = jumpsTypes.removeFirst()
            if let coord = Level?.solutionCoords[touchedTiles-1]{
                tile2DArray[coord.y][coord.x].jumpIndication = j
            }
            if let coord2 = Level?.solutionCoords[touchedTiles]{
                tile2DArray[coord2.y][coord2.x].jumpIndication = j
            }
            //jumpsToDraw.append(contentsOf: [j,j])

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
    
    func nextTileIsJump(fromTileNumber: Int) -> Bool{
        if fromTileNumber < Level!.solutionCoords.count && fromTileNumber > 0 && lastTouchedTile?.state == .touched{
            let currCoord = Level!.solutionCoords[fromTileNumber-1]
            let nextCoord = Level!.solutionCoords[fromTileNumber]
            let xDiff = abs(nextCoord.x - currCoord.x)
            let yDiff = abs(nextCoord.y - currCoord.y)
            
            //we have an upcoming jump
            if xDiff > 1 || yDiff > 1 || (xDiff == 1 && yDiff == 1)  {
                return true
            }
        }
        else{
            print("this index is past what is allowed in nextTileIsJump")
        }
        return false
    }
    
    func addJumpIndication(t: GridTile){
        if let jump = t.jumpIndication{
            addSymbol(t: t, j: jump)
        }
//        if !jumpsToDraw.isEmpty{
//            let jumpType = jumpsToDraw.removeFirst()
//            addSymbol(t: t, j: jumpType)
//        }
    }
    
    func addSymbol(t: GridTile, j: Jumps){
        switch j{
        case .circle:
            let circle = SKShapeNode(circleOfRadius: blocksize/10)
            circle.fillColor = .black
            circle.lineWidth = 0
            t.addChild(circle)
            circle.position = .zero
            circle.zPosition = 5
        case .diamond:
            let diamond = SKShapeNode(rectOf: CGSize(width: blocksize/5, height: blocksize/5))
            diamond.fillColor = .black
            diamond.zRotation += CGFloat(Double.pi/2.0)
            t.addChild(diamond)
            diamond.position = .zero
        default:
            print("default")
        }
    }
    
    func flipTile(tile: GridTile, a: CGFloat, repeatTile: Bool, highlightPathAfterFlip: Bool){
        touchedTiles += 1
        var flip = SKAction()
        let duration = 0.16
        if touchedTiles > 1 {
            let currCoord = Level!.solutionCoords[touchedTiles - 1]
            let prevCoord = Level!.solutionCoords[touchedTiles - 2]
            let xDiff = abs(prevCoord.x - currCoord.x)
            let yDiff = abs(prevCoord.y - currCoord.y)
            if xDiff > 0{
                flip = SKAction.scaleX(to: 1, y: 0, duration: duration)
            }
            else if yDiff > 0{
                flip = SKAction.scaleX(to: 0, y: 1, duration: duration)
            }
        }
        else{
            if lastTouchedTile?.gridCoord.x == 0{
                flip = SKAction.scaleX(to: 1, y: 0, duration: duration)
            }
            else {
                flip = SKAction.scaleX(to: 0, y: 1, duration: duration)
            }
        }
        let paths = self.drawPath(currTile: tile, repeatTile: repeatTile, alpha: alpha)
        tile.run(flip) {
            //if we aren't passing over a previously flipped tile
            //if !repeatTile{
                tile.removeOutline()
                tile.switchToWhite()
                tile.setAlpha(alpha: a)
                self.addJumpIndication(t: tile)
            
            //}
            tile.run(SKAction.scaleX(to: 1, y: 1, duration: duration)){
                for path in paths {
                    tile.path = path
                    self.gridNode.addChild(path)   //accounts for the null path, means we have a null jump
                }
                if highlightPathAfterFlip {
                    self.successHighlightPath()
                }
            }
        }
    }
    
    
    //We pass in the current tile otherwise we could update touchedtiles a bunch of times
    //Returns either the path to draw or nil (if it's a jump)
    private func drawPath(currTile : GridTile, repeatTile: Bool, alpha: CGFloat) -> [SKShapeNode]{
        if nextTileIsJump(fromTileNumber: touchedTiles - 1){
            return []
        }
        var path = [SKShapeNode]()
        //we are dealing with the first coordinate
        if touchedTiles == 1{//tupleContains(a: currTile.gridCoord, v: (Level?.solutionCoords[0])!){
            print ("first coord")
            let point = CGPoint(x: currTile.position.x + startPathCoord.x * blocksize / 2.0, y: currTile.position.y + startPathCoord.y * blocksize / 2.0)
            path = [connectPoints(points: [point, currTile.position], repeatTile: repeatTile, alpha: alpha)]
        }
        //we are dealing with the last solution coord
        else if touchedTiles == (Level?.solutionCoords.count ?? 0){//tupleContains(a: currTile.gridCoord, v: (Level?.solutionCoords.last)!){
            print ("last")
            let prevCoord = (Level?.solutionCoords[touchedTiles-2])!
            let prevTile = tile2DArray[prevCoord.y][prevCoord.x]
            let point = CGPoint(x: currTile.position.x + endPathCoord.x * blocksize / 2.0, y: currTile.position.y + endPathCoord.y * blocksize / 2.0)
            path = [connectPoints(points: [prevTile.position, currTile.position], repeatTile: repeatTile, alpha: alpha),
                    connectPoints(points: [currTile.position, point], repeatTile: repeatTile, alpha: alpha)]
        }
        //all the tiles in the middle
        else{
            print ("middle")
            let prevCoord = (Level?.solutionCoords[touchedTiles-2])!
            let prevTile = tile2DArray[prevCoord.y][prevCoord.x]
            path = [connectPoints(points: [prevTile.position, currTile.position], repeatTile: repeatTile, alpha: alpha)]
        }
        self.pathLines = self.pathLines + path
        return path
    }

    
    private func connectPoints(points: [CGPoint], repeatTile: Bool, alpha: CGFloat) -> SKShapeNode{
        let path = UIBezierPath()
        for i in 0...points.count - 2{
            path.move(to: points[i])
            path.addLine(to: points[i+1])
        }
        let line = SKShapeNode()
        line.lineCap = .round
        line.path = path.cgPath
        line.lineWidth = blocksize/10
        line.strokeColor = .black
        line.zPosition = 9
        line.name = "Line"
        return line
    }
    
    private func convertIndexToTile(i: Int)->GridTile?{
        if i > 0{
            let coord = Level!.solutionCoords[i]
            let tile = tile2DArray[coord.y][coord.x]
            print(tile.gridCoord)
            return tile
        }
        return nil
    }
    
    private func tileIsRepeat(tileNumber: Int) -> Bool{
        let coord = Level!.solutionCoords[tileNumber]
        print(coord)
        let tile = tile2DArray[coord.y][coord.x]
        return (tile.tile.fillColor != .black)
    }

    // If all the solutions coords are filled (and there wasn't a
    // failure) show the end game success (failure = false). Otherwise,
    // show the end game failure (failure = true)
    func endGame (success: Bool){
        let nextLevelUnlockedBefore = LevelsData.shared.isPageUnlocked(page: LevelsData.shared.selectedLevel.page + 1)
        
        
        LevelsData.shared.levelCompleted(success: success)
        
        let nextLevelUnlockedAfter = LevelsData.shared.isPageUnlocked(page: LevelsData.shared.selectedLevel.page + 1)
        for child in self.children {
            child.removeFromParent()
        }
        nextPageUnlocked = !nextLevelUnlockedBefore && nextLevelUnlockedAfter
        if LevelsData.shared.getPageCategory(page: currentPage) == "Intro"{
            var text = ""
            var buttonText = ""
            if currentLevel == 0{
                if success {
                    text = "Always try to escape on your first try, this will give you a bonus to help you later..."
                    buttonText = "Next Level"
                    LevelsData.shared.nextLevel()
                }
                else{
                    text = "You stepped outside the maze..."
                    buttonText = "Try Again"
                }
            }
            else if currentLevel == 1{
                if !success{
                    LevelsData.shared.levelCompleted(success: true)
                }
                nextPageUnlocked = true
                text = "You're obviously not prepared. Let's start at the beginning..."
                buttonText = "Continue"
            }
            tutorial(text: text, buttonText: buttonText)
            continueButtonFunction = tutorialContinue
        }
        else{
            switchToEndGameScene()
        }
        
    }
    
    private func tutorialContinue(){
        if currentLevel == 0{
            //LevelsData.shared.nextLevel()
            removeAllChildren()
            (self.delegate as? GameDelegate)?.playGame()
        }
        else if currentLevel == 1{
            LevelsData.shared.nextLevel()
            (self.delegate as? GameDelegate)?.levelSelect()
        }
        
    }
    
    private func switchToEndGameScene(){
        (self.delegate as? GameDelegate)?.gameOver(unlockedLevel: nextPageUnlocked)
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
        }
    }
    
    func giveHint(){
        jiggleNew()
    }
    
    //return true if game over as a success
    //return false if game over as a failure
    //return nil if game not over
    func gameOverSuccessOrFailure(alpha: CGFloat)->Bool?{
        if tupleContains(a: Level!.solutionCoords[touchedTiles], v: (lastTouchedTile?.gridCoord)!){
            if tupleContains(a: (Level!.solutionCoords.last)!, v: (lastTouchedTile?.gridCoord)!) && touchedTiles - 1 >= (Level?.solutionCoords.count ?? 0) - 2 {
                LevelsData.shared.currentLevelSuccess = true
                self.gameActive = false
                return true
            }
        }
        else{
            touchedTiles += 1
            self.gameActive = false
            LevelsData.shared.currentLevelSuccess = false
            lastTouchedTile?.restoreOutline()
            let positionInScene = lastTouchedTile?.scene?.convert((lastTouchedTile?.position)!, from: (lastTouchedTile?.parent)!)

            lastTouchedTile?.switchToWhite()
            lastTouchedTile?.setAlpha(alpha: alpha)
            let paths = drawPath(currTile: lastTouchedTile!, repeatTile: false, alpha: alpha)
            for path in paths{
                self.gridNode.addChild(path)   //accounts for the null path, means we have a null jump
            }
            crackAnimation(point: positionInScene!)
            return false
        }
        return nil
    }

    func successHighlightPath(){
        print("count is \(pathLines.count)")
        _ = Double(pathLines.count)
        let sequence = SKAction.sequence(
            [//SKAction.wait(forDuration: 1.0),
             SKAction.run({
                for (i,path) in self.pathLines.enumerated(){
                    if i == 0 || i == self.pathLines.count-1{
                        path.lineCap = .butt
                    }
                    path.strokeColor = YELLOW
                    path.lineWidth = path.lineWidth + 1
                    path.glowWidth = 1
                }
             }),
             SKAction.wait(forDuration: 1.3)
            ])
        pathLines[0].run(sequence){
            self.endGame(success: true)
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
        crack.zPosition = (lastTouchedTile?.tile.zPosition)! + 4 //hack! need to fix this. Caused by adding to the tile's z value repeatedly
        crack.zRotation = gridNode.zRotation
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
        for coord in Level!.solutionCoords.reversed(){
            let tile = tile2DArray[coord.y][coord.x]
            switch tile.state {
            case .touched:
                let center = tile.scene?.convert(tile.position, from: tile.parent!)
                crackAnimation(point: center!)
            default:
                break
            }
        }
    }
    
    
/*----------------------------------------------------------*/
/*------------------------- Arrows -------------------------*/
    func drawArrows(firstTile: GridTile){
        startArrow.scale(to: CGSize(width: blocksize, height: blocksize))
        endArrow.scale(to: CGSize(width: blocksize, height: blocksize))
        let endTile = self.tile2DArray[(Level!.solutionCoords.last?.y)!][(Level!.solutionCoords.last?.x)!]
        placeArrow(tile: firstTile, arrow: startArrow, orient: -1)
        placeArrow(tile: endTile, arrow: endArrow, orient: 1)
        startArrowSequence(tile: firstTile)
    }
    
    func startArrowSequence(tile: GridTile){
        var vector = CGVector()
        if tile.gridCoord.x == 0 || tile.gridCoord.x == tile2DArray[0].count - 1{
            vector = CGVector(dx: -blocksize/5.0,dy: 0)
        }
        else{
            vector = CGVector(dx: 0, dy: -blocksize/5.0)
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
        if let a = arrow.parent{
            //do nothing
        }
        else{
            gridNode.addChild(arrow)
        }
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
