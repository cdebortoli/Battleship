//
//  GridCell.swift
//  Battleships
//
//  Created by cdebortoli on 23/12/2018.
//  Copyright © 2018 CDB. All rights reserved.
//

import Foundation

struct GridCell {
    var x: Int
    var y: Int
    var type: GridCellType
    var currentType: GridCellType
    
    init(x: Int, y: Int, type: GridCellType = .blank, currentType: GridCellType = .blank) {
       
        self.x = x
        self.y = y
        self.type = type
        self.currentType = currentType
        
    }
}
