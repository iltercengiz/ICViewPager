//
//  ContentCollectionViewDelegate.swift
//  ICViewPager
//
//  Created by Ilter Cengiz on 19/5/18.
//  Copyright © 2018 Ilter Cengiz. All rights reserved.
//

import UIKit

protocol ContentCollectionViewDelegateProtocol: class {
    
    func contentCollectionView(_ collectionView: UICollectionView, didScroll offset: CGPoint)
    func contentCollectionViewWillBeginDragging(_ collectionView: UICollectionView)
    func contentCollectionViewDidEndDragging(_ collectionView: UICollectionView)
}

final class ContentCollectionViewDelegate: NSObject {
    
    private unowned var viewPagerController: ViewPagerController
    private unowned var collectionView: UICollectionView
    weak var delegate: ContentCollectionViewDelegateProtocol?
    
    // MARK: Init
    
    init(viewPagerController: ViewPagerController, collectionView: UICollectionView) {
        self.viewPagerController = viewPagerController
        self.collectionView = collectionView
        super.init()
    }
}

// MARK: Private functions

private extension ContentCollectionViewDelegate {
    
}

// MARK: UICollectionViewDelegate

extension ContentCollectionViewDelegate: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView,
                               willDisplay cell: UICollectionViewCell,
                               forItemAt indexPath: IndexPath) {
        guard let contentCell = cell as? ContentCollectionViewCell else { return }
        contentCell.addContentViewController(to: viewPagerController)
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               didEndDisplaying cell: UICollectionViewCell,
                               forItemAt indexPath: IndexPath) {
        guard let contentCell = cell as? ContentCollectionViewCell else { return }
        contentCell.removeContentViewController()
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension ContentCollectionViewDelegate: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}

// MARK: UIScrollViewDelegate

extension ContentCollectionViewDelegate: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.contentCollectionView(collectionView, didScroll: scrollView.contentOffset)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.contentCollectionViewWillBeginDragging(collectionView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                  willDecelerate decelerate: Bool) {
        delegate?.contentCollectionViewDidEndDragging(collectionView)
    }
}
