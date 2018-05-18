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
        setUpLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpLayout()
    }
}

private extension ContentCollectionViewLayout {
    
    func setUpLayout() {
        scrollDirection = .horizontal
        sectionInset = .zero
        minimumInteritemSpacing = 0.0
        minimumLineSpacing = 0.0
    }
}
