//
//  TabCollectionViewDelegate.swift
//  ICViewPager
//
//  Created by Ilter Cengiz on 19/5/18.
//  Copyright © 2018 Ilter Cengiz. All rights reserved.
//

import UIKit

protocol TabCollectionViewDelegateProtocol: class {
    
    func tabCollectionView(_ collectionView: UICollectionView, didSelectItemAt index: Int)
}

final class TabCollectionViewDelegate: NSObject {
    
    private unowned var viewPagerController: ViewPagerController
    private lazy var numberOfItems: Int = self.viewPagerController.tabCollectionViewDataSource.numberOfViews
    weak var delegate: TabCollectionViewDelegateProtocol?
    
    // MARK: Init
    
    init(viewPagerController: ViewPagerController) {
        self.viewPagerController = viewPagerController
        super.init()
    }
}

// MARK: UICollectionViewDelegate

extension TabCollectionViewDelegate: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        delegate?.tabCollectionView(collectionView, didSelectItemAt: indexPath.item)
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension TabCollectionViewDelegate: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let tabItemSizingPolicy = viewPagerController.configuration.tabItemSizingPolicy
        switch tabItemSizingPolicy {
        case .fixed(let size):
            return size
        case .fill:
            return CGSize(width: collectionView.bounds.width / CGFloat(numberOfItems),
                          height: collectionView.bounds.height)
        }
    }
}
