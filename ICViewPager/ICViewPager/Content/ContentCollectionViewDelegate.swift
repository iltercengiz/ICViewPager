//
//  ContentCollectionViewDelegate.swift
//  ICViewPager
//
//  Created by Ilter Cengiz on 19/5/18.
//  Copyright © 2018 Ilter Cengiz. All rights reserved.
//

import UIKit

protocol ContentCollectionViewDelegateProtocol: class {
    
    func contentCollectionViewDidScroll(_ collectionView: UICollectionView, direction: ScrollDirection)
    func contentCollectionViewWillBeginDragging(_ collectionView: UICollectionView)
    func contentCollectionViewDidEndDragging(_ collectionView: UICollectionView)
    func contentCollectionView(_ collectionView: UICollectionView, didScrollToPageAt index: Int)
}

final class ContentCollectionViewDelegate: NSObject {
    
    private unowned var viewPagerController: ViewPagerController
    private unowned var collectionView: UICollectionView
    weak var delegate: ContentCollectionViewDelegateProtocol?
    
    public private(set) var currentPage: Int = 0
    private var contentOffsetBeforeDragging: CGPoint = .zero
    private var shouldResetContentOffsetBeforeDragging: Bool = true
    
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

// MARK: UIScrollViewDelegate

extension ContentCollectionViewDelegate: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard let layout = collectionView.collectionViewLayout as? ContentCollectionViewLayout else { return }
        
        let diff = CGFloat(abs(contentOffsetBeforeDragging.x - scrollView.contentOffset.x))
        let percentage = diff / (scrollView.bounds.width + layout.minimumLineSpacing)
        
        let direction: ScrollDirection
        if scrollView.contentOffset.x < contentOffsetBeforeDragging.x {
            direction = .left(percentage: percentage)
        } else if scrollView.contentOffset.x > contentOffsetBeforeDragging.x {
            direction = .right(percentage: percentage)
        } else {
            direction = .stationary
        }
        
        delegate?.contentCollectionViewDidScroll(collectionView, direction: direction)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if shouldResetContentOffsetBeforeDragging {
            contentOffsetBeforeDragging = scrollView.contentOffset
            shouldResetContentOffsetBeforeDragging = false
        }
        delegate?.contentCollectionViewWillBeginDragging(collectionView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                  willDecelerate decelerate: Bool) {
        delegate?.contentCollectionViewDidEndDragging(collectionView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let layout = collectionView.collectionViewLayout as? ContentCollectionViewLayout else { return }
        let width = layout.itemSize.width
        let spacing = layout.minimumLineSpacing
        currentPage = Int(floor((scrollView.contentOffset.x + spacing) / (width + spacing)))
        delegate?.contentCollectionView(collectionView, didScrollToPageAt: currentPage)
        
        shouldResetContentOffsetBeforeDragging = true
    }
}
