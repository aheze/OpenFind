//
//  ListsController.swift
//  Lists
//
//  Created by Zheng on 11/18/21.
//

import UIKit

class ListsController {
    
    var listsViewModel: ListsViewModel
    var toolbarViewModel: ToolbarViewModel
    var realmModel: RealmModel
    
    var searchConfiguration: SearchConfiguration
    var searchNavigationController: SearchNavigationController
    var viewController: ListsViewController
    
    init(listsViewModel: ListsViewModel, toolbarViewModel: ToolbarViewModel, realmModel: RealmModel) {
        self.listsViewModel = listsViewModel
        self.toolbarViewModel = toolbarViewModel
        self.realmModel = realmModel
        
        let searchConfiguration = SearchConfiguration.lists
        self.searchConfiguration = searchConfiguration
        
        let storyboard = UIStoryboard(name: "ListsContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "ListsViewController") { coder in
            ListsViewController(
                coder: coder,
                listsViewModel: listsViewModel,
                toolbarViewModel: toolbarViewModel,
                realmModel: realmModel,
                searchConfiguration: searchConfiguration
            )
        }
        
        self.viewController = viewController
        let searchNavigationController = SearchNavigationController.make(
            rootViewController: viewController,
            searchConfiguration: searchConfiguration,
            tabType: .lists
        )
        searchNavigationController.onWillBecomeActive = { viewController.willBecomeActive() }
        searchNavigationController.onDidBecomeActive = { viewController.didBecomeActive() }
        searchNavigationController.onWillBecomeInactive = { viewController.willBecomeInactive() }
        searchNavigationController.onDidBecomeInactive = { viewController.didBecomeInactive() }
        
        self.searchNavigationController = searchNavigationController
    
        viewController.loadViewIfNeeded() /// needed to initialize outlets
        viewController.updateNavigationBar = { [weak self] in
            self?.searchNavigationController.updateSearchBarOffset()
        }
    }
}
