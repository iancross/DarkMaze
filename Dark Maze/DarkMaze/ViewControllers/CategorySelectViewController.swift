//
//  CategorySelectViewController.swift
//  Dark Maze
//
//  Created by Ian Cross on 4/3/18.
//  Copyright © 2018 crossibc. All rights reserved.
//

import UIKit
import SpriteKit
import GoogleMobileAds

enum Scrolling {
    case up
    case down
    case none
}

class CategorySelectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, CellDelegate {
    @IBOutlet weak var headerHeight: NSLayoutConstraint!
    @IBAction func backButtonTapped(_ sender: UIButton) {
        AudioController.shared.playButtonClick()
        switchToGame(sceneString: "MenuScene")
    }

    @IBOutlet weak var backButton: UIButton!
    var defaultHeight = 0 as CGFloat
    var scrollDirection: Scrolling = .none
    var lastContentOffset: CGPoint = CGPoint()
    var cellSizeBuffer: CGFloat = 0
    var bannerView = GADBannerView()
    var tableDidLoad = false
    
    //set when we initially click a row. reinit when that row is finally closed
    var selectedRowIndex: IndexPath? = nil

    //MARK: Variables
    
    //MARK: Outlets
    @IBOutlet weak var customTableView: UITableView!
    
    override func viewDidLoad() {
        defaultHeight = screenHeight / 11
        cellSizeBuffer = screenHeight / 19

        customTableView.decelerationRate = UIScrollView.DecelerationRate.normal
        lastContentOffset = CGPoint.zero
        addBannerViewToView()
        customTableView.decelerationRate = UIScrollView.DecelerationRate.fast
        
        self.customTableView.rowHeight = defaultHeight;
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        view.addConstraint(NSLayoutConstraint(item: customTableView,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: bannerView,
                                              attribute: .top,
                                              multiplier: 1,
                                              constant: 0))
        let originalSelectedIndexPath = IndexPath(row: LevelsData.shared.selectedLevel.page, section: 0)
        selectedRowIndex = originalSelectedIndexPath
        
        customTableView.selectRow(at: selectedRowIndex, animated: true, scrollPosition: .none)
        
        customTableView.reloadData()
        DispatchQueue.main.async {
            self.customTableView.scrollToRow(at: IndexPath(row: self.getTopLevelToScrollTo(), section: 0), at: .top, animated: true)
        }
    }
    
    func getTopLevelToScrollTo()->Int{
//        if let index = selectedRowIndex{
//            if index.row > 0{
//                return index.row - 1
//            }
//        }
//        return 0
        if LevelsData.shared.selectedLevel.page > 0{
            
            return LevelsData.shared.selectedLevel.page - 1
        }
        return 0
        
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
            let count = Double(LevelsData.shared.getNumLevelsOnPage(page: indexPath.row))
            let lines = ceil(count/Double(GameStyle.shared.numLevelsOnLine))
            
            return CGFloat(Double(defaultHeight) + lines * 55.0)
        }
        return defaultHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LevelsData.shared.getNumPages()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! CustomTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomTableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? CustomTableViewCell{
            cell.cellDelegate = self
            let cellCategory = LevelsData.shared.getPageCategory(page: indexPath.row)
            let progress = LevelsData.shared.nextLevelToCompleteOnPage(page: indexPath.row)
            let outOfTotal = LevelsData.shared.getNumLevelsOnPage(page: indexPath.row)
            
            cell.initCellData(category: cellCategory, progress: progress ?? outOfTotal, outOfTotal: outOfTotal, path: indexPath, origHeight: defaultHeight)
            if isPathUnlocked(path: indexPath){
//                if LevelsData.shared.selectedLevel.page == indexPath.row && !tableDidLoad{
//                    cell.initExpandedView()
//                    cell.expanded = true
//                    tableDidLoad = true
//                }
                if indexPath == selectedRowIndex{
                    cell.initExpandedView()
                    cell.expanded = true
                }
                else{
                    cell.initNormalView()
                    cell.expanded = false
                }
            }
            else{
                //cell.backgroundColor = UIColor.orange
                cell.initLockedView()
            }


            switch scrollDirection{
            default:
                cell.alpha = 0.0
                UIView.animate(withDuration: 0.7, delay: 0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
                    cell.alpha = 1.0
                },
                completion: nil)
            }
        }
    }
    
    func isPathUnlocked(path: IndexPath)->Bool{
        return LevelsData.shared.isPageUnlocked(page: path.row)
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
        if selectedRowIndex?.row != indexPath.row && isPathUnlocked(path: indexPath){
            //and as long as the index path isn't nil
            //close the previously selected row
            if selectedRowIndex != nil{
                closeFrame(indexPath: selectedRowIndex!)
            }
            
            selectedRowIndex = indexPath
            tableView.beginUpdates()
            tableView.endUpdates()
            
            tableView.scrollToRow(at: indexPath, at: .none, animated: true)

            cell?.reverseState()
        
            AudioController.shared.levelOpenClose()
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
    
    func switchToGame(sceneString: String){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let ivc = storyboard.instantiateViewController(withIdentifier: "GameViewController") as? GameViewController
        ivc?.sceneString = sceneString
        let appDelegate: AppDelegate = (UIApplication.shared.delegate as? AppDelegate)!
        
        UIView.animate(withDuration: 0.5, animations: {self.view.alpha = 0}){
            (completed) in
            appDelegate.window?.set(rootViewController: ivc!)
            if sceneString == "Level1Scene"{
                ivc?.playGame()
            }
            else{
                ivc?.mainMenu()
            }
        }
    }
    
    private func addBannerViewToView() {
        bannerView = GADBannerView(adSize: kGADAdSizeFullBanner)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        bannerView.rootViewController = self
        bannerView.backgroundColor = .black
        bannerView.adUnitID = GameStyle.shared.adMobLevelSelectToken
//        bannerView.translatesAutoresizingMaskIntoConstraints = false
//        let horizontalConstraint = bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
//        let verticalConstraint = bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
//        let widthConstraint = bannerView.widthAnchor.constraint(equalToConstant: 100)
//        let heightConstraint = newView.heightAnchor.constraint(equalToConstant: 100)
//
        
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: 0))
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: 0))
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: view.safeAreaLayoutGuide,
                                              attribute: .bottom,
                                              multiplier: 1,
                                              constant: 0))
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: NSLayoutConstraint.Attribute.height,
                                              relatedBy: NSLayoutConstraint.Relation.equal,
                                              toItem: nil,
                                              attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                              multiplier: 1,
                                              constant: bannerView.frame.height))
        let request = GADRequest()
        //request.testDevices = [kGADSimulatorID]
        bannerView.load(request)
    }
}
