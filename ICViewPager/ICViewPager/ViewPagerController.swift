//
//  ViewPagerController.swift
//  ICViewPager
//
//  Created by Ilter Cengiz on 18/5/18.
//  Copyright © 2018 Ilter Cengiz. All rights reserved.
//

import UIKit

final public class ViewPagerController: UIViewController {
    
    @IBOutlet private weak var contentCollectionView: UICollectionView!
    @IBOutlet private weak var tabContainerStackView: UIStackView!
    @IBOutlet private weak var tabCollectionView: UICollectionView!
    @IBOutlet private weak var tabCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var tabCollectionViewLayout: TabCollectionViewLayout!
    @IBOutlet private weak var contentCollectionViewLayout: ContentCollectionViewLayout!
    
    public private(set) var configuration: ViewPagerConfiguration
    
    // MARK: Init
    
    public init(configuration: ViewPagerConfiguration = ViewPagerConfiguration()) {
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View life cycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
}

private extension ViewPagerController {
    
    func setUpUI() {
        applyConfiguration(configuration)
    }
    
    func applyConfiguration(_ configuration: ViewPagerConfiguration) {
        tabCollectionViewHeightConstraint.constant = configuration.tabHeight
    }
}
