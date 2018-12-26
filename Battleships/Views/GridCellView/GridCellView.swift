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
    var id: String?
    
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
        id = GridCellView.id(cell: cell)
        
    }
    
    func setup() {
        
        setupAppearance()
        
    }
    
    func setupAppearance() {
        
        layer.borderWidth = 1.0
        backgroundColor = .blue
        
    }
}

extension GridCellView {
    
    static func id(cell: GridCell) -> String {
        return GridCellView.id(x: cell.x, y: cell.y)
    }
    
    static func idFirstCell() -> String {
        return GridCellView.id(x: 0, y: 0)
    }
    
    static func id(x: Int, y: Int) -> String {
        return "\(x)_\(y)"
    }
    
}
