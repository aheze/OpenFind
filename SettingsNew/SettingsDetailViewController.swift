//
//  SettingsDetailViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/31/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

class SettingsDetailViewController: UIViewController {
    var model: SettingsViewModel
    
    static func make(
        model: SettingsViewModel
    ) -> SettingsDetailViewController {
        let storyboard = UIStoryboard(name: "SettingsContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "SettingsDetailViewController") { coder in
            SettingsDetailViewController(
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
    
}
