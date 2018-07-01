//
//  CustomTableViewCell.swift
//  BMCustomTableView
//
//  Created by Barbara Brina on 10/22/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import UIKit
import SpriteKit

protocol test{
    func test()
}
class CustomTableViewCell: UITableViewCell {
    let boarderBuffer: CGFloat = 15.0
    var willAnimate = true
    var drawing: SKView?
    var button: UIButton?
    var indexPath = IndexPath()
    var cellDelegate: CellDelegate?
    var defaultHeight: CGFloat = 0
    var verticalSpacing: CGFloat = 10
    var levels = [TextBoxButton]()
    var mainFontSize: CGFloat = 0
    var categoryString = String()
    var progressString = String()
    var progress: Int?
    var numLevels: Int?
    var expanded = false
    var accessibleElements: [UIAccessibilityElement] = []
    var levelBuffer = 5
    let progressLabelBuffer: CGFloat = 5
    let NonBonusLevels = 8

    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.black
        expanded = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        if selected {
        }
    }
    
    
    func initCellData(category: String, progress: Int, outOfTotal: Int, path: IndexPath, origHeight: CGFloat){
        accessibilityIdentifier = "Cell \(path.row)"
        categoryString = category
        progressString = "\(progress)/\(outOfTotal)"
        self.progress = progress
        numLevels = outOfTotal
        mainFontSize = frame.width/13
        defaultHeight = origHeight
        verticalSpacing = 45
        indexPath = path
    }
    
    func reverseState(){
        expanded = !expanded
        initView()
    }
    
    func initView(){
        if expanded{
            initExpandedView()
        }
        else{
            initNormalView()
        }
    }
    
    func initNormalView(){
        removeButton()
        clean()
        setupScene()
        drawProgressLine()
        addCategoryLabel(alpha: 1.0)
    }

    func initExpandedView(){
        clean()
        setupScene()
        addCategoryLabel(alpha: 1.0)
        addButton()
        addLevels()
    }
    
    func initLockedView(){
        setupScene()
        addCategoryLabel(alpha: 0.35)
        
        let center = CGPoint(x: (drawing?.frame.midX)!, y: (drawing?.frame.midY)!)
        let chain = SKSpriteNode(imageNamed: "ChainSprite1000")
        chain.alpha = 0.6

        chain.scale(to: CGSize(width: (drawing?.frame.size.width)!/2, height: (drawing?.frame.size.height)! / 4))
        chain.position = center
        let chain2 = chain.copy() as! SKSpriteNode
        chain.anchorPoint = CGPoint(x: Double.random(min: 0.42, max: 0.58) , y: 0.5)
        chain2.anchorPoint = CGPoint(x: Double.random(min: 0.42, max: 0.58) , y: 0.5)

        drawing?.scene?.addChild(chain)
        drawing?.scene?.addChild(chain2)
        let rot = CGFloat(Double.pi/Double.random(min: 10.0, max: 15.0))
        let negrot = -CGFloat(Double.pi/Double.random(min: 10.0, max: 15.0))
        chain.zRotation = rot
        chain2.zRotation = negrot
        
        let lock = SKSpriteNode(imageNamed: "lock_sprite200x200")
        lock.alpha = 0.8
        lock.position = center
        lock.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        lock.scale(to: CGSize(width: 22.0, height: 22.0))
        drawing?.scene?.addChild(lock)
    }
    
    private func addButton(){
        removeButton()
        button = UIButton(frame: CGRect(origin: CGPoint.zero, size: frame.size))
        button?.accessibilityIdentifier = "skview button"
        button?.backgroundColor = UIColor.clear
        button?.setTitle("", for: .normal)
        button?.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        button?.bringSubview(toFront: self)
        if let butt = button{
            self.addSubview(butt)
        }
    }
    
    private func addLevels(){
        let nextLevelToComplete = LevelsData.shared.nextLevelToCompleteOnPage(page: indexPath.row)
        let levelCount = LevelsData.shared.getNumLevelsOnPage(page: indexPath.row)
        let n = GameStyle.shared.numLevelsOnLine
        for i in 0...levelCount/n{
            
            let top = (drawing?.frame.maxY)! - defaultHeight + 7
            let lines = CGFloat(ceil(Double(levelCount)/Double(n)))
            let offset = (top / lines) - 1.0
            let y = top + (offset / 2.0) - (offset * CGFloat(i + 1)) + CGFloat(levelBuffer)
            
            for j in 0...n-1{
                let levelNumber = i * (n) + j
                if levelNumber <= levelCount - 1 {
                    var yPrime = y
                    if levelNumber == NonBonusLevels - 1{
                        let bonus = CategoryHeader(string: "Bonus Levels", fontSize: mainFontSize*4/5, frameWidth: (drawing?.scene?.frame.width)!)
                        bonus.position = CGPoint(x: frame.width/2.0, y: y - offset*4/6)
                        drawing?.scene?.addChild(bonus)
                    }
                    if levelNumber > NonBonusLevels - 1{
                        yPrime -= offset*1/4
                    }
                    let box = TextBoxButton(
                        x: (frame.width/(CGFloat(n) + 1) * CGFloat(j+1)),
                        y: yPrime,
                        text: String(99),
                        fontsize: mainFontSize,
                        buffers: (7.0,12.0))
                    drawing?.scene?.addChild(box)
                    box.isAccessibilityElement = true
                    box.updateText(String(levelNumber + 1))
                    if LevelsData.shared.hasLevelBeenCompleted(page: indexPath.row, levelToTest: levelNumber){
                        box.markAsCompletedLevel()
                    }
                    else if levelNumber == nextLevelToComplete{
                        //do nothing
                    }
                    else {
                        box.setAlpha(0.3)
                    }
                    levels.append(box)
                }
            }
        }
    }
    
    private func addGradient(){
        //anchor is center for this gradient texture
        let topColor = CIColor(color: UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0))
        let bottomColor = CIColor(color: UIColor.black)
        let texture = SKTexture(size: frame.size, color1: topColor, color2: bottomColor, direction: GradientDirection.up)
        texture.filteringMode = .nearest
        let sprite = SKSpriteNode(texture: texture)
        sprite.position = CGPoint(x: frame.midX ,y:0)
        sprite.size = (drawing?.frame.size)!
        sprite.zPosition = -1
        drawing?.scene?.addChild(sprite)
    }
    
    
    @objc func buttonAction(sender: AnyObject, event: UIEvent) {
        let buttonView = sender as! UIView;
        // get any touch on the buttonView
        if let touch = event.touches(for: buttonView)?.first{
            touchedLevel(point: touch.location(in: (drawing?.scene)!))
        }
    }
    
    private func touchedLevel(point: CGPoint){
        let nextLevelToComplete = LevelsData.shared.nextLevelToCompleteOnPage(page: indexPath.row)
        for button in levels{
            if button.within(point: point){
                if Int(button.text)!-1 > nextLevelToComplete{
                    let sequence = [SKAction.rotate(byAngle: 0.1, duration: 0.1),
                                    SKAction.rotate(byAngle: -0.2, duration: 0.1),
                                    SKAction.rotate(byAngle: 0.1, duration: 0.1)]
                    button.outline.run(SKAction.sequence(sequence))
                    return
                }
                else if Int(button.text)!-1 <= nextLevelToComplete{
                    let embiggen = SKAction.scale(to: 1.3, duration: 0.4)
                    let loadScene = SKAction.run({
                        LevelsData.shared.selectedLevel = (page: self.indexPath.row, level: Int(button.text)! - 1)
                    })
                    button.outline.run(SKAction.sequence([embiggen,loadScene])){ [weak self] in
                        self?.cellDelegate?.switchToGame()
                    }
                    return
                }
                else{
                }
            }
        }
        cellDelegate?.closeFrame(indexPath: indexPath)
    }
    
    private func setupScene(){
        drawing = SKView(frame: CGRect(origin: CGPoint.zero, size: frame.size))
        self.addSubview(drawing!)
        let scene = SKScene(size: (drawing?.frame.size)!)
        scene.backgroundColor = UIColor.black
        drawing?.presentScene(scene)
        drawing?.isAccessibilityElement = true
        drawing?.accessibilityIdentifier = "drawing"
        addGradient()
    }
    
    func drawProgressLine(){
        let yBuffer: CGFloat = 4
        let Circle = SKShapeNode(circleOfRadius: 3 ) // Size of Circle

        // Define start & end point for line
        let startPoint = CGPoint(x: (drawing?.frame.maxX)! * 3.0/4.0 - progressLabelBuffer, y: yBuffer)
        let fraction = CGFloat(Double(progress!)/Double(numLevels!))
        
        var circlePoint = CGPoint()
        if fraction == 0{
            circlePoint = CGPoint(x: startPoint.x + (drawing?.frame.maxX)! * 1.0/4.0 * fraction + progressLabelBuffer, y: yBuffer)
        }
        else if fraction == 1{
            circlePoint = CGPoint(x: startPoint.x + (drawing?.frame.maxX)! * 1.0/4.0 * fraction - progressLabelBuffer/2.0, y: yBuffer)
        }
        else{
            circlePoint = CGPoint(x: startPoint.x + (drawing?.frame.maxX)! * 1.0/4.0 * fraction, y: yBuffer)
        }
        let endPoint = CGPoint(x: (drawing?.frame.maxX)! - progressLabelBuffer, y: yBuffer)

        // Create line with SKShapeNode
        let line = SKShapeNode()
        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: circlePoint)
        line.path = path.cgPath
        line.strokeColor = UIColor.white
        line.lineWidth = 1
        line.glowWidth = 3
        drawing?.scene?.addChild(line)
        line.alpha = 0
        line.run(SKAction.fadeIn(withDuration: 0.3))

        let line2 = SKShapeNode()
        let path2 = UIBezierPath()
        path2.move(to: circlePoint)
        path2.addLine(to: endPoint)
        line2.path = path2.cgPath
        line2.strokeColor = UIColor.white
        line2.lineWidth = 1
        line2.alpha = 0.5
        drawing?.scene?.addChild(line2)
        line2.alpha = 0
        line2.run(SKAction.fadeIn(withDuration: 0.3))

        Circle.position = circlePoint
        Circle.fillColor = SKColor.white
        drawing?.scene?.addChild(Circle)
    }
    
    private func addCategoryLabel(alpha: CGFloat){
        let label = Helper.createGenericLabel(categoryString, fontsize: mainFontSize)
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .center
        if let scene = drawing?.scene{
            scene.addChild(label)
            label.alpha = alpha
            label.position = CGPoint(x: boarderBuffer, y: scene.frame.maxY - defaultHeight/2)
        }
        let completion = Helper.createGenericLabel(progressString, fontsize: mainFontSize)
        completion.horizontalAlignmentMode = .center
        completion.verticalAlignmentMode = .center
        if let scene = drawing?.scene{
            scene.addChild(completion)
            completion.alpha = alpha
            completion.position = CGPoint(x: scene.frame.width * 7.0/8.0, y: scene.frame.maxY - defaultHeight/2 - progressLabelBuffer)
        }
    }
    
    func clean(){
        accessibleElements.removeAll()
        self.removeLevels()
        self.removeButton()
        self.drawing?.scene?.removeAllChildren()
        self.drawing?.scene?.removeFromParent()
        self.drawing?.removeFromSuperview()
    }
    func removeLevels(){
        for i in levels{
            i.removeFromParent()
        }
        levels.removeAll()
    }
    
    private func removeButton(){
        button?.removeFromSuperview()
    }
    
    override func prepareForReuse() {
        clean()
        expanded = false
    }
    
    public func animateCell() {
        let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, -500, 0, 1)
        self.layer.transform = rotationTransform

        UIView.animate(withDuration: 1.0, animations: { [weak self] in
            self?.layer.transform = CATransform3DIdentity
        })
    }
    
