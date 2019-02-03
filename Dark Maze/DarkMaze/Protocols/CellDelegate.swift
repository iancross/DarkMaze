//
//  CellDelegate.swift
//  Dark Maze
//
//  Created by crossibc on 4/6/18.
//  Copyright © 2018 crossibc. All rights reserved.
//

import SpriteKit
import Foundation

protocol CellDelegate {
    func closeFrame(indexPath: IndexPath)
    func switchToGame(sceneString: String)
}

