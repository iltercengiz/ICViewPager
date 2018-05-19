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
        return CGSize(width: 144.0, height: 44.0)
    }
}
