//
//  GameDelegate.swift
//  Dark Maze
//
//  Created by crossibc on 4/1/18.
//  Copyright © 2018 crossibc. All rights reserved.
//

/*Use (self.delegate as? GameDelegate)?.gameOver()
 to call a function in the delegate. The load scene function
 in Helper handles the delegate handoff.
 */


import SpriteKit
import Foundation

protocol GameDelegate: SKSceneDelegate {
    func gameOver(unlockedLevel: Bool)
    func levelSelect()
    func playGame()
    func mainMenu()
}

