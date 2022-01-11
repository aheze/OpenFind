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
            let viewController = viewController as? Searchable
        {
            searchContainerViewTopC.constant = viewController.searchBarOffset
            navigationBarBackgroundHeightC.constant = viewController.searchBarOffset + searchConfiguration.getTotalHeight()
            
            /// stop the animator fist
            animator?.stopAnimation(false)
            animator?.finishAnimation(at: .current)
            animator = nil

            
            let percentage = getBlurPercentage(for: viewController.searchBarOffset)
            
            transitionCoordinator.animate { _ in
                self.searchContainerViewContainer.layoutIfNeeded()
                self.navigationBarBackgroundContainer.layoutIfNeeded()
                
                /// manually animate the line
                if percentage == 0 {
                    self.navigationBarBackgroundBorderView.alpha = 0
                } else if percentage == 1 {
                    self.navigationBarBackgroundBorderView.alpha = 1
                }
            } completion: { context in
                
                /// restart the animator
                self.setupBlur()
                
                if context.isCancelled {
                    if let currentViewController = self.navigation.topViewController as? Searchable {
                        self.searchContainerViewTopC.constant = currentViewController.searchBarOffset
                        self.navigationBarBackgroundHeightC.constant = currentViewController.searchBarOffset + self.searchConfiguration.getTotalHeight()
                        self.updateBlur(for: currentViewController.searchBarOffset)
                    }
                } else {
                    self.updateBlur(for: viewController.searchBarOffset)
                }
            }
        }
    }
}

extension SearchNavigationController {
    func updateSearchBarOffset() {
        if let topViewController = navigation.topViewController as? Searchable {
            searchContainerViewTopC.constant = topViewController.searchBarOffset
            navigationBarBackgroundHeightC.constant = topViewController.searchBarOffset + searchConfiguration.getTotalHeight()
            updateBlur(for: topViewController.searchBarOffset)
        }
    }
    
    /// 0 is nil, 1 is blur
    func getBlurPercentage(for searchBarOffset: CGFloat) -> CGFloat {
        let navigationBar = navigation.navigationBar
        
        if let window = UIApplication.shared.keyWindow {
            let compactHeight = navigationBar.getCompactHeight() // 44 on iPhone 11
            let statusBarHeight = window.safeAreaInsets.top // 44 on iPhone 11
            let targetOffset = compactHeight + statusBarHeight /// the smallest search bar offset
            
            let difference = max(0, searchBarOffset - targetOffset)
            
            if difference < SearchNavigationConstants.blurFadeRange {
                let percentage = 1 - difference / SearchNavigationConstants.blurFadeRange
                return percentage
            }
        }
        return 0
    }
    
    func updateBlur(for searchBarOffset: CGFloat) {
        let blurPercentage = getBlurPercentage(for: searchBarOffset)
        animator?.fractionComplete = blurPercentage
        self.blurPercentage = blurPercentage
    }
}
