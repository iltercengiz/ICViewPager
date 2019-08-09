//
//  ScrollController.swift
//  ICViewPager
//
//  Created by Ilter Cengiz on 19/5/18.
//  Copyright © 2018 Ilter Cengiz. All rights reserved.
//

import UIKit

final class ScrollController {
    
    private unowned var viewPagerController: ViewPagerController
    private unowned var contentCollectionView: UICollectionView
    private unowned var tabCollectionView: UICollectionView
    private unowned var tabCollectionViewLayout: TabCollectionViewLayout
    
    // MARK: Init
    
    init(viewPagerController: ViewPagerController,
         contentCollectionView: UICollectionView,
         tabCollectionView: UICollectionView) {
        self.viewPagerController = viewPagerController
        self.contentCollectionView = contentCollectionView
        self.tabCollectionView = tabCollectionView
        self.tabCollectionViewLayout = tabCollectionView.collectionViewLayout as! TabCollectionViewLayout
    }
}

extension ScrollController: ContentCollectionViewDelegateProtocol {
    
    func contentCollectionViewDidScroll(_ collectionView: UICollectionView, direction: ScrollDirection) {
        tabCollectionViewLayout.updateIndicator(direction: direction)
    }
    
    func contentCollectionViewWillBeginDragging(_ collectionView: UICollectionView) {
        tabCollectionView.isUserInteractionEnabled = false
    }
    
    func contentCollectionViewDidEndDragging(_ collectionView: UICollectionView) {
        tabCollectionView.isUserInteractionEnabled = true
    }
    
    func contentCollectionView(_ collectionView: UICollectionView, didScrollToPageAt index: Int) {
        tabCollectionViewLayout.currentPage = index
        tabCollectionView.scrollToItem(at: IndexPath(item: index, section: 0),
                                       at: .left,
                                       animated: true)
    }
}

extension ScrollController: TabCollectionViewDelegateProtocol {
    
    func tabCollectionView(_ collectionView: UICollectionView, didSelectItemAt index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        contentCollectionView.scrollToItem(at: indexPath,
                                           at: .centeredHorizontally,
                                           animated: true)
        collectionView.scrollToItem(at: indexPath,
                                    at: .left,
                                    animated: true)
    }
}
