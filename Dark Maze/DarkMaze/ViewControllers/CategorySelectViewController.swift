//
//  CategorySelectViewController.swift
//  Dark Maze
//
//  Created by Ian Cross on 4/3/18.
//  Copyright © 2018 crossibc. All rights reserved.
//

import UIKit
import SpriteKit

enum Scrolling {
    case up
    case down
    case none
}

class CategorySelectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, CellDelegate {
    
    let levelGroups = LevelsData.shared.levelGroups
    let defaultHeight = 45 as CGFloat
    var scrollDirection: Scrolling = .none
    var lastContentOffset: CGPoint = CGPoint()
    
    //set when we initially click a row. reinit when that row is finally closed
    var selectedRowIndex: IndexPath? = nil

    //MARK: Variables
    
    //MARK: Outlets
    @IBOutlet weak var customTableView: UITableView!
    
    override func viewDidLoad() {
        
        customTableView.decelerationRate = UIScrollViewDecelerationRateNormal
        let i = IndexPath(item:12, section: 0)
        lastContentOffset = CGPoint.zero

        //customTableView.scrollToRow(at: i, at: .middle, animated: false)
        self.customTableView.rowHeight = defaultHeight;
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedRowIndex == indexPath{
            let count = Double(levelGroups[indexPath.row].levels.count)
            let lines = ceil(count/Double(GameStyle.shared.numLevelsOnLine))
            
            return CGFloat(Double(defaultHeight) + lines * 55.0)
        }
        return defaultHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return levelGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! CustomTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomTableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? CustomTableViewCell{
            cell.cellDelegate = self
            let cellCategory = levelGroups[indexPath.row].category
            let progress = LevelsData.shared.getCategoryProgress(groupIndex: indexPath.row)
            let outOfTotal = LevelsData.shared.levelGroups[indexPath.row].levels.count
            
            cell.initCellData(category: cellCategory, progress: progress, outOfTotal: outOfTotal, path: indexPath, origHeight: defaultHeight)
            
            if indexPath == selectedRowIndex{
                cell.initExpandedView()
                cell.expanded = true
            }
            else{
                cell.initNormalView()
                cell.expanded = false
            }
            
            //should we animate it? only if it isn't the selected one
            //cell.animateCell()

            switch scrollDirection{
            default:
                print ("no scrolling")
                cell.alpha = 0.0
                UIView.animate(withDuration: 1.0, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                    cell.alpha = 1.0
                },
                completion: nil)
                
//            case .none:
//                print ("no scrolling")
//                cell.alpha = 0.0
//                UIView.animate(withDuration: 2.0, animations: {
//                    cell.alpha = 1.0
//                })
//            case .down:
//                print ("scrolling down")
//                cell.transform = CGAffineTransform(translationX: -cell.frame.maxX/2.0, y: 0)
//                cell.layer.shadowColor = UIColor.black.cgColor
//                cell.layer.shadowOffset = CGSize(width: 10, height: 10)
//                cell.alpha = 0
//
//                UIView.beginAnimations("rotation", context: nil)
//                UIView.setAnimationDuration(0.5)
//                cell.transform = CGAffineTransform(translationX: 0, y: 0)
//                cell.alpha = 1
//                cell.layer.shadowOffset = CGSize(width: 0, height: 0)
//                UIView.commitAnimations()
//
//            case .up:
//                print ("scrolling up")
//                cell.transform = CGAffineTransform(translationX: cell.frame.maxX/2.0, y: 0)
//                cell.layer.shadowColor = UIColor.black.cgColor
//                cell.layer.shadowOffset = CGSize(width: 10, height: 10)
//                cell.alpha = 0
//
//                UIView.beginAnimations("rotation", context: nil)
//                UIView.setAnimationDuration(0.5)
//                cell.transform = CGAffineTransform(translationX: 0, y: 0)
//                cell.alpha = 1
//                cell.layer.shadowOffset = CGSize(width: 0, height: 0)
//                UIView.commitAnimations()
            }
        }
    }
    
    // while scrolling this delegate is being called so you may now check which direction your scrollView is being scrolled to
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset
        if currentOffset.y < self.lastContentOffset.y {
            scrollDirection = .up
        } else {
            scrollDirection = .down
        }
        self.lastContentOffset = currentOffset
    }
    //if the indexpath isn't the selected row, close the current row
    //and expand the new row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? CustomTableViewCell
        
        //if selected row doesn't equal the current indexPath row
        if selectedRowIndex?.row != indexPath.row {
            
            //and as long as the index path isn't nil
            //close the previously selected row
            if selectedRowIndex != nil{
                closeFrame(indexPath: selectedRowIndex!)
            }
            
            selectedRowIndex = indexPath
            tableView.beginUpdates()
            tableView.endUpdates()
            
            cell?.reverseState()
        }
    }
    
    //MARK Protocol ----------------------------------------------------
    
    func closeFrame(indexPath: IndexPath) {
        let cell = customTableView.cellForRow(at: indexPath) as? CustomTableViewCell
        selectedRowIndex = nil
        customTableView.beginUpdates()
        customTableView.endUpdates()
        cell?.reverseState()
    }
    
    func switchToGame(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let ivc = storyboard.instantiateViewController(withIdentifier: "GameViewController") as? GameViewController
        ivc?.sceneString = "Level1Scene"
        let appDelegate: AppDelegate = (UIApplication.shared.delegate as? AppDelegate)!
        
        UIView.animate(withDuration: 0.7, animations: {self.view.alpha = 0}){
            (completed) in
            appDelegate.window?.set(rootViewController: ivc!)
            ivc?.playGame()
        }
    }
}
