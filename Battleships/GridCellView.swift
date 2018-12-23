//
//  GridCellView.swift
//  Battleships
//
//  Created by cdebortoli on 23/12/2018.
//  Copyright © 2018 CDB. All rights reserved.
//

import UIKit

class GridCellView: UIView {
    
    var cell: GridCell = GridCell(x: 0, y: 0)
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        setup()
        
    }
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        setup()
        
    }
    
    init(cell: GridCell) {
        
        self.cell = cell
        super.init(frame: CGRect.zero)
        
    }
    
    func setup() {
        
        setupAppearance()
        
    }
    
    func setupAppearance() {
        
        layer.borderWidth = 1.0
        backgroundColor = .blue
        
    }
}
