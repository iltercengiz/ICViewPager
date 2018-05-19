//
//  DefaultTabItemView.swift
//  ICViewPager
//
//  Created by Ilter Cengiz on 19/5/18.
//  Copyright © 2018 Ilter Cengiz. All rights reserved.
//

import UIKit

final class DefaultTabItemView: TabItemView {
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 144.0, height: 44.0)
    }
    
    private var label: UILabel
    public var title: String {
        didSet {
            label.text = title
        }
    }
    
    init(title: String) {
        label = UILabel()
        self.title = title
        super.init(frame: .zero)
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpUI() {
        backgroundColor = .white
        
        label.text = title
        label.textAlignment = .center
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        embed(label)
    }
}
