//
//  ContentCollectionViewCell.swift
//  ICViewPager
//
//  Created by Ilter Cengiz on 18/5/18.
//  Copyright © 2018 Ilter Cengiz. All rights reserved.
//

import UIKit

final class ContentCollectionViewCell: UICollectionViewCell {
    
    private var contentViewController: UIViewController?
    
    // MARK: Public functions
    
    func configure(contentViewController: UIViewController) {
        self.contentViewController = contentViewController
    }
    
    // MARK: View controller containment
    
    func addContentViewController(to parentViewController: UIViewController) {
        
        guard let viewController = contentViewController else { return }
        
        parentViewController.addChildViewController(viewController)
        contentView.embed(viewController.view)
        viewController.didMove(toParentViewController: parentViewController)
        contentViewController = viewController
    }
    
    func removeContentViewController() {
        contentViewController?.willMove(toParentViewController: nil)
        contentViewController?.view.removeFromSuperview()
        contentViewController?.removeFromParentViewController()
    }
}
