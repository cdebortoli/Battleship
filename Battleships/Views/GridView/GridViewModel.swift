//
//  GridViewModel.swift
//  Battleships
//
//  Created by cdebortoli on 23/12/2018.
//  Copyright © 2018 CDB. All rights reserved.
//
import Foundation
import RxSwift
import RxCocoa

class GridViewModel {
    
    var configurationOutput: Observable<GridConfiguration> { return configurationInput.asObservable() }
    var configurationInput = BehaviorRelay<GridConfiguration>(value: GridConfiguration(size: 6, name: "default"))
    
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
