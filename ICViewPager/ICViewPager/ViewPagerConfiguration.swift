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
        fileprivate static let defaultTabSize = CGSize(width: 144.0, height: Constants.tabHeight)
    }
    
    public enum TabItemSizingPolicy {
        public static let defaultTabSize: CGSize = Constants.defaultTabSize
        
        case fixed(size: CGSize)
        case fill
    }
    
    public var tabHeight: CGFloat
    public var tabItemSizingPolicy: TabItemSizingPolicy
    public var tabIndicatorColor: UIColor
    
    public init(tabHeight: CGFloat = Constants.tabHeight,
                tabItemSizingPolicy: TabItemSizingPolicy = .fixed(size: TabItemSizingPolicy.defaultTabSize),
                tabIndicatorColor: UIColor = .red) {
        self.tabHeight = tabHeight
        self.tabItemSizingPolicy = tabItemSizingPolicy
        self.tabIndicatorColor = tabIndicatorColor
    }
}
