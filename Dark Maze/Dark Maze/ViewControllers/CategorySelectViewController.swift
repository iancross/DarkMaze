//
//  CategorySelectViewController.swift
//  Dark Maze
//
//  Created by Ian Cross on 4/3/18.
//  Copyright © 2018 crossibc. All rights reserved.
//

import UIKit
import SpriteKit
class CategorySelectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CellDelegate {
    
    
    var testReceivedVar: Double?
    let levelGroups = LevelsData.shared.levelGroups
    let defaultHeight = 45 as CGFloat
    
    //set when we initially click a row. reinit when that row is finally closed
    var selectedRowIndex: IndexPath? = nil
    
    var indexToNotAnimate: IndexPath? = nil

    //MARK: Variables
    
    //MARK: Outlets
    @IBOutlet weak var customTableView: UITableView!
    
    override func viewDidLoad() {
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
        if indexPath.row == selectedRowIndex?.row {
            return 130
        }
        return defaultHeight
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //print((customTableView.cellForRow(at: indexPath) as? CustomTableViewCell)?.button!)
        //(customTableView.cellForRow(at: indexPath) as? CustomTableViewCell)?.clean()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return levelGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! CustomTableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? CustomTableViewCell{
            print("willdisplay \(indexPath.row)")

            cell.cellDelegate = self
            let cellCategory = levelGroups[indexPath.row].category
            let progress = LevelsData.shared.getCategoryProgress(groupIndex: indexPath.row)
            let outOfTotal = LevelsData.shared.levelGroups[indexPath.row].levels.count
            cell.initCellData(category: cellCategory, progress: "\(progress)/\(outOfTotal)", path: indexPath, origHeight: defaultHeight)
            cell.initView()
            
            //should we animate it? only if it isn't the selected one
            if indexPath.row != indexToNotAnimate?.row{
                cell.animateCell()
            }
        }
    }

    //if the indexpath isn't the selected row, close the current row
    //and expand the new row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? CustomTableViewCell
        if selectedRowIndex?.row != indexPath.row {
            if selectedRowIndex != nil && indexToNotAnimate != nil{
                closeFrame(indexPath: selectedRowIndex!)
            }
            selectedRowIndex = indexPath
            indexToNotAnimate = indexPath
            tableView.beginUpdates()
            tableView.endUpdates()
            
            cell?.reverseState()
            cell?.initView()
        }
    }
    
    func closeFrame(indexPath: IndexPath) {
        print("about to close frame")
        let cell = customTableView.cellForRow(at: indexPath) as? CustomTableViewCell
        cell?.revertToOrigState()
        cell?.reverseState()
        cell?.initView()
        
        selectedRowIndex = nil
        customTableView.beginUpdates()
        customTableView.endUpdates()
        indexToNotAnimate = nil
    }
    
    //MARK Protocol ----------------------------------------------------

    private func switchToGame(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let ivc = storyboard.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
        ivc.sceneString = "Level1Scene"
        
        UIView.animate(withDuration: 0.7, animations: {self.view.alpha = 0}){
            (completed) in
            ivc.modalTransitionStyle = .crossDissolve
            self.present(ivc, animated: false, completion: nil)
        }
    }
}



/*    private func addTopBorderLine(){
let px = 1 / UIScreen.main.scale
let headerFrame = CGRect(x: 0, y: 0, width: self.customTableView.frame.size.width, height: px)
let line = UIView(frame: headerFrame)
self.customTableView.tableHeaderView = line
line.backgroundColor = self.customTableView.separatorColor
}
*/
