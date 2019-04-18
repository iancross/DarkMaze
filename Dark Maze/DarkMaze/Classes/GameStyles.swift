//
//  GameStyles.swift
//  Dark Maze
//
//  Created by crossibc on 1/21/18.
//  Copyright © 2018 crossibc. All rights reserved.
//

import Foundation
import SpriteKit

class GameStyle {
    static let shared = GameStyle()
    
    let defaultHeight = 1334
    let defaultSceneSize: CGSize = CGSize(width: screenWidth, height: screenHeight)
    let sceneSizeWithAd: CGSize = CGSize(width: screenWidth, height: screenHeight - 50)
//    let defaultSceneSize: CGSize = CGSize(width: 750, height: 1334)
//    let sceneSizeWithAd: CGSize = CGSize(width: 750, height: 1334 - 100)
    var mainFontString = "My Scars"
    var SmallTextBoxFontSize: CGFloat = 40
    var SubHeaderFontSize: CGFloat = 75
    var TextBoxFontSize: CGFloat = 90
    var LargeTextBoxFontSize: CGFloat = 130
    let sceneTransition = SKTransition.fade(with: UIColor.black, duration: 0.5)
    let numLevelsOnLine = 4
    let adMobLevelSelectToken = "ca-app-pub-1344161040949299/2897745758"
    let adMobEndGameToken = "ca-app-pub-1344161040949299/3430252314"

    private init() {
        sceneTransition.pausesOutgoingScene = true
    }
}
