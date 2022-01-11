//
//  ListsController.swift
//  Lists
//
//  Created by Zheng on 11/18/21.
//

import UIKit

class ListsController {
    var searchConfiguration: SearchConfiguration
    var listsViewModel: ListsViewModel
    var searchNavigationController: SearchNavigationController
    var viewController: ListsViewController
    
    init(listsViewModel: ListsViewModel) {
        self.listsViewModel = listsViewModel
        let searchConfiguration = SearchConfiguration.lists
        self.searchConfiguration = searchConfiguration
        
        let storyboard = UIStoryboard(name: "ListsContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "ListsViewController") { coder in
            ListsViewController(
                coder: coder,
                listsViewModel: listsViewModel,
                searchConfiguration: searchConfiguration
            )
        }
        
        self.viewController = viewController
        let searchNavigationController = SearchNavigationController.make(
            rootViewController: viewController,
            searchConfiguration: searchConfiguration
        )
        self.searchNavigationController = searchNavigationController
    
        viewController.loadViewIfNeeded() /// needed to initialize outlets
        viewController.updateNavigationBar = { [weak self] in
            self?.searchNavigationController.updateSearchBarOffset()
        }
    }
}
