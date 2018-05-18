//
//  ViewPagerConfiguration.swift
//  ICViewPager
//
//  Created by Ilter Cengiz on 18/5/18.
//  Copyright © 2018 Ilter Cengiz. All rights reserved.
//

import UIKit

public struct ViewPagerConfiguration {
    
    public struct Constants {
        public static let tabHeight: CGFloat = 44.0
    }
    
    public var tabHeight: CGFloat
    
    public init(tabHeight: CGFloat = Constants.tabHeight) {
        self.tabHeight = tabHeight
    }
}
