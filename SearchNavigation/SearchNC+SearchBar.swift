//
//  SearchNC+SearchBar.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/9/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

extension SearchNavigationController {
    func createSearchBar() -> SearchViewController {
        let searchViewController = Bridge.makeViewController(
            searchViewModel: searchViewModel,
            configuration: searchConfiguration
        )
        
        searchContainerView.backgroundColor = .clear
        addResizableChildViewController(searchViewController, in: searchContainerView)
        searchContainerViewTopC.constant = scrollView.adjustedContentInset.top /// top safe area by default
        
        return searchViewController
    }
}
