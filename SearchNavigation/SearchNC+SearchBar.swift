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
        view.addSubview(searchContainerViewContainer)
        searchContainerViewContainer.pinEdgesToSuperview()
        
        let searchContainerView = UIView()
        self.searchContainerView = searchContainerView
        searchContainerView.backgroundColor = .clear
        searchContainerViewContainer.addSubview(searchContainerView)
        
        let searchContainerViewTopC = searchContainerView.topAnchor.constraint(equalTo: searchContainerViewContainer.topAnchor, constant: 0)
        self.searchContainerViewTopC = searchContainerViewTopC
        searchContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchContainerView.leftAnchor.constraint(equalTo: searchContainerViewContainer.leftAnchor),
            searchContainerView.rightAnchor.constraint(equalTo: searchContainerViewContainer.rightAnchor),
            searchContainerViewTopC
        ])
        
        /// standard search bar
        let searchViewController = SearchViewController.make(searchViewModel: searchViewModel, realmModel: realmModel)
        self.searchViewController = searchViewController
        addResizableChildViewController(searchViewController, in: searchContainerView)
        
        /// search bar for details/slides
        if let detailsSearchViewModel = detailsSearchViewModel {
            let detailsSearchViewController = SearchViewController.make(searchViewModel: detailsSearchViewModel, realmModel: realmModel)
            self.detailsSearchViewController = detailsSearchViewController
            addResizableChildViewController(detailsSearchViewController, in: searchContainerView)
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
