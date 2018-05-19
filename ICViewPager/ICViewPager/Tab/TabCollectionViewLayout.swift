//
//  TabCollectionViewLayout.swift
//  ICViewPager
//
//  Created by Ilter Cengiz on 18/5/18.
//  Copyright © 2018 Ilter Cengiz. All rights reserved.
//

import UIKit

final class TabCollectionViewLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        setUpLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpLayout()
    }
}

private extension TabCollectionViewLayout {
    
    func setUpLayout() {
        scrollDirection = .horizontal
        sectionInset = .zero
        minimumInteritemSpacing = 0.0
        minimumLineSpacing = 0.0
    }
}
