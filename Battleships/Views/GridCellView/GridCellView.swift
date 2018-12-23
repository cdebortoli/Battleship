//
//  GridCellView.swift
//  Battleships
//
//  Created by cdebortoli on 23/12/2018.
//  Copyright © 2018 CDB. All rights reserved.
//

import UIKit

class GridCellView: UIView {

    var x: Int = -1
    var y: Int = -1
    var currentType: GridCellType = .blank
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        setup()
        
    }
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        setup()
        
    }
    
    convenience init(cell: GridCell) {
        
        self.init(frame: CGRect.zero)
        x = cell.x
        y = cell.y
        currentType = cell.currentType
    }
    
    func setup() {
        
        setupAppearance()
        
    }
    
    func setupAppearance() {
        
        layer.borderWidth = 1.0
        backgroundColor = .blue
        
    }
}
