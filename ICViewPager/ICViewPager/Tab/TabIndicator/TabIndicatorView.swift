//
//  ActiveTabIndicatorView.swift
//  ICViewPager
//
//  Created by Ilter Cengiz on 20/5/18.
//  Copyright © 2018 Ilter Cengiz. All rights reserved.
//

import UIKit

final class TabIndicatorView: UICollectionReusableView {
    
    class var kind: String {
        return "\(TabIndicatorView.self)"
    }
    
    // MARK: Applying layout attributes
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        guard let attributes = layoutAttributes as? TabIndicatorAttributes else { return }
        backgroundColor = attributes.backgroundColor
    }
}
