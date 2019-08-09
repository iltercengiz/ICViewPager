//
//  UIView+Embed.swift
//  ICViewPager
//
//  Created by Ilter Cengiz on 18/5/18.
//  Copyright © 2018 Ilter Cengiz. All rights reserved.
//

import UIKit

extension UIView {
    
    func embed(_ view: UIView, insets: UIEdgeInsets = .zero) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        NSLayoutConstraint.activate(
            [view.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
             view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
             view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom),
             view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right)]
        )
    }
}
