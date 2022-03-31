//
//  SettingsController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/30/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

class SettingsController {
    var model: SettingsViewModel
    var viewController: SettingsViewController
    var mainViewController: SettingsMainViewController
    var detailViewController: SettingsDetailViewController
    
    init() {
        let model = SettingsViewModel()
        self.model = model
        
        let viewController = SettingsViewController.make(model: model)
        let mainViewController = SettingsMainViewController.make(model: model)
        let detailViewController = SettingsDetailViewController.make(model: model)
        
        self.viewController = viewController
        self.mainViewController = mainViewController
        self.detailViewController = detailViewController
    }
}
