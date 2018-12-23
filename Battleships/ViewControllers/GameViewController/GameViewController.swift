//
//  GameViewController.swift
//  Battleships
//
//  Created by cdebortoli on 23/12/2018.
//  Copyright © 2018 CDB. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxSwiftExt


class GameViewController: UIViewController {
    
    @IBOutlet weak var gridScrollView: UIScrollView!
    @IBOutlet weak var gridView: GridView!
    @IBOutlet weak var gridViewHeightConstraint: NSLayoutConstraint!
    
    fileprivate var viewDidLayoutSubviewsSubject = PublishSubject<Void>()
    fileprivate var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        gridScrollView.delegate = self
        
        setup()
    }
    
    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()
        viewDidLayoutSubviewsSubject.onNext(())
        
    }
    
    func setup() {
        
        setupAppearance()
        
    }
    
    func setupAppearance() {
        
        let updateGridViewSize = viewDidLayoutSubviewsSubject
                                    .withLatestFrom(gridView.viewModel.configurationOutput)
       Observable
        .merge(gridView.viewModel.configurationOutput, updateGridViewSize)
        .map { GameViewController.gridViewSize(configuration: $0) }
        .map { [weak self] gridViewSize -> (scrollViewSize: CGFloat, gridViewSize: CGFloat) in
            guard let strongSelf = self else { return (scrollViewSize: 320.0 , gridViewSize: gridViewSize) }
            let scrollViewSize = min(strongSelf.gridScrollView.bounds.height, strongSelf.gridScrollView.bounds.width)
            return (scrollViewSize: scrollViewSize, gridViewSize: max(gridViewSize, scrollViewSize))
        }
        .do(onNext: { [weak self] (scrollViewSize, gridViewSize) in
            self?.updateScrollViewZoomScale(scrollViewSize: scrollViewSize, gridViewSize: gridViewSize)
        })
        .map { $0.gridViewSize }
        .bind(to: gridViewHeightConstraint.rx.constant)
        .disposed(by: disposeBag)
    }
    
}

extension GameViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return gridView
    }
    
    func updateScrollViewZoomScale(scrollViewSize: CGFloat, gridViewSize: CGFloat) {
        
        if gridViewSize > scrollViewSize {
            gridScrollView.maximumZoomScale = gridViewSize/scrollViewSize
            gridScrollView.minimumZoomScale = scrollViewSize/gridViewSize
            gridScrollView.zoomScale = gridScrollView.minimumZoomScale
        } else {
            gridScrollView.maximumZoomScale = 1.0
            gridScrollView.minimumZoomScale = 1.0
            gridScrollView.zoomScale = 1.0
        }
        
    }
    
    static func gridViewSize(configuration: GridConfiguration) -> CGFloat {
        
        return CGFloat(configuration.size) * CGFloat(44)
        
    }
}
