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
    
    var searchViewModel: SearchViewModel
    var searchNavigationController: SearchNavigationController
    var viewController: ListsViewController
    
    init(listsViewModel: ListsViewModel, toolbarViewModel: ToolbarViewModel, realmModel: RealmModel) {
        self.listsViewModel = listsViewModel
        self.toolbarViewModel = toolbarViewModel
        self.realmModel = realmModel
        
        let searchViewModel = SearchViewModel(configuration: .lists)
        self.searchViewModel = searchViewModel
        
        let storyboard = UIStoryboard(name: "ListsContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "ListsViewController") { coder in
            ListsViewController(
                coder: coder,
                listsViewModel: listsViewModel,
                toolbarViewModel: toolbarViewModel,
                realmModel: realmModel,
                searchViewModel: searchViewModel
            )
        }
        
        self.viewController = viewController
        let searchNavigationController = SearchNavigationController.make(
            rootViewController: viewController,
            searchViewModel: searchViewModel,
            tabType: .lists
        )
        searchNavigationController.onWillBecomeActive = { viewController.willBecomeActive() }
        searchNavigationController.onDidBecomeActive = { viewController.didBecomeActive() }
        searchNavigationController.onWillBecomeInactive = { viewController.willBecomeInactive() }
        searchNavigationController.onDidBecomeInactive = { viewController.didBecomeInactive() }
        searchNavigationController.onBoundsChange = { (size, safeAreaInset) in
            viewController.boundsChanged(to: size, safeAreaInsets: safeAreaInset)
        }
        
        
        self.searchNavigationController = searchNavigationController
    
        viewController.loadViewIfNeeded() /// needed to initialize outlets
        viewController.updateNavigationBar = { [weak self] in
            self?.searchNavigationController.updateSearchBarOffset()
        }
    }
}
