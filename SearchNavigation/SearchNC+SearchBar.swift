//
//  SearchNC+SearchBar.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/9/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

extension SearchNavigationController {
    func setupSearchBar() {
        
        // MARK: Setup container view
        
        view.addSubview(searchContainerViewContainer)
        if let topConstraint = searchContainerViewContainer.pinEdgesToSuperviewAndReturnTopConstraint() {
            searchContainerViewContainerTopC = topConstraint
        }
        
        let searchContainerView = UIView()
        searchContainerView.backgroundColor = .clear
        searchContainerViewContainer.addSubview(searchContainerView)
        self.searchContainerView = searchContainerView
        
        let searchContainerViewTopC = searchContainerView.topAnchor.constraint(equalTo: searchContainerViewContainer.topAnchor, constant: 0)
        let searchContainerViewLeftC = searchContainerView.leftAnchor.constraint(equalTo: searchContainerViewContainer.leftAnchor)
        searchContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchContainerViewTopC,
            searchContainerViewLeftC,
            searchContainerView.widthAnchor.constraint(equalTo: searchContainerViewContainer.widthAnchor),
        ])
        self.searchContainerViewTopC = searchContainerViewTopC
        self.searchContainerViewLeftC = searchContainerViewLeftC
        
        // MARK: Add search collection views
        
        /// standard search bar
        let searchViewController = SearchViewController.make(searchViewModel: searchViewModel, realmModel: realmModel)
        addResizableChildViewController(searchViewController, in: searchContainerView)
        self.searchViewController = searchViewController
        
        /// search bar for details/slides
        if let detailsSearchViewModel = detailsSearchViewModel {
            let detailsSearchViewController = SearchViewController.make(searchViewModel: detailsSearchViewModel, realmModel: realmModel)
            addResizableChildViewController(detailsSearchViewController, in: searchContainerView)
            self.detailsSearchViewController = detailsSearchViewController
        }
        
        showDetailsSearchBar(false)
    }
    
    func showDetailsSearchBar(_ show: Bool) {
        if show {
            detailsSearchViewController?.view.alpha = 1
            searchViewController.view.alpha = 0
        } else {
            detailsSearchViewController?.view.alpha = 0
            searchViewController.view.alpha = 1
        }
    }
    
    /// 0 = hide, 1 = show
    func adjustShowingDetailsSearchBar(percentage: CGFloat) {
        detailsSearchViewController?.view.alpha = percentage
        searchViewController.view.alpha = 1 - percentage
    }
}
