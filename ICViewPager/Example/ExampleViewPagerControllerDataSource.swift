//
//  ExampleViewPagerControllerDataSource.swift
//  ICViewPager
//
//  Created by Ilter Cengiz on 19/5/18.
//  Copyright © 2018 Ilter Cengiz. All rights reserved.
//

import UIKit

final class ExampleViewPagerControllerDataSource {
    
    private var viewControllers: [UIViewController] = [
        EmptyViewController(backgroundColor: #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1), number: 0),
        EmptyViewController(backgroundColor: #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1), number: 1),
        EmptyViewController(backgroundColor: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), number: 2),
        EmptyViewController(backgroundColor: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), number: 3),
        EmptyViewController(backgroundColor: #colorLiteral(red: 0.3098039329, green: 0.2039215714, blue: 0.03921568766, alpha: 1), number: 4),
        EmptyViewController(backgroundColor: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), number: 5),
        EmptyViewController(backgroundColor: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), number: 6),
        EmptyViewController(backgroundColor: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), number: 7),
        EmptyViewController(backgroundColor: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), number: 8),
        EmptyViewController(backgroundColor: #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1), number: 9)
    ]
}

extension ExampleViewPagerControllerDataSource: ViewPagerControllerDataSource {
    
    func viewPagerController(_ controller: ViewPagerController,
                             viewControllerAt index: Int) -> UIViewController {
        return viewControllers[index]
    }
    
    func viewPagerController(_ controller: ViewPagerController,
                             tabItemViewAt index: Int,
                             reusingTabItemView tabItemView: TabItemView?) -> TabItemView {
        let title = "Title #\(index)"
        if let view = tabItemView as? DefaultTabItemView {
            view.title = title
            return view
        }
        return DefaultTabItemView(title: title)
    }
    
    func numberOfViews(in controller: ViewPagerController) -> Int {
        return viewControllers.count
    }
}
