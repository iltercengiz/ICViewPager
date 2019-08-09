//
//  ViewPagerController.swift
//  ICViewPager
//
//  Created by Ilter Cengiz on 18/5/18.
//  Copyright © 2018 Ilter Cengiz. All rights reserved.
//

import UIKit

public final class ViewPagerController: UIViewController {
    
    @IBOutlet private weak var contentCollectionView: UICollectionView!
    @IBOutlet private weak var tabContainerStackView: UIStackView!
    @IBOutlet private weak var tabCollectionView: UICollectionView!
    @IBOutlet private weak var tabCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var tabCollectionViewLayout: TabCollectionViewLayout!
    @IBOutlet private weak var contentCollectionViewLayout: ContentCollectionViewLayout!
    
    var contentCollectionViewDataSource: ContentCollectionViewDataSource!
    var contentCollectionViewDelegate: ContentCollectionViewDelegate!
    var tabCollectionViewDataSource: TabCollectionViewDataSource!
    var tabCollectionViewDelegate: TabCollectionViewDelegate!
    var scrollController: ScrollController!
    
    public weak var dataSource: ViewPagerControllerDataSource? {
        didSet {
            tabCollectionViewDataSource?.dataSource = dataSource
            contentCollectionViewDataSource?.dataSource = dataSource
        }
    }
    public var configuration: ViewPagerConfiguration
    
    // MARK: Init
    
    public init(configuration: ViewPagerConfiguration = ViewPagerConfiguration()) {
        self.configuration = configuration
        super.init(nibName: "\(ViewPagerController.self)",
                   bundle: Bundle(for: ViewPagerController.self))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        configuration = ViewPagerConfiguration()
        super.init(coder: aDecoder)
    }
    
    // MARK: View life cycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setUpScrollController()
        setUpUI()
    }
}

private extension ViewPagerController {
    
    func setUpUI() {
        view.backgroundColor = .black
        adjustInsets()
        setUpContentCollectionView(contentCollectionView)
        setUpTabCollectionView(tabCollectionView)
        applyConfiguration(configuration)
    }
    
    func adjustInsets() {
        if #available(iOS 11.0, *) {
            additionalSafeAreaInsets = UIEdgeInsets(top: configuration.tabHeight, left: 0.0, bottom: 0.0, right: 0.0)
            contentCollectionView.contentInsetAdjustmentBehavior = .never
        } else {
            if let constraint = view.constraints.first(where: { $0.identifier == "tabAlignmentConstraint" }) {
                view.removeConstraint(constraint)
            }
            topLayoutGuide.bottomAnchor.constraint(equalTo: tabContainerStackView.topAnchor).isActive = true
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    func setUpContentCollectionView(_ collectionView: UICollectionView) {
        contentCollectionViewDataSource = ContentCollectionViewDataSource(viewPagerController: self,
                                                                          collectionView: collectionView)
        contentCollectionViewDataSource.dataSource = dataSource
        contentCollectionViewDelegate = ContentCollectionViewDelegate(viewPagerController: self,
                                                                      collectionView: collectionView)
        contentCollectionViewDelegate.delegate = scrollController
        collectionView.dataSource = contentCollectionViewDataSource
        collectionView.delegate = contentCollectionViewDelegate
    }
    
    func setUpTabCollectionView(_ collectionView: UICollectionView) {
        tabCollectionViewDataSource = TabCollectionViewDataSource(viewPagerController: self,
                                                                  collectionView: collectionView)
        tabCollectionViewDataSource.dataSource = dataSource
        tabCollectionViewDelegate = TabCollectionViewDelegate(viewPagerController: self)
        tabCollectionViewDelegate.delegate = scrollController
        collectionView.dataSource = tabCollectionViewDataSource
        collectionView.delegate = tabCollectionViewDelegate
        tabCollectionViewLayout.configuration = configuration
    }
    
    func applyConfiguration(_ configuration: ViewPagerConfiguration) {
        tabCollectionViewHeightConstraint.constant = configuration.tabHeight
    }
    
    func setUpScrollController() {
        scrollController = ScrollController(viewPagerController: self,
                                            contentCollectionView: contentCollectionView,
                                            tabCollectionView: tabCollectionView)
    }
}
