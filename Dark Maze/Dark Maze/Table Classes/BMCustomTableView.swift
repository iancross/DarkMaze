//
//  BMCustomTableView.swift
//  Pods
//
//  Created by Barbara Brina on 10/22/15.
//
//

import QuartzCore
import UIKit

//protocol CustomTableViewDelegate{
//    func test()
//}
//
//var delegate: CustomTableViewDelegate?

public class BMCustomTableView : UITableView {
    
    public func customizeCell(cell: UITableViewCell) {
        
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
