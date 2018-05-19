//
//  TabCollectionViewDataSource.swift
//  ICViewPager
//
//  Created by Ilter Cengiz on 19/5/18.
//  Copyright © 2018 Ilter Cengiz. All rights reserved.
//

import UIKit

final class TabCollectionViewDataSource: NSObject {
    
    private struct Constants {
        static let cellIdentifier = "\(TabCollectionViewCell.self)"
    }
    
    private unowned var viewPagerController: ViewPagerController
    private unowned var collectionView: UICollectionView
    weak var dataSource: ViewPagerControllerDataSource?
    
    // MARK: Init
    
    init(viewPagerController: ViewPagerController, collectionView: UICollectionView) {
        self.viewPagerController = viewPagerController
        self.collectionView = collectionView
        super.init()
        registerTabCell()
    }
}

// MARK: Private functions

private extension TabCollectionViewDataSource {
    
    func registerTabCell() {
        collectionView.register(TabCollectionViewCell.self,
                                forCellWithReuseIdentifier: Constants.cellIdentifier)
    }
    
    func tabItemView(at index: Int, reuseTabItemView view: TabItemView?) -> TabItemView {
        
        guard let dataSource = dataSource else {
            fatalError("ViewPagerControllerDataSource is not provided!")
        }
        
        return dataSource.viewPagerController(viewPagerController, tabItemViewAt: index, reusingTabItemView: view)
    }
}

// MARK: UICollectionViewDataSource

extension TabCollectionViewDataSource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier,
                                                      for: indexPath) as! TabCollectionViewCell
        cell.tabItemView = tabItemView(at: indexPath.item, reuseTabItemView: cell.tabItemView)
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        guard let dataSource = dataSource else {
            fatalError("ViewPagerControllerDataSource is not provided!")
        }
        
        return dataSource.numberOfViews(in: viewPagerController)
    }
}
