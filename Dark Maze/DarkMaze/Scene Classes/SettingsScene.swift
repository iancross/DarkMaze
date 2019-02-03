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
    var backButton = SKSpriteNode()
    override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = UIColor.black
        anchorPoint = CGPoint(x: 0, y:0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        createHeader()
        createBackButton()
        createTextNextToButton(description: "Sounds", buttonText: "On")
    }
    
    private func createHeader(){
        header = SKLabelNode(text: "Settings")
        header.position = CGPoint(x: screenWidth/2.0, y: screenHeight*0.85)
        header.fontName = GameStyle.shared.mainFontString
        header.fontSize = screenWidth*0.12
        self.addChild(header)
    }
    
    private func createBackButton(){
        backButton = SKSpriteNode(imageNamed: "backButton")
        backButton.position = CGPoint(x: screenWidth*0.1, y: screenHeight*0.92)
        backButton.name = "BackButton"
        backButton.scale(to: CGSize(width: 28, height: 28))
        addChild(backButton)
    }
    
    private func createTextNextToButton(description: String, buttonText: String){
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches{
            let positionInScene = t.location(in: self)
            let touchedNode = self.atPoint(positionInScene)
            
            if let name = touchedNode.name{
                if name == "BackButton"{
                    (self.delegate as? GameDelegate)?.mainMenu()
                }
            }
        }
    }
}
