//
//  ApplicationDelegate.swift
//  ICViewPager
//
//  Created by Ilter Cengiz on 18/5/18.
//  Copyright © 2018 Ilter Cengiz. All rights reserved.
//

import UIKit

@UIApplicationMain
class ApplicationDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    
    var window: UIWindow?
    private let dataSource = ExampleViewPagerControllerDataSource()
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        
        window = UIWindow(frame: UIScreen.main.bounds)
//        window?.rootViewController = viewPagerController()
//        window?.rootViewController = navigationController()
        window?.rootViewController = tabBarController()
        window?.makeKeyAndVisible()
        
        return true
    }
    
    // MARK: Functions for test purposes
    
    private func viewPagerController() -> ViewPagerController {
        let viewPagerController = ViewPagerController()
        viewPagerController.dataSource = dataSource
        return viewPagerController
    }
    
    private func navigationController() -> UINavigationController {
        return UINavigationController(rootViewController: viewPagerController())
    }
    
    private func tabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [navigationController()]
        return tabBarController
    }
}
