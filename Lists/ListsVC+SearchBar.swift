//
//  ListsVC+SearchBar.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/8/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

extension ListsViewController {
    func createSearchBar() -> SearchViewController {
        let searchViewController = Bridge.makeViewController(searchViewModel: searchViewModel)
        
        searchContainerView.backgroundColor = .clear
        addResizableChildViewController(searchViewController, in: searchContainerView)
        searchContainerViewTopC.constant = collectionView.adjustedContentInset.top /// top safe area by default
        
        return searchViewController
    }
}
