//
//  CategorySelectViewController.swift
//  Dark Maze
//
//  Created by Ian Cross on 4/3/18.
//  Copyright © 2018 crossibc. All rights reserved.
//

import UIKit
import SpriteKit
class CategorySelectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var testReceivedVar: Double?
    let levelGroups = LevelsData.shared.levelGroups
    let defaultHeight = 50.0 as CGFloat
    //MARK: Variables
    
    //MARK: Outlets
    @IBOutlet weak var customTableView: UITableView!
    
    
    override func viewDidLoad() {
        self.customTableView.rowHeight = defaultHeight;
        //addTopBorderLine()
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return levelGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! CustomTableViewCell
        cell.backgroundColor = UIColor.black
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? CustomTableViewCell{
            cell.customizeCell()
            let cellCategory = levelGroups[indexPath.row].category
            cell.initializeView(category: cellCategory)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Load the SKScene from 'GameScene.sks'
        self.performSegue(withIdentifier: "backToGame", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "backToGame") {
            let receiver = segue.destination as? GameViewController
            receiver?.sceneString = "Level1Scene"
        }
    }
}
