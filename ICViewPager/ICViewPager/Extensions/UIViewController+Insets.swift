//
//  UIViewController+Insets.swift
//  ICViewPager
//
//  Created by Ilter Cengiz on 19/5/18.
//  Copyright © 2018 Ilter Cengiz. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func adjustScrollViewInsets(insets: UIEdgeInsets) {
        if let scrollView = firstQualifyingScrollView() {
            adjustInsets(of: scrollView, insets: insets)
        }
    }
    
    private func firstQualifyingScrollView() -> UIScrollView? {
        if let scrollView = view as? UIScrollView {
            return scrollView
        } else if let scrollView = view.subviews.first as? UIScrollView {
            return scrollView
        }
        return nil
    }
    
    private func adjustInsets(of scrollView: UIScrollView, insets: UIEdgeInsets) {
        var scrollViewInsets = scrollView.contentInset
        scrollViewInsets.top = insets.top
        scrollViewInsets.bottom = insets.bottom
        scrollView.contentInset = scrollViewInsets
        scrollView.scrollIndicatorInsets = scrollViewInsets
    }
}
