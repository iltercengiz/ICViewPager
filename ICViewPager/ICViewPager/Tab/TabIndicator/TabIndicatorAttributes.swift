//
//  TabIndicatorAttributes.swift
//  ICViewPager
//
//  Created by Ilter Cengiz on 22/5/18.
//  Copyright © 2018 Ilter Cengiz. All rights reserved.
//

import UIKit

final class TabIndicatorAttributes: UICollectionViewLayoutAttributes {
    
    enum Constants {
        static let indicatorIndexPath: IndexPath = IndexPath(item: 0, section: 0)
    }
    
    private(set) var backgroundColor: UIColor = .black
    /** To be able to have the following `init(backgroundColor:)`, this `backgroundColor` property must have
     a default value, as all the `init` functions are defined as `convenience`, except the one that's
     inherited from `NSObject` which is pure `init()`. */
    
    convenience init(backgroundColor: UIColor) {
        self.init(forDecorationViewOfKind: TabIndicatorView.kind,
                  with: Constants.indicatorIndexPath)
        self.backgroundColor = backgroundColor
    }
}

private extension TabIndicatorAttributes {
    
    func setUpAttributes() {
        zIndex = .max
    }
}
