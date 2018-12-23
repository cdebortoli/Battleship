//
//  GridView.swift
//  Battleships
//
//  Created by cdebortoli on 23/12/2018.
//  Copyright © 2018 CDB. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

struct GridViewConfiguration {
    var size: Int
    var name: String
}

class GridView: UIView {
    
    var viewModel = GridViewModel()
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
                var cellViews = [GridCellView]()
                cells
                    .forEach({ cell in
                        let cellView = GridCellView()
                        cellView.cell = cell
                        cellView.translatesAutoresizingMaskIntoConstraints = false
                        
                        self?.addSubview(cellView)
                        self?.setConstraints(cellView: cellView, cellViews: cellViews, configuration: configuration)
                        cellViews.append(cellView)
                        
                    })
                
            })
            .disposed(by: disposeBag)
        
    }
    
    func setConstraints(cellView: GridCellView, cellViews: [GridCellView], configuration: GridViewConfiguration) {
        
        if let firstCell = cellViews.first {
            cellView.heightAnchor.constraint(equalTo: firstCell.heightAnchor).isActive = true
            cellView.widthAnchor.constraint(equalTo: firstCell.widthAnchor).isActive = true
        }
        
        if cellView.cell.y == 0 {
            // Constraint to top superview
            cellView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        } else if cellView.cell.y == configuration.size - 1 {
            // Constraint to cell view y - 1, same X
            if let previousYCell = cellViews.filter({ $0.cell.y == cellView.cell.y - 1 && $0.cell.x == cellView.cell.x }).first {
                cellView.topAnchor.constraint(equalTo: previousYCell.bottomAnchor).isActive = true
            }
            // constraint to bottom superview
            cellView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            // Constraint to cell view y - 1, same X
            if let previousYCell = cellViews.filter({ $0.cell.y == cellView.cell.y - 1 && $0.cell.x == cellView.cell.x }).first {
                cellView.topAnchor.constraint(equalTo: previousYCell.bottomAnchor).isActive = true
            }
        }
        if cellView.cell.x == 0 {
            // Constraint to leading
            cellView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
        } else if cellView.cell.x == configuration.size - 1 {
            // Constraint to cell view x -1, same Y
            if let previousXCell = cellViews.filter({ $0.cell.x == cellView.cell.x - 1 && $0.cell.y == cellView.cell.y }).first {
                cellView.leadingAnchor.constraint(equalTo: previousXCell.trailingAnchor).isActive = true
            }
            // constraint to trailing superview
            cellView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
            
        } else {
            // Constraint to cell view x -1, same Y
            if let previousXCell = cellViews.filter({ $0.cell.x == cellView.cell.x - 1 && $0.cell.y == cellView.cell.y }).first {
                cellView.leadingAnchor.constraint(equalTo: previousXCell.trailingAnchor).isActive = true
            }
        }
        
    }
}

class GridViewModel {
    
    var configurationOutput: Observable<GridViewConfiguration> { return configurationInput.asObservable() }
    var configurationInput = BehaviorRelay<GridViewConfiguration>(value: GridViewConfiguration(size: 6, name: "default"))
    
    var cellsOutput : Observable<[GridCell]> { return cellsInput.asObservable() }
    var cellsInput = PublishSubject<[GridCell]>()
    
    fileprivate var disposeBag = DisposeBag()
    
    func setup() {
        
        setupGridGeneration()
        
    }
    
    func setupGridGeneration() {
        
        configurationOutput
            .map { configuration -> [GridCell] in
                
                var newCells = [GridCell]()
                (0..<configuration.size).forEach { y in
                    (0..<configuration.size).forEach { x in
                        newCells.append(GridCell(x: x, y: y))
                    }
                }
                return newCells
                
            }
            .bind(to: cellsInput)
            .disposed(by: disposeBag)
        
    }
    
}
