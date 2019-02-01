//
//  SettingsScene.swift
//  DarkMaze
//
//  Created by crossibc on 1/27/19.
//  Copyright © 2019 crossibc. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
class SettingsScene: SKScene {
    
    var header = SKLabelNode()
    override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = UIColor.black
        anchorPoint = CGPoint(x: 0, y:0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        header = SKLabelNode(text: "Settings")
        header.position = CGPoint(x: screenWidth/2.0, y: screenHeight*0.8)
        header.fontName = GameStyle.shared.mainFontString
        header.fontSize = screenWidth*0.12
        self.addChild(header)
        
        createTextNextToButton(description: "Sounds", buttonText: "On")
    }
    
    private func createTextNextToButton(description: String, buttonText: String){
        
    }
}
