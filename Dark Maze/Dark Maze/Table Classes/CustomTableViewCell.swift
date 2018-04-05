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

    @IBOutlet weak var drawing: SKView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func initializeView(){
        let scene = SKScene(size: drawing.frame.size)
        var Circle = SKShapeNode(circleOfRadius: 10 )
        Circle.fillColor = SKColor.orange
        scene.addChild(Circle)
        scene.backgroundColor = UIColor.black
        drawing.presentScene(scene)
    }

    
}
