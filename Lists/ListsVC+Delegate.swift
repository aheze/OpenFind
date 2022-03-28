//
//  ListsVC+Delegate.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/27/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

/// Scroll view
extension ListsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = -scrollView.contentOffset.y
        self.additionalSearchBarOffset = contentOffset - baseSearchBarOffset - searchViewModel.getTotalHeight()
        updateNavigationBar?()
    }
}
