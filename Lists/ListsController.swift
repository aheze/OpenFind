//
//  ListsController.swift
//  Lists
//
//  Created by Zheng on 11/18/21.
//

import UIKit

class ListsController {
    var model: ListsViewModel
    var tabViewModel: TabViewModel
    var toolbarViewModel: ToolbarViewModel
    var realmModel: RealmModel
    
    var searchNavigationModel: SearchNavigationModel
    var searchViewModel: SearchViewModel
    var searchNavigationController: SearchNavigationController
    var viewController: ListsViewController
    
    init(
        model: ListsViewModel,
        tabViewModel: TabViewModel,
        toolbarViewModel: ToolbarViewModel,
        realmModel: RealmModel
    ) {
        self.model = model
        self.tabViewModel = tabViewModel
        self.toolbarViewModel = toolbarViewModel
        self.realmModel = realmModel
        
        let searchNavigationModel = SearchNavigationModel()
        self.searchNavigationModel = searchNavigationModel
        let searchViewModel = SearchViewModel(configuration: .lists)
        self.searchViewModel = searchViewModel
        
        let storyboard = UIStoryboard(name: "ListsContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "ListsViewController") { coder in
            ListsViewController(
                coder: coder,
                model: model,
                tabViewModel: tabViewModel,
                toolbarViewModel: toolbarViewModel,
                realmModel: realmModel,
                searchViewModel: searchViewModel
            )
        }
        
        self.viewController = viewController
        let searchNavigationController = SearchNavigationController.make(
            rootViewController: viewController,
            searchNavigationModel: searchNavigationModel,
            searchViewModel: searchViewModel,
            realmModel: realmModel,
            tabType: .lists
        )
        
        /// set the details search view model
        searchNavigationModel.onWillBecomeActive = { viewController.willBecomeActive() }
        searchNavigationModel.onDidBecomeActive = { viewController.didBecomeActive() }
        searchNavigationModel.onWillBecomeInactive = { viewController.willBecomeInactive() }
        searchNavigationModel.onDidBecomeInactive = { viewController.didBecomeInactive() }
        searchNavigationModel.onBoundsChange = { size, safeAreaInsets in
            print("boundschanged.")
            viewController.boundsChanged(to: size, safeAreaInsets: safeAreaInsets)
        }
        
        self.searchNavigationController = searchNavigationController
    
        viewController.loadViewIfNeeded() /// needed to initialize outlets
        viewController.updateNavigationBar = { [weak self] in
            guard let self = self else { return }
            self.searchNavigationController.updateSearchBarOffset()
            tabViewModel.excludedFrames[.listsSearchBar] = searchNavigationController.searchContainerView.windowFrame()
        }
    }
}
