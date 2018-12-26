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
    
    static var countersBarSize: CGFloat = 44.0
    static var cellSize: CGSize = CGSize(width: 44.0, height: 44.0)
    
    var viewModel = GridViewModel()
    
    var contentView: UIView
    var leftCountersBarView: UIView
    var topCountersBarView: UIView
    
    fileprivate var cellViews = [String: GridCellView]()
    fileprivate var leftCounterViews = [Int: GridCountView]()
    fileprivate var topCounterViews = [Int: GridCountView]()
    
    fileprivate var disposeBag = DisposeBag()

    override init(frame: CGRect) {
        
        contentView = UIView()
        leftCountersBarView = UIView()
        topCountersBarView = UIView()
        
        super.init(frame: frame)
        setup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        contentView = UIView()
        leftCountersBarView = UIView()
        topCountersBarView = UIView()
        
        super.init(coder: aDecoder)
        setup()
        
    }
    
    func setup() {
        
        setupLayout()
        setupContentLayout()
        viewModel.setup()
        
    }
    
    func setupLayout() {
        
        addSubview(contentView)
        addSubview(topCountersBarView)
        addSubview(leftCountersBarView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        topCountersBarView.translatesAutoresizingMaskIntoConstraints = false
        leftCountersBarView.translatesAutoresizingMaskIntoConstraints = false
        
        topCountersBarView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        topCountersBarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        topCountersBarView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
        topCountersBarView.heightAnchor.constraint(equalToConstant: GridView.countersBarSize).isActive = true

        leftCountersBarView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        leftCountersBarView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
        leftCountersBarView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        leftCountersBarView.widthAnchor.constraint(equalToConstant: GridView.countersBarSize).isActive = true

        contentView.topAnchor.constraint(equalTo: topCountersBarView.bottomAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: leftCountersBarView.trailingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        
    }
    
    func setupContentLayout() {
        
        let updateGridTrigger = viewModel
            .cellsOutput
            .withLatestFrom(viewModel.configurationOutput, resultSelector: { (configuration: $1, cells: $0) })
            .share(replay: 1)
        
        // TODO : if cellviews.count != subviews.count == replace all by cellviews
        // TODO : if cellViews.count == suviews.count == Refresh only updated cellviews

        updateGridTrigger
            .filter { [weak self] (configuration, _) in
                self?.contentView.subviews.count != (configuration.size * configuration.size)
            }
            .subscribe(onNext: { [weak self] (configuration, cells) in
                
                guard let strongSelf = self else { return }
                
                // Clean
                self?.contentView.subviews.forEach({ subview in
                    subview.removeFromSuperview()
                })
                self?.topCountersBarView.subviews.forEach({ subview in
                    subview.removeFromSuperview()
                })
                self?.leftCountersBarView.subviews.forEach({ subview in
                    subview.removeFromSuperview()
                })
                
                // Counters bar
                (0..<configuration.size).forEach({ index in
                    
                    let leftCountView = GridCountView(position: index)
                    self?.leftCountersBarView.addSubview(leftCountView)
                    self?.setLeftCountersViewConstraints(counterView: leftCountView, counterViews: strongSelf.leftCounterViews, configuration: configuration)
                    self?.leftCounterViews[index] = leftCountView

                    let topCountView = GridCountView(position: index)
                    self?.topCountersBarView.addSubview(topCountView)
                    self?.setTopCountersViewConstraints(counterView: topCountView, counterViews: strongSelf.topCounterViews, configuration: configuration)
                    self?.topCounterViews[index] = topCountView

                })
                
                // Grid cells
                cells
                    .forEach({ cell in
                        let cellView = GridCellView(cell: cell)
                        self?.contentView.addSubview(cellView)
                        self?.setConstraints(cellView: cellView, cellViews: strongSelf.cellViews, configuration: configuration)
                        if let id = cellView.id {
                            self?.cellViews[id] = cellView
                        }
                    })
                
            })
            .disposed(by: disposeBag)
        
    }
    
}

// MARK: - Size
extension GridView {
    
    static func size(configuration: GridConfiguration) -> CGFloat {
        
        let gridSize = CGFloat(configuration.size) * GridView.cellSize.height
        return gridSize + countersBarSize
        
    }
}

// MARK: - Grid Content View constraints
extension GridView {
    
    func setConstraints(cellView: GridCellView, cellViews: [String: GridCellView], configuration: GridConfiguration) {
        
        cellView.translatesAutoresizingMaskIntoConstraints = false

        if let firstCell = cellViews[GridCellView.idFirstCell()] {
            cellView.heightAnchor.constraint(equalTo: firstCell.heightAnchor).isActive = true
            cellView.widthAnchor.constraint(equalTo: firstCell.widthAnchor).isActive = true
        }
        
        if cellView.y == 0 {
            cellView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        } else if cellView.y == configuration.size - 1 {
            if let previousYCell = GridView.previousVerCellView(from: cellView, in: cellViews) {
                cellView.topAnchor.constraint(equalTo: previousYCell.bottomAnchor).isActive = true
            }
            cellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        } else {
            if let previousYCell = GridView.previousVerCellView(from: cellView, in: cellViews) {
                cellView.topAnchor.constraint(equalTo: previousYCell.bottomAnchor).isActive = true
            }
        }
        
        if cellView.x == 0 {
            cellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        } else if cellView.x == configuration.size - 1 {
            if let previousXCell = GridView.previousHorCellView(from: cellView, in: cellViews) {
                cellView.leadingAnchor.constraint(equalTo: previousXCell.trailingAnchor).isActive = true
            }
            cellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
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

// MARK: - Counters View Constraints
extension GridView {
    
    func setTopCountersViewConstraints(counterView: GridCountView, counterViews: [Int: GridCountView], configuration: GridConfiguration) {
        
        counterView.translatesAutoresizingMaskIntoConstraints = false

        counterView.topAnchor.constraint(equalTo: topCountersBarView.topAnchor).isActive = true
        counterView.bottomAnchor.constraint(equalTo: topCountersBarView.bottomAnchor).isActive = true
        if let firstTopCountersView = counterViews[0] {
            counterView.widthAnchor.constraint(equalTo: firstTopCountersView.widthAnchor).isActive = true
        }
        
        if counterView.position == 0 {
            counterView.leadingAnchor.constraint(equalTo: topCountersBarView.leadingAnchor).isActive = true
        } else if counterView.position == configuration.size - 1 {
            if let previousCounterView = counterViews[counterView.position - 1] {
                counterView.leadingAnchor.constraint(equalTo: previousCounterView.trailingAnchor).isActive = true
            }
            counterView.trailingAnchor.constraint(equalTo: topCountersBarView.trailingAnchor).isActive = true
        } else {
            if let previousCounterView = counterViews[counterView.position - 1] {
                counterView.leadingAnchor.constraint(equalTo: previousCounterView.trailingAnchor).isActive = true
            }
        }
        
    }

    func setLeftCountersViewConstraints(counterView: GridCountView, counterViews: [Int: GridCountView], configuration: GridConfiguration) {
        
        counterView.translatesAutoresizingMaskIntoConstraints = false

        counterView.leadingAnchor.constraint(equalTo: leftCountersBarView.leadingAnchor).isActive = true
        counterView.trailingAnchor.constraint(equalTo: leftCountersBarView.trailingAnchor).isActive = true
        if let firstTopCountersView = counterViews[0] {
            counterView.heightAnchor.constraint(equalTo: firstTopCountersView.heightAnchor).isActive = true
        }
        
        if counterView.position == 0 {
            counterView.topAnchor.constraint(equalTo: leftCountersBarView.topAnchor).isActive = true
        } else if counterView.position == configuration.size - 1 {
            if let previousCounterView = counterViews[counterView.position - 1] {
                counterView.topAnchor.constraint(equalTo: previousCounterView.bottomAnchor).isActive = true
            }
            counterView.bottomAnchor.constraint(equalTo: leftCountersBarView.bottomAnchor).isActive = true
        } else {
            if let previousCounterView = counterViews[counterView.position - 1] {
                counterView.topAnchor.constraint(equalTo: previousCounterView.bottomAnchor).isActive = true
            }
        }
        
    }
    
}
