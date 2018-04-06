//
//  CategorySelectViewController.swift
//  Dark Maze
//
//  Created by Ian Cross on 4/3/18.
//  Copyright © 2018 crossibc. All rights reserved.
//

import UIKit
import SpriteKit
class CategorySelectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    var testReceivedVar: Double?
    let levelGroups = LevelsData.shared.levelGroups
    let defaultHeight = 50.0 as CGFloat
    var selectedRowIndex: Int = -1
    var indexToNotAnimate = -1

    //MARK: Variables
    
    //MARK: Outlets
    @IBOutlet weak var customTableView: UITableView!
    
    
    override func viewDidLoad() {
        self.customTableView.rowHeight = defaultHeight;
        addTopBorderLine()
        super.viewDidLoad()
    }
    private func addTopBorderLine(){
        let px = 1 / UIScreen.main.scale
        let headerFrame = CGRect(x: 0, y: 0, width: self.customTableView.frame.size.width, height: px)
        let line = UIView(frame: headerFrame)
        self.customTableView.tableHeaderView = line
        line.backgroundColor = self.customTableView.separatorColor
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print(indexPath.row)
        (cell as! CustomTableViewCell).willAnimate = true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == selectedRowIndex {
            return 140
        }
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return levelGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! CustomTableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //tableView.beginUpdates()
        if let cell = cell as? CustomTableViewCell{
            let cellCategory = levelGroups[indexPath.row].category
            cell.initializeView(category: cellCategory)
            if indexPath.row != indexToNotAnimate{
                cell.customizeCell()
            }
            else{
                indexToNotAnimate = -1
            }
        }
    }
    
//    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
//        print("deselected")
//        //indexToNotAnimate = -1
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedRowIndex == indexPath.row {
            selectedRowIndex = -1
            tableView.cellForRow(at: indexPath)?.isSelected = false
        } else {
            selectedRowIndex = indexPath.row
            tableView.cellForRow(at: indexPath)?.isSelected = true
        }
        indexToNotAnimate = indexPath.row
        tableView.reloadRows(at: [indexPath], with: .none)
        (tableView.cellForRow(at: indexPath) as! CustomTableViewCell).willAnimate = false
    }
    
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
