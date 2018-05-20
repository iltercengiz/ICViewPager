//
//  ContentCollectionViewLayout.swift
//  ICViewPager
//
//  Created by Ilter Cengiz on 18/5/18.
//  Copyright © 2018 Ilter Cengiz. All rights reserved.
//

import UIKit

final class ContentCollectionViewLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        scrollDirection = .horizontal
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        scrollDirection = .horizontal
    }
    
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        itemSize = collectionView.bounds.size
        let sweetSpot = (UIScrollViewDecelerationRateFast * 0.64 + UIScrollViewDecelerationRateNormal * 0.36)
        collectionView.decelerationRate = sweetSpot
        collectionView.isPagingEnabled = false
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return proposedContentOffset }
        let proposedContentOffsetCenterX = proposedContentOffset.x + collectionView.bounds.width / 2.0
        let proposedRect = CGRect(origin: CGPoint(x: proposedContentOffset.x, y: 0.0),
                                  size: collectionView.bounds.size)
        let layoutAttributes = layoutAttributesForElements(in: proposedRect)?.sorted(by: {
            // Returning `true` means $0, $1 order, whereas `false` means $1, $0 order.
            let attr1Diff = fabs($0.center.x - proposedContentOffsetCenterX)
            let attr2Diff = fabs($1.center.x - proposedContentOffsetCenterX)
            return ((attr1Diff == attr2Diff && $0.indexPath.item == 0) || attr1Diff < attr2Diff)
        })
        guard let candidateAttributes = layoutAttributes?.first else { return proposedContentOffset }
        // Note: There's a rounding problem on iPhone+ models for x values.
        // It's advised to use NSInteger and check if it is smaller than zero and if so set it to zero.
        var x = candidateAttributes.center.x - collectionView.bounds.width / 2.0
        if x < 0 { x = 0 }
        return CGPoint(x: x, y: proposedContentOffset.y)
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                      withScrollingVelocity velocity: CGPoint) -> CGPoint {
        return targetContentOffset(forProposedContentOffset: proposedContentOffset)
    }
}
