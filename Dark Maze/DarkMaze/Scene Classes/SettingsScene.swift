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
    var fontSize = screenWidth * 0.08
    let buffer = screenWidth * 0.1
    var settingsButton: TextBoxButton?
    var longerSettingButton: TextBoxButton?
    var resetButton: TextBoxButton?
    
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
        settingsButton = createTextNextToButton(description: "Sounds", buttonText: "ON", height: 0.75 * screenHeight)
        longerSettingButton = createTextNextToButton(description: "Longer Setting", buttonText: "ON", height: 0.65 * screenHeight)
        addResetButton(description: "Reset Game", height: 0.55 * screenHeight)
    }
    
    private func createHeader(){
        header = SKLabelNode(text: "Settings")
        header.position = CGPoint(x: screenWidth/2.0, y: screenHeight*0.85)
        header.fontName = GameStyle.shared.mainFontString
        header.fontSize = screenWidth*0.128
        self.addChild(header)
    }
    
    private func createBackButton(){
        backButton = SKSpriteNode(imageNamed: "backButton")
        backButton.position = CGPoint(x: screenWidth*0.1, y: screenHeight*0.92)
        backButton.name = "BackButton"
        backButton.scale(to: CGSize(width: 28, height: 28))
        addChild(backButton)
    }
    
    private func createTextNextToButton(description: String, buttonText: String, height: CGFloat) -> TextBoxButton{
        let s = SKLabelNode()
        let label = Helper.createGenericLabel(description, fontsize: fontSize)
        label.position = CGPoint(x: screenWidth * 0.6, y: height)
        label.horizontalAlignmentMode = .right
        let button = TextBoxButton(x: 0, y: 0, text: buttonText, fontsize: fontSize, buffers: buffers)
        button.position = CGPoint(x: screenWidth * 0.6 + buffer + button.frame.width/2, y: height)
        button.name = description
        print ("\(button.name)")
        self.addChild(label)
        self.addChild(button)
        return button
    }
    override func touchesBegan (_ touches: Set<UITouch>, with event: UIEvent?) {
        if let t = touches.first{
            let positionInScene = t.location(in: self)
            let touchedNode = self.atPoint(positionInScene)
            if let name = touchedNode.name{
                if name == "BackButton"{
                    touchedNode.alpha = 0.6
                }
            }
            else{
                if let s = settingsButton{
                    if s.within(point: t.location(in: self)){
                        s.tappedState()
                    }
                }
                if let r = resetButton{
                    if r.within(point: t.location(in: self)){
                        r.tappedState()
                    }
                }
                if let l = longerSettingButton{
                    if l.within(point: t.location(in: self)){
                        l.tappedState()
                    }
                }
                
            }
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let t = touches.first{
            let positionInScene = t.location(in: self)
            let touchedNode = self.atPoint(positionInScene)
            if let name = touchedNode.name{
                if name == "BackButton"{
                    touchedNode.alpha = 0.6
                }
            }
            else{
                touchedNode.alpha = 1.0
                if let s = settingsButton{
                    if s.within(point: t.location(in: self)){
                        s.tappedState()
                    }
                    else{
                        s.originalState()
                    }
                }
                if let r = resetButton{
                    if r.within(point: t.location(in: self)){
                        r.tappedState()
                    }
                    else{
                        r.originalState()
                    }
                }
                if let l = longerSettingButton{
                    if l.within(point: t.location(in: self)){
                        l.tappedState()
                    }
                    else{
                        l.originalState()
                    }
                }

            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let t = touches.first{
            let positionInScene = t.location(in: self)
            let touchedNode = self.atPoint(positionInScene)
            if let name = touchedNode.name{
                if name == "BackButton"{
                    (self.delegate as? GameDelegate)?.mainMenu()
                }
            }
            else{
                if let s = settingsButton{
                    if s.within(point: t.location(in: self)){
                        s.originalState()
                        flip(button: settingsButton)
                    }
                }
                if let r = resetButton{
                    if r.within(point: t.location(in: self)){
                        r.originalState()
                        LevelsData.shared.resetGame()
                    }
                }
                if let l = longerSettingButton{
                    if l.within(point: t.location(in: self)){
                        l.originalState()
                        flip(button: longerSettingButton)
                    }
                }
            }
        }
    }
    
    private func addResetButton(description: String, height: CGFloat){
            resetButton = TextBoxButton(x: screenWidth/2.0, y: height, text: description, fontsize: fontSize, buffers: buffers)
            self.addChild(resetButton!)
    }
    
    private func flip(button: TextBoxButton?){
        if let b = button{
            let text = b.text
            b.run(SKAction.sequence([
                SKAction.scaleX(to: 0, duration: 0.4),
                SKAction.run {
                    print("\(text)")
                    if text == "ON"{
                        print("turning off")
                        b.text = "OFF"
                    }
                    else if text == "OFF"{
                        print ("turning on")
                        b.text = "ON"
                    }
                },
                SKAction.scaleX(to: 1, duration: 0.4)
            ]))
        }
    }
}
