//
//  ContentCollectionViewDelegate.swift
//  ICViewPager
//
//  Created by Ilter Cengiz on 19/5/18.
//  Copyright © 2018 Ilter Cengiz. All rights reserved.
//

import UIKit

final class ContentCollectionViewDelegate: NSObject {
    
    private unowned var viewPagerController: ViewPagerController
    
    // MARK: Init
    
    init(viewPagerController: ViewPagerController) {
        self.viewPagerController = viewPagerController
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
