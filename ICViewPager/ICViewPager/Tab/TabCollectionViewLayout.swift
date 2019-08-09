//
//  TabCollectionViewLayout.swift
//  ICViewPager
//
//  Created by Ilter Cengiz on 18/5/18.
//  Copyright © 2018 Ilter Cengiz. All rights reserved.
//

import UIKit

final class TabCollectionViewLayout: UICollectionViewFlowLayout {
    
    private enum Constants {
        static let indicatorHeight: CGFloat = 2.0
    }
    
    private var indicatorAttributes: TabIndicatorAttributes!
    private var invalidationContext: UICollectionViewFlowLayoutInvalidationContext = {
        let context = UICollectionViewFlowLayoutInvalidationContext()
        context.invalidateFlowLayoutAttributes = false
        context.invalidateFlowLayoutDelegateMetrics = false
        context.invalidateDecorationElements(ofKind: TabIndicatorView.kind,
                                             at: [TabIndicatorAttributes.Constants.indicatorIndexPath])
        return context
    }()
    
    var configuration: ViewPagerConfiguration!
    var currentPage: Int = 0
    var numberOfViews: Int = 0
    
    // MARK: Init
    
    override init() {
        super.init()
        setUpLayout()
        registerDecorationView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpLayout()
        registerDecorationView()
    }
    
    // MARK: Layout
    
    override func prepare() {
        super.prepare()
        if numberOfViews > 0 {
            indicatorAttributes = indicatorAttributes(for: currentPage)
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = super.layoutAttributesForElements(in: rect)
        if numberOfViews > 0 {
            attributes?.append(indicatorAttributes)
        }
        return attributes
    }

    override func layoutAttributesForDecorationView(ofKind elementKind: String,
                                                    at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard elementKind == TabIndicatorView.kind else { return nil }
        return indicatorAttributes
    }
    
    // MARK: Public functions
    
    func updateIndicator(direction: ScrollDirection) {
        
        let currentIndicatorAttributes = indicatorAttributes(for: currentPage)
        
        switch direction {
        case .left(let percentage):
            
            let previousIndicatorAttributes = indicatorAttributes(for: currentPage - 1)
            
            let frame = currentIndicatorAttributes.frame
            currentIndicatorAttributes.frame = CGRect(x: frame.minX - (frame.minX - previousIndicatorAttributes.frame.minX) * percentage,
                                                      y: frame.minY,
                                                      width: frame.width - (frame.width - previousIndicatorAttributes.frame.width) * percentage,
                                                      height: frame.height)
            
            indicatorAttributes = currentIndicatorAttributes
            
        case .right(let percentage):
            
            let nextIndicatorAttributes = indicatorAttributes(for: currentPage + 1)
            
            let frame = currentIndicatorAttributes.frame
            currentIndicatorAttributes.frame = CGRect(x: frame.minX + (nextIndicatorAttributes.frame.minX - frame.minX) * percentage,
                                                      y: frame.minY,
                                                      width: frame.width - (frame.width - nextIndicatorAttributes.frame.width) * percentage,
                                                      height: frame.height)
            
            indicatorAttributes = currentIndicatorAttributes
            
        case .stationary:
            
            break
        }
        
        invalidateLayout(with: invalidationContext)
    }
}

private extension TabCollectionViewLayout {
    
    func setUpLayout() {
        scrollDirection = .horizontal
        minimumInteritemSpacing = 0.0
        minimumLineSpacing = 0.0
    }
    
    func registerDecorationView() {
        register(TabIndicatorView.self,
                 forDecorationViewOfKind: TabIndicatorView.kind)
    }
    
    func indicatorAttributes(for page: Int) -> TabIndicatorAttributes {
        
        guard let tabItemAttributes = layoutAttributesForItem(at: IndexPath(item: page, section: 0)) else {
            fatalError("Called `indicatorAttributes(for:)` before super did its preparations.")
        }
        
        let tabItemFrame = tabItemAttributes.frame
        
        let indicatorAttributes = TabIndicatorAttributes(backgroundColor: configuration.tabIndicatorColor)
        indicatorAttributes.frame = CGRect(x: tabItemFrame.minX, y: tabItemFrame.maxY - Constants.indicatorHeight,
                                           width: tabItemFrame.width, height: Constants.indicatorHeight)
        return indicatorAttributes
    }
}
