//
//  SettingsMVC+Delegate.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/1/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension SettingsMainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateSearchBarOffsetFromScroll(scrollView: scrollView)
    }
    
    func updateSearchBarOffsetFromScroll(scrollView: UIScrollView) {
        let contentOffset = -scrollView.contentOffset.y
        self.additionalSearchBarOffset = contentOffset - baseSearchBarOffset - searchViewModel.getTotalHeight()
        updateSearchBarOffset?()
    }
}
