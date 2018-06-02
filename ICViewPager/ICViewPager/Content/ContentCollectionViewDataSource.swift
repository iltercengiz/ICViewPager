//
//  ContentCollectionViewDataSource.swift
//  ICViewPager
//
//  Created by Ilter Cengiz on 18/5/18.
//  Copyright © 2018 Ilter Cengiz. All rights reserved.
//

import UIKit

final class ContentCollectionViewDataSource: NSObject {
    
    private struct Constants {
        static let cellIdentifier = "\(ContentCollectionViewCell.self)"
    }
    
    private unowned var viewPagerController: ViewPagerController
    private unowned var collectionView: UICollectionView
    private var viewControllerCache: [Int: UIViewController] = [:]
    weak var dataSource: ViewPagerControllerDataSource? {
        didSet { collectionView.reloadData() }
    }
    
    // MARK: Init
    
    init(viewPagerController: ViewPagerController, collectionView: UICollectionView) {
        self.viewPagerController = viewPagerController
        self.collectionView = collectionView
        super.init()
        registerContentCell()
    }
}

// MARK: Private functions

private extension ContentCollectionViewDataSource {
    
    func registerContentCell() {
        collectionView.register(ContentCollectionViewCell.self,
                                forCellWithReuseIdentifier: Constants.cellIdentifier)
    }
    
    func viewController(at index: Int) -> UIViewController {
        
        if let viewController = viewControllerCache[index] {
            return viewController
        }
        
        guard let dataSource = dataSource else {
            fatalError("ViewPagerControllerDataSource is not provided!")
        }
        
        let viewController = dataSource.viewPagerController(viewPagerController,
                                                            viewControllerAt: index)
        
        if #available(iOS 11.0, *) {
            // Do nothing. Safe area guide handles the insets.
        } else {
            let topInset = viewPagerController.topLayoutGuide.length + viewPagerController.configuration.tabHeight
            let bottomInset = viewPagerController.bottomLayoutGuide.length
            let insets = UIEdgeInsetsMake(topInset, 0.0, bottomInset, 0.0)
            viewController.adjustScrollViewInsets(insets: insets)
        }
        
        viewControllerCache[index] = viewController
        
        return viewController
    }
}

// MARK: UICollectionViewDataSource

extension ContentCollectionViewDataSource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier,
                                                      for: indexPath) as! ContentCollectionViewCell
        let contentViewController = viewController(at: indexPath.item)
        cell.configure(contentViewController: contentViewController)
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        guard let dataSource = dataSource else {
            return 0
        }
        
        return dataSource.numberOfViews(in: viewPagerController)
    }
}
