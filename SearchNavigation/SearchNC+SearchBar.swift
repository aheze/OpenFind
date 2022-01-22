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
        
    
        navigation.view.addSubview(searchContainerViewContainer)
        searchContainerViewContainer.pinEdgesToSuperview()
        
        let searchContainerView = UIView()
        self.searchContainerView = searchContainerView
        searchContainerViewContainer.addSubview(searchContainerView)
        
        let searchContainerViewTopC = searchContainerView.topAnchor.constraint(equalTo: searchContainerViewContainer.topAnchor, constant: 0)
        self.searchContainerViewTopC = searchContainerViewTopC
        searchContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchContainerView.leftAnchor.constraint(equalTo: searchContainerViewContainer.leftAnchor),
            searchContainerView.rightAnchor.constraint(equalTo: searchContainerViewContainer.rightAnchor),
            searchContainerViewTopC
        ])
        
        searchContainerView.backgroundColor = .clear
        
        let searchViewController = Bridge.makeViewController(
            searchViewModel: searchViewModel,
            configuration: searchConfiguration
        )
        addResizableChildViewController(searchViewController, in: searchContainerView)
        
        
    }
}
