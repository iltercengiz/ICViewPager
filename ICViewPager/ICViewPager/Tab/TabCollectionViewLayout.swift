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
        static let indicatorIndexPath: IndexPath = IndexPath(item: 0, section: 0)
        static let indicatorHeight: CGFloat = 2.0
    }
    
    private var indicatorAttributes: UICollectionViewLayoutAttributes!
    private var invalidationContext: UICollectionViewFlowLayoutInvalidationContext = {
        let context = UICollectionViewFlowLayoutInvalidationContext()
        context.invalidateFlowLayoutAttributes = false
        context.invalidateFlowLayoutDelegateMetrics = false
        context.invalidateDecorationElements(ofKind: ActiveTabIndicatorView.kind, at: [Constants.indicatorIndexPath])
        return context
    }()
    
    var currentPage: Int = 0
    
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
        indicatorAttributes = indicatorAttributes(for: currentPage)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = super.layoutAttributesForElements(in: rect)
        attributes?.append(indicatorAttributes)
        return attributes
    }

    override func layoutAttributesForDecorationView(ofKind elementKind: String,
                                                    at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard elementKind == ActiveTabIndicatorView.kind else { return nil }
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
        register(ActiveTabIndicatorView.self,
                 forDecorationViewOfKind: ActiveTabIndicatorView.kind)
    }
    
    func indicatorAttributes(for page: Int) -> UICollectionViewLayoutAttributes {
        
        guard let tabItemAttributes = layoutAttributesForItem(at: IndexPath(item: page, section: 0)) else {
            #if DEBUG
            NSLog("Called `indicatorAttributes(for:)` before super did its preparations.")
            #endif
            return UICollectionViewLayoutAttributes()
        }
        
        let tabItemFrame = tabItemAttributes.frame
        
        let indicatorAttributes = UICollectionViewLayoutAttributes(forDecorationViewOfKind: ActiveTabIndicatorView.kind,
                                                                   with: Constants.indicatorIndexPath)
        indicatorAttributes.frame = CGRect(x: tabItemFrame.minX, y: tabItemFrame.maxY - Constants.indicatorHeight,
                                           width: tabItemFrame.width, height: Constants.indicatorHeight)
        indicatorAttributes.zIndex = Int.max
        return indicatorAttributes
    }
}
