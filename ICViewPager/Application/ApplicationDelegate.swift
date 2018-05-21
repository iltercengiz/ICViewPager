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
        
        /** To test different container scenarios, enable one option. */
        window?.rootViewController = viewPagerController()
//        window?.rootViewController = navigationController()
//        window?.rootViewController = tabBarController()
        
        window?.makeKeyAndVisible()
        
        return true
    }
    
    // MARK: Functions for test purposes
    
    private func viewPagerController() -> ViewPagerController {
        
        /** ViewPagerController configuration here. All the configuration properties are optional. */
        let configuration = ViewPagerConfiguration(tabHeight: 48.0,
                                                   tabItemSizingPolicy: .fill)
        
        let viewPagerController = ViewPagerController(configuration: configuration)
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
