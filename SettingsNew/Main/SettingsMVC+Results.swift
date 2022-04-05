//
//  SettingsMVC+Results.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

extension SettingsMainViewController {
    func showResults(_ show: Bool) {
        if show {
            resultsViewController.contentViewBottomC?.isActive = true
            resultsViewController.view.alpha = 1
            pageViewController.view.alpha = 0
        } else {
            resultsViewController.contentViewBottomC?.isActive = false
            resultsViewController.view.alpha = 0
            pageViewController.view.alpha = 1
        }
    }
}
