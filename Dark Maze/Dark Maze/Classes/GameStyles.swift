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
    
    var mainFontString = "My Scars"
    var SmallTextBoxFontSize: CGFloat = 40
    var SubHeaderFontSize: CGFloat = 75
    var TextBoxFontSize: CGFloat = 90
    var LargeTextBoxFontSize: CGFloat = 120
    let sceneTransition = SKTransition.fade(with: UIColor.black, duration: 0.8)

    private init() {
        
    }
}
