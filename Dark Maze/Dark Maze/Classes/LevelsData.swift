//
//  Level1LevelsData.swift
//  Dark Maze
//
//  Created by crossibc on 12/24/17.
//  Copyright © 2017 crossibc. All rights reserved.
//

import Foundation

class LevelsData{
    var levels: [LevelData]
    init(){
        levels = [LevelData]()
        
        //level 1
        levels.append (LevelData(
            gridSizeX: 5,
            gridSizeY: 5,
            blockBuffer: 3,
            solutionCoords:
                [(0,0),(0,1),(0,2)]
        ))
    }
}
struct LevelData {
    var gridSizeX: Int
    var gridSizeY: Int
    var blockBuffer: Int
    var solutionCoords: [(x: Int,y: Int)]
}

