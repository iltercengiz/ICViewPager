//
//  TabCollectionViewCell.swift
//  ICViewPager
//
//  Created by Ilter Cengiz on 19/5/18.
//  Copyright © 2018 Ilter Cengiz. All rights reserved.
//

import UIKit

final class TabCollectionViewCell: UICollectionViewCell {
    
    weak var tabItemView: TabItemView? {
        didSet {
            guard oldValue !== tabItemView else { return }
            oldValue?.removeFromSuperview()
            guard let view = tabItemView else { return }
            contentView.embed(view)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        tabItemView?.prepareForReuse()
    }
}
