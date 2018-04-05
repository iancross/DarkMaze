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
    let boarderBuffer: CGFloat = 10.0

    var drawing: SKView?
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func initializeView(category: String){
        setupScene()
        addCategoryLabel(category: category)
     }
    
    private func setupScene(){
        drawing = SKView(frame: CGRect(origin: CGPoint(x:0,y:0), size: frame.size))
        self.addSubview(drawing!)
        let scene = SKScene(size: (drawing?.frame.size)!)
        scene.backgroundColor = UIColor.black
        drawing?.presentScene(scene)
    }
    
    private func addCategoryLabel(category: String){
        let label = Helper.createGenericLabel(category, fontsize: frame.width/15)
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .top
        if let scene = drawing?.scene{
            scene.addChild(label)
            label.position = CGPoint(x: boarderBuffer, y: scene.frame.maxY - boarderBuffer)
        }
    }
    public func customizeCell() {
        let cell = self
        cell.backgroundColor = UIColor.black
        
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
        cell.layer.shadowOffset = CGSize(width:0,height: 0)
        UIView.commitAnimations()
    }
}
