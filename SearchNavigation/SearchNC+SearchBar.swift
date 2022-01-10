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
        let searchViewController = Bridge.makeViewController(
            searchViewModel: searchViewModel,
            configuration: searchConfiguration
        )
        
        let searchContainerView = UIView()
        self.searchContainerView = searchContainerView
        navigation.view.addSubview(searchContainerView)
//        searchContainerView.pinEdgesToSuperview()
        
        let searchContainerViewTopC = searchContainerView.topAnchor.constraint(equalTo: navigation.view.topAnchor, constant: 0)
        self.searchContainerViewTopC = searchContainerViewTopC
        searchContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchContainerView.leftAnchor.constraint(equalTo: navigation.view.leftAnchor),
            searchContainerView.rightAnchor.constraint(equalTo: navigation.view.rightAnchor),
            searchContainerViewTopC
        ])
        
        
        searchContainerView.backgroundColor = .red
        
        searchContainerView.backgroundColor = .clear
        addResizableChildViewController(searchViewController, in: searchContainerView)
//        searchContainerViewTopC.constant = searchBarOffset
//        view.bringSubviewToFront(searchContainerView)
        
    }
}
