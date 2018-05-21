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
    
    public enum TabItemSizingPolicy {
        public static let defaultTabWidth: CGSize = CGSize(width: 144.0, height: Constants.tabHeight)
        
        case fixed(size: CGSize)
        case fill
    }
    
    public var tabHeight: CGFloat
    public var tabItemSizingPolicy: TabItemSizingPolicy
    
    public init(tabHeight: CGFloat = Constants.tabHeight,
                tabItemSizingPolicy: TabItemSizingPolicy = .fixed(size: TabItemSizingPolicy.defaultTabWidth)) {
        self.tabHeight = tabHeight
        self.tabItemSizingPolicy = tabItemSizingPolicy
    }
}
