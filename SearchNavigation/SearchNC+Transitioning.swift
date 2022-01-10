//
//  SearchNC+Transitioning.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/10/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//


import UIKit

extension SearchNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if
            let transitionCoordinator = navigation.transitionCoordinator,
            let topViewController = navigation.topViewController as? Searchable
        {
            searchContainerViewTopC.constant = topViewController.searchBarOffset
            navigationBarBackgroundHeightC.constant = topViewController.searchBarOffset + searchConfiguration.getTotalHeight()
            transitionCoordinator.animate { _ in
                self.searchContainerViewContainer.layoutIfNeeded()
                self.navigationBarBackgroundContainer.layoutIfNeeded()
                self.updateBlur(searchBarOffset: topViewController.searchBarOffset)
            }
        }
    }
}

extension SearchNavigationController {
    func updateSearchBarOffset() {
        if let topViewController = navigation.topViewController as? Searchable {
            searchContainerViewTopC.constant = topViewController.searchBarOffset
            navigationBarBackgroundHeightC.constant = topViewController.searchBarOffset + searchConfiguration.getTotalHeight()
            updateBlur(searchBarOffset: topViewController.searchBarOffset)
        }
    }
}
