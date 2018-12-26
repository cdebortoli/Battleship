//
//  GridCountView.swift
//  Battleships
//
//  Created by cdebortoli on 26/12/2018.
//  Copyright © 2018 CDB. All rights reserved.
//

import UIKit

class GridCountView: UIView {
    
    var position: Int = -1
    var label: UILabel
    
    override init(frame: CGRect) {
        
        label = UILabel()
        super.init(frame: frame)
        addSubview(label)
        setup()
        
    }
    required init?(coder aDecoder: NSCoder) {
        
        label = UILabel()
        super.init(coder: aDecoder)
        addSubview(label)
        setup()
        
    }
    
    convenience init(position: Int) {
        
        self.init(frame: CGRect.zero)
        self.position = position
        
    }
    
    func setup() {
        
        setupAppearance()
        
    }
    
    func setupAppearance() {
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        layer.borderWidth = 1.0
        backgroundColor = .red
        
    }
}