//    public func animateCell() {
//        let cell = self
//
//        var rotate: CATransform3D
//        let value = CGFloat((90.0 * Double.pi) / 180.0)
//
//        rotate = CATransform3DMakeRotation(value, 0.0, 0.7, 0.4)
//        //rotate.m34 = 1.0 / -600
//
////        cell.layer.shadowColor = UIColor.black.cgColor
////        cell.layer.shadowOffset = CGSize(width: 10,height: 10)
//        cell.alpha = 0
//        cell.layer.transform = rotate
//        cell.layer.anchorPoint = CGPoint(x: 0,y: 0.5)
//
//        if(cell.layer.position.x != 0){
//            cell.layer.position = CGPoint(x: 0,y: cell.layer.position.y);
//        }
//
//        UIView.beginAnimations("rotate", context: nil)
//        UIView.setAnimationDuration(0.8)
//        cell.layer.transform = CATransform3DIdentity
//        cell.alpha = 1
//        cell.layer.shadowOffset =  CGSize(width:0,height: 0)
//        UIView.commitAnimations()
//    }
    
    override func accessibilityElementCount() -> Int {
        initAccessibility()
        return accessibleElements.count
    }
    
    override func accessibilityElement(at index: Int) -> Any? {
        
        initAccessibility()
        if (index < accessibleElements.count) {
            return accessibleElements[index]
        } else {
            return nil
        }
    }
    
    override func index(ofAccessibilityElement element: Any) -> Int {
        initAccessibility()
        return accessibleElements.index(of: element as! UIAccessibilityElement)!
    }
    
    func initAccessibility() {
        if accessibleElements.count == 0 {
            accessibleElements.append(UIAccessibilityElement(accessibilityContainer: drawing!))
            for (i,level) in levels.enumerated(){
                // 1.
                let elementForTapMe   = UIAccessibilityElement(accessibilityContainer: level)
                
                // 2.
                let frameForTapMe = level.frame
                
                // From Scene to View
                //frameForTapMe.origin = (drawing?.convert(frameForTapMe.origin, from: self))!
                
                // Don't forget origins are different for SpriteKit and UIKit:
                // - SpriteKit is bottom/left
                // - UIKit is top/left
                //              y
                //  ┌────┐       ▲
                //  │    │       │   x
                //  ◉────┘       └──▶
                //
                //                   x
                //  ◉────┐       ┌──▶
                //  │    │       │
                //  └────┘     y ▼
                //
                // Thus before the following conversion, origin value indicate the bottom/left edge of the frame.
                // We then need to move it to top/left by retrieving the height of the frame.
                //
                
                //frameForTapMe.origin.y = frameForTapMe.origin.y - frameForTapMe.size.height
                
                // 3.
                elementForTapMe.accessibilityLabel   = "Level \(i)"
                elementForTapMe.accessibilityFrame   = frameForTapMe
                elementForTapMe.accessibilityTraits  = UIAccessibilityTraitButton
                
                // 4.
                accessibleElements.append(elementForTapMe)
            }
        }
    }
}
