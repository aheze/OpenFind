//
//  PhotoFindVC+Setup.swift
//  Find
//
//  Created by Zheng on 1/15/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotoFindViewController {
    func setup() {
        progressView.alpha = 0
        
        findBar.findBarDelegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        let bottomSafeAreaHeight = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.bottom ?? 0
        tableView.contentInset.bottom = CGFloat(FindConstantVars.tabHeight) + CGFloat(16)
        tableView.verticalScrollIndicatorInsets.bottom = CGFloat(FindConstantVars.tabHeight) - CGFloat(bottomSafeAreaHeight)
    }
}
