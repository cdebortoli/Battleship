//
//  GridView.swift
//  Battleships
//
//  Created by cdebortoli on 23/12/2018.
//  Copyright © 2018 CDB. All rights reserved.
//

// TODO : Content view for the Grid
// Top and left view for the counters
import UIKit
import RxSwift
import RxCocoa


class GridView: UIView {
    
    var viewModel = GridViewModel()
    var cellViews = [String: GridCellView]()
    fileprivate var disposeBag = DisposeBag()

    override init(frame: CGRect) {
        
        super.init(frame: frame)
        setup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        setup()
        
    }
    
    func setup() {
        
        setupLayout()
        viewModel.setup()
        
    }
    
    func setupLayout() {
        
        let updateGridTrigger = viewModel
            .cellsOutput
            .withLatestFrom(viewModel.configurationOutput, resultSelector: { (configuration: $1, cells: $0) })
            .share(replay: 1)
        
        // TODO : if cellviews.count != subviews.count == replace all by cellviews
        // TODO : if cellViews.count == suviews.count == Refresh only updated cellviews

        updateGridTrigger
            .filter { [weak self] (configuration, _) in
                self?.subviews.count != (configuration.size * configuration.size)
            }
            .subscribe(onNext: { [weak self] (configuration, cells) in
                guard let strongSelf = self else { return }
                
                // Clean
                self?.subviews.forEach({ subview in
                    subview.removeFromSuperview()
                })
                
                // Init
                cells
                    .forEach({ cell in
                        let cellView = GridCellView(cell: cell)
                        cellView.translatesAutoresizingMaskIntoConstraints = false
                        
                        self?.addSubview(cellView)
                        self?.setConstraints(cellView: cellView, cellViews: strongSelf.cellViews, configuration: configuration)
                        if let id = cellView.id {
                            self?.cellViews[id] = cellView
                        }
                    })
                
            })
            .disposed(by: disposeBag)
        
    }
    
}

extension GridView {
    
    func setConstraints(cellView: GridCellView, cellViews: [String: GridCellView], configuration: GridConfiguration) {
        
        if let firstCell = cellViews[GridCellView.idFirstCell()] {
            cellView.heightAnchor.constraint(equalTo: firstCell.heightAnchor).isActive = true
            cellView.widthAnchor.constraint(equalTo: firstCell.widthAnchor).isActive = true
        }
        
        if cellView.y == 0 {
            cellView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        } else if cellView.y == configuration.size - 1 {
            if let previousYCell = GridView.previousVerCellView(from: cellView, in: cellViews) {
                cellView.topAnchor.constraint(equalTo: previousYCell.bottomAnchor).isActive = true
            }
            cellView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            if let previousYCell = GridView.previousVerCellView(from: cellView, in: cellViews) {
                cellView.topAnchor.constraint(equalTo: previousYCell.bottomAnchor).isActive = true
            }
        }
        
        if cellView.x == 0 {
            cellView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
        } else if cellView.x == configuration.size - 1 {
            if let previousXCell = GridView.previousHorCellView(from: cellView, in: cellViews) {
                cellView.leadingAnchor.constraint(equalTo: previousXCell.trailingAnchor).isActive = true
            }
            cellView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
        } else {
            if let previousXCell = GridView.previousHorCellView(from: cellView, in: cellViews) {
                cellView.leadingAnchor.constraint(equalTo: previousXCell.trailingAnchor).isActive = true
            }
        }
        
    }
    
    static func previousHorCellView(from cellView: GridCellView, in cellViews: [String: GridCellView]) -> GridCellView? {
        let id = GridCellView.id(x: cellView.x - 1, y: cellView.y)
        return cellViews[id]
    }
    
    static func previousVerCellView(from cellView: GridCellView, in cellViews: [String: GridCellView]) -> GridCellView? {
        let id = GridCellView.id(x: cellView.x, y: cellView.y - 1)
        return cellViews[id]
    }
}
