//
//  SettingsMainViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/31/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

class SettingsMainViewController: UIViewController {
    var model: SettingsViewModel
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var contentViewHeightC: NSLayoutConstraint!
    
    static func make(
        model: SettingsViewModel
    ) -> SettingsMainViewController {
        let storyboard = UIStoryboard(name: "SettingsContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "SettingsMainViewController") { coder in
            SettingsMainViewController(
                coder: coder,
                model: model
            )
        }
        return viewController
    }

    init?(
        coder: NSCoder,
        model: SettingsViewModel
    ) {
        self.model = model
        super.init(coder: coder)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with metadata.")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        
        scrollView.backgroundColor = .secondarySystemBackground
    }
}
