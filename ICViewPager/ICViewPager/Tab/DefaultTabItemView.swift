//
//  DefaultTabItemView.swift
//  ICViewPager
//
//  Created by Ilter Cengiz on 19/5/18.
//  Copyright © 2018 Ilter Cengiz. All rights reserved.
//

import UIKit

public final class DefaultTabItemView: TabItemView {
    
    private enum Constants {
        static let defaultTabItemSize = CGSize(width: 144.0, height: 44.0)
    }
    
    public override var intrinsicContentSize: CGSize {
        return Constants.defaultTabItemSize
    }
    
    private var label: UILabel
    public var title: String {
        didSet {
            label.text = title
        }
    }
    
    public init(title: String) {
        label = UILabel()
        self.title = title
        super.init(frame: .zero)
        setUpUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
    
private extension DefaultTabItemView {
    
    func setUpUI() {
        backgroundColor = .white
        
        label.font = UIFont.boldSystemFont(ofSize: 14.0)
        label.text = title
        label.textAlignment = .center
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        embed(label)
    }
}
