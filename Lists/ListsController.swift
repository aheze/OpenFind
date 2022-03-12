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
    var detailsSearchViewModel: SearchViewModel
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
        let detailsSearchViewModel = SearchViewModel(configuration: .lists)
        self.detailsSearchViewModel = detailsSearchViewModel
        
        let storyboard = UIStoryboard(name: "ListsContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "ListsViewController") { coder in
            ListsViewController(
                coder: coder,
                model: model,
                tabViewModel: tabViewModel,
                toolbarViewModel: toolbarViewModel,
                realmModel: realmModel,
                searchViewModel: searchViewModel,
                detailsSearchViewModel: detailsSearchViewModel
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
        searchNavigationController.detailsSearchViewModel = detailsSearchViewModel
        searchNavigationModel.onWillBecomeActive = { viewController.willBecomeActive() }
        searchNavigationModel.onDidBecomeActive = { viewController.didBecomeActive() }
        searchNavigationModel.onWillBecomeInactive = { viewController.willBecomeInactive() }
        searchNavigationModel.onDidBecomeInactive = { viewController.didBecomeInactive() }
        searchNavigationModel.onBoundsChange = { size, safeAreaInsets in
            viewController.boundsChanged(to: size, safeAreaInsets: safeAreaInsets)
        }
        
        self.searchNavigationController = searchNavigationController
    
        viewController.loadViewIfNeeded() /// needed to initialize outlets
        viewController.updateNavigationBar = { [weak self] in
            guard let self = self else { return }
            self.searchNavigationController.updateSearchBarOffset()
            tabViewModel.excludedFrames[.listsSearchBar] = searchNavigationController.searchContainerView.windowFrame()
        }
        
        configureTransitions(for: searchNavigationController)
    }
}

extension ListsController {
    func configureTransitions(for searchNavigationController: SearchNavigationController) {
        model.updateDetailsSearchCollectionView = {
            /// reload the details search bar.
            searchNavigationController.detailsSearchViewController?.collectionViewModel.replaceInPlace(
                with: searchNavigationController.searchViewController.collectionViewModel
            )
            
            /// update the focused index.
            searchNavigationController.detailsSearchViewController?.collectionViewModel.focusedCellIndex = searchNavigationController.searchViewController?.collectionViewModel.focusedCellIndex
            
            /// reload the collection view.
            searchNavigationController.detailsSearchViewController?.reload()
        }
    }
}
