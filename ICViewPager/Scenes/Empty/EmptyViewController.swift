//
//  EmptyViewController.swift
//  ICViewPager
//
//  Created by Ilter Cengiz on 18/5/18.
//  Copyright © 2018 Ilter Cengiz. All rights reserved.
//

import UIKit

class EmptyViewController: UIViewController {
    
    var backgroundColor: UIColor
    var number: Int
    @IBOutlet weak var numberLabel: UILabel!
    
    // MARK: Init
    
    init(backgroundColor: UIColor, number: Int) {
        self.backgroundColor = backgroundColor
        self.number = number
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        backgroundColor = .blue
        number = 0
        super.init(coder: aDecoder)
    }
    
    // MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = backgroundColor
        numberLabel.text = "\(number)"
    }
}
