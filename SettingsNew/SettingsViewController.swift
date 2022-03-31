//
//  SettingsViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/30/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    var model: SettingsViewModel
    var split: UISplitViewController!

    static func make(
        model: SettingsViewModel
    ) -> SettingsViewController {
        let storyboard = UIStoryboard(name: "SettingsContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "SettingsViewController") { coder in
            SettingsViewController(
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

    override func viewDidLoad() {
        super.viewDidLoad()
        split = UISplitViewController(style: .doubleColumn)
        addChildViewController(split, in: view)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with metadata.")
    }
}
