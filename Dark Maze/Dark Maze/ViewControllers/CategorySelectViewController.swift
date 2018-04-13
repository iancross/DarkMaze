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
    
    
    let levelGroups = LevelsData.shared.levelGroups
    let defaultHeight = 45 as CGFloat
    
    //set when we initially click a row. reinit when that row is finally closed
    var selectedRowIndex: IndexPath? = nil

    //MARK: Variables
    
    //MARK: Outlets
    @IBOutlet weak var customTableView: UITableView!
    
    override func viewDidLoad() {
        self.customTableView.rowHeight = defaultHeight;
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        //presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
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
            return 130
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
            
            cell.initCellData(category: cellCategory, progress: "\(progress)/\(outOfTotal)", path: indexPath, origHeight: defaultHeight)
            
            if indexPath == selectedRowIndex{
                cell.initExpandedView()
                cell.expanded = true
            }
            else{
                cell.initNormalView()
                cell.expanded = false
            }
            
            //should we animate it? only if it isn't the selected one
            cell.animateCell()
        }
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
        cell?.reverseState()
        selectedRowIndex = nil
        customTableView.beginUpdates()
        customTableView.endUpdates()
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



/*    private func addTopBorderLine(){
let px = 1 / UIScreen.main.scale
let headerFrame = CGRect(x: 0, y: 0, width: self.customTableView.frame.size.width, height: px)
let line = UIView(frame: headerFrame)
self.customTableView.tableHeaderView = line
line.backgroundColor = self.customTableView.separatorColor
}
*/
