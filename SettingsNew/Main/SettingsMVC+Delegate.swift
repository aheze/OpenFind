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

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        model.touchesEnabled = false
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        model.touchesEnabled = true
    }

    func updateSearchBarOffsetFromScroll(scrollView: UIScrollView) {
        let contentOffset = -scrollView.contentOffset.y
        additionalSearchBarOffset = contentOffset - baseSearchBarOffset - searchViewModel.getTotalHeight()
        model.updateNavigationBar?()
    }
}
