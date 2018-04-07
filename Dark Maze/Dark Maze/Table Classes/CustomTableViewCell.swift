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

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state

    }
    
    func initializeView(category: String, progress: String, path: IndexPath, origHeight: CGFloat){
        defaultHeight = origHeight
        indexPath = path
        setupScene()
        addCategoryLabel(category: category, progress: progress)
    }
    func addButton(){
        print("button about to be called")
        button = UIButton(frame: CGRect(origin: CGPoint(x:0,y:0), size: frame.size))
        button?.backgroundColor = UIColor.clear
        button?.setTitle("", for: .normal)
        button?.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        button?.bringSubview(toFront: self)
        if let butt = button{
            print("adding button")
            self.addSubview(butt)
            addGradient()
        }
    }
    
    func addGradient(){
        //anchor is center for this gradient texture
        let topColor = CIColor(color: UIColor(red: 0.2196, green: 0.2196, blue: 0.2196, alpha: 1.0))
        let bottomColor = CIColor(color: UIColor.black)
        let texture = SKTexture(size: frame.size, color1: topColor, color2: bottomColor, direction: GradientDirection.up)
        texture.filteringMode = .nearest
        let sprite = SKSpriteNode(texture: texture)
        sprite.position = CGPoint(x: frame.midX ,y:0)
        sprite.size = (drawing?.frame.size)!
        drawing?.scene?.addChild(sprite)
    }
    
    func removeButton(){
        print("button being removed")
        button?.removeFromSuperview()
    }
    @objc func buttonAction(sender: AnyObject, event: UIEvent) {
        let buttonView = sender as! UIView;
        
        // get any touch on the buttonView
        if (event.touches(for: buttonView)?.first) != nil {
            // print the touch location on the button
            cellDelegate?.closeFrame(indexPath: indexPath)
        }
    }
    
    private func setupScene(){
        //drawing?.removeFromSuperview()
        //let size = CGSize(width: frame.width, height: frame.height - defaultHeight)
        drawing = SKView(frame: CGRect(origin: CGPoint(x:0,y:0), size: frame.size))
        self.addSubview(drawing!)
        let scene = SKScene(size: (drawing?.frame.size)!)
        scene.backgroundColor = UIColor.black
        drawing?.presentScene(scene)
    }
    
    private func addCategoryLabel(category: String, progress: String){
        let fontsize = frame.width/13
        let label = Helper.createGenericLabel(category, fontsize: fontsize)
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .top
        if let scene = drawing?.scene{
            scene.addChild(label)
            label.position = CGPoint(x: boarderBuffer, y: scene.frame.maxY - boarderBuffer)
        }
        let completion = Helper.createGenericLabel(progress, fontsize: fontsize)
        completion.horizontalAlignmentMode = .right
        completion.verticalAlignmentMode = .top
        if let scene = drawing?.scene{
            scene.addChild(completion)
            completion.position = CGPoint(x: scene.frame.width - boarderBuffer, y: scene.frame.maxY - boarderBuffer)
        }

    }
    
    func expand(){
    }
    
    public func customizeCell() {
        let cell = self
        
        var rotate: CATransform3D
        let value = CGFloat((90.0 * Double.pi) / 180.0)
        
        rotate = CATransform3DMakeRotation(value, 0.0, 0.7, 0.4)
        rotate.m34 = 1.0 / -600
        
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 10,height: 10)
        cell.alpha = 0
        cell.layer.transform = rotate
        cell.layer.anchorPoint = CGPoint(x: 0,y: 0.5)
        
        if(cell.layer.position.x != 0){
            cell.layer.position = CGPoint(x: 0,y: cell.layer.position.y);
        }
        
        UIView.beginAnimations("rotate", context: nil)
        UIView.setAnimationDuration(0.8)
        cell.layer.transform = CATransform3DIdentity
        cell.alpha = 1
        cell.layer.shadowOffset =  CGSize(width:0,height: 0)
        UIView.commitAnimations()
    }
    
    
}
