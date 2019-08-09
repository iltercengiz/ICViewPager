//
//  ViewPagerControllerDataSource.swift
//  ICViewPager
//
//  Created by Ilter Cengiz on 18/5/18.
//  Copyright © 2018 Ilter Cengiz. All rights reserved.
//

import UIKit

public protocol ViewPagerControllerDataSource: class {
    
    func viewPagerController(_ controller: ViewPagerController,
                             viewControllerAt index: Int) -> UIViewController
    
    func viewPagerController(_ controller: ViewPagerController,
                             tabItemViewAt index: Int,
                             reusingTabItemView tabItemView: TabItemView?) -> TabItemView
    
    func numberOfViews(in controller: ViewPagerController) -> Int
}
