//
//  ActiveTabIndicatorView.swift
//  ICViewPager
//
//  Created by Ilter Cengiz on 20/5/18.
//  Copyright © 2018 Ilter Cengiz. All rights reserved.
//

import UIKit

final class ActiveTabIndicatorView: UICollectionReusableView {
    
    class var kind: String {
        return "\(ActiveTabIndicatorView.self)"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpUI()
    }
    
    private func setUpUI() {
        backgroundColor = .red
    }
}
