//
//  ListsController.swift
//  Lists
//
//  Created by Zheng on 11/18/21.
//

import UIKit

class ListsController {
    var model: ListsViewModel
    var toolbarViewModel: ToolbarViewModel
    var realmModel: RealmModel
    
    var searchViewModel: SearchViewModel
    var detailsSearchViewModel: SearchViewModel
    var searchNavigationController: SearchNavigationController
    var viewController: ListsViewController
    
    init(model: ListsViewModel, toolbarViewModel: ToolbarViewModel, realmModel: RealmModel) {
        self.model = model
        self.toolbarViewModel = toolbarViewModel
        self.realmModel = realmModel
        
        let searchViewModel = SearchViewModel(configuration: .lists)
        self.searchViewModel = searchViewModel
        let detailsSearchViewModel = SearchViewModel(configuration: .lists)
        self.detailsSearchViewModel = detailsSearchViewModel
        
        let storyboard = UIStoryboard(name: "ListsContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "ListsViewController") { coder in
            ListsViewController(
                coder: coder,
                model: model,
                toolbarViewModel: toolbarViewModel,
                realmModel: realmModel,
                searchViewModel: searchViewModel,
                detailsSearchViewModel: detailsSearchViewModel
            )
        }
        
        self.viewController = viewController
        let searchNavigationController = SearchNavigationController.make(
            rootViewController: viewController,
            searchViewModel: searchViewModel,
            realmModel: realmModel,
            tabType: .lists
        )
        
        /// set the details search view model
        searchNavigationController.detailsSearchViewModel = detailsSearchViewModel
        searchNavigationController.onWillBecomeActive = { viewController.willBecomeActive() }
        searchNavigationController.onDidBecomeActive = { viewController.didBecomeActive() }
        searchNavigationController.onWillBecomeInactive = { viewController.willBecomeInactive() }
        searchNavigationController.onDidBecomeInactive = { viewController.didBecomeInactive() }
        searchNavigationController.onBoundsChange = { size, safeAreaInsets in
            viewController.boundsChanged(to: size, safeAreaInsets: safeAreaInsets)
        }
        
        self.searchNavigationController = searchNavigationController
    
        viewController.loadViewIfNeeded() /// needed to initialize outlets
        viewController.updateNavigationBar = { [weak self] in
            guard let self = self else { return }
            self.searchNavigationController.updateSearchBarOffset()
            Tab.Frames.excluded[.listsSearchBar] = searchNavigationController.searchContainerView.windowFrame()
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
