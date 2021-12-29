//
//  CameraVC+SearchBar.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/28/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//
    
import UIKit

extension CameraViewController {
    func createSearchBar() -> SearchViewController {
        searchViewModel.availableLists = listsViewModel.lists
        let searchViewController = Bridge.makeViewController(searchViewModel: searchViewModel)
        
        searchContainerView.backgroundColor = .clear
        addResizableChild(searchViewController, in: searchContainerView)
        return searchViewController
    }
}
