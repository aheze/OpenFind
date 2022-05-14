//
//  SettingsMVC+Setup.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/1/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

extension SettingsMainViewController {
    func setup() {
        contentView.backgroundColor = .clear
        view.backgroundColor = .secondarySystemBackground
        scrollView.delegate = self
        scrollView.contentInset.top = searchViewModel.getTotalHeight()
        scrollView.verticalScrollIndicatorInsets.top = searchViewModel.getTotalHeight() + SearchNavigationConstants.scrollIndicatorTopPadding
        scrollView.keyboardDismissMode = .interactive
    }
}
