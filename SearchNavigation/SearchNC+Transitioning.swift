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
        guard
            let transitionCoordinator = navigation.transitionCoordinator,
            let viewController = viewController as? Searchable,
            currentAnimator == nil
        else { return }
        
        let offset = viewController.baseSearchBarOffset + max(0, viewController.additionalSearchBarOffset ?? 0)
            
        searchContainerViewTopC?.constant = offset
        navigationBarBackgroundHeightC?.constant = offset + searchViewModel.getTotalHeight()
            
        let percentage = getViewControllerBlurPercentage(for: viewController)
        
        /// first reset to start, if there's going to be a change
        if percentage == 0, blurPercentage != 0 {
            self.navigationBarBackgroundBorderView.alpha = 1
            self.navigationBarBackgroundBlurView.effect = SearchNavigationConstants.blurEffect
        } else if percentage == 1, blurPercentage != 1 {
            self.navigationBarBackgroundBorderView.alpha = 0
            self.navigationBarBackgroundBlurView.effect = nil
        }
    
        transitionCoordinator.animate { _ in
            self.searchContainerViewContainer.layoutIfNeeded()
            self.navigationBarBackgroundContainer.layoutIfNeeded()
                
            /// manually animate the line
            if percentage == 0, self.blurPercentage != 0 {
                self.navigationBarBackgroundBorderView.alpha = 0
                self.navigationBarBackgroundBlurView.effect = nil
            } else if percentage == 1, self.blurPercentage != 1 {
                self.navigationBarBackgroundBorderView.alpha = 1
                self.navigationBarBackgroundBlurView.effect = SearchNavigationConstants.blurEffect
            }
        } completion: { context in
                
            /// restart the animator
            self.setupBlur()
                
            if context.isCancelled {
                if let currentViewController = self.navigation.topViewController as? Searchable {
                    let offset = currentViewController.baseSearchBarOffset + max(0, currentViewController.additionalSearchBarOffset ?? 0)
                        
                    self.searchContainerViewTopC?.constant = offset
                    self.navigationBarBackgroundHeightC?.constant = offset + self.searchViewModel.getTotalHeight()
                    self.updateBlur(
                        baseSearchBarOffset: currentViewController.baseSearchBarOffset,
                        additionalSearchBarOffset: currentViewController.additionalSearchBarOffset
                    )
                }
            } else {
                self.updateBlur(
                    baseSearchBarOffset: viewController.baseSearchBarOffset,
                    additionalSearchBarOffset: viewController.additionalSearchBarOffset
                )
            }
        }
    }
}

extension SearchNavigationController {
    func updateSearchBarOffset() {
        if let topViewController = navigation?.topViewController as? Searchable {
            let offset = topViewController.baseSearchBarOffset + max(0, topViewController.additionalSearchBarOffset ?? 0)
            
            searchContainerViewTopC?.constant = offset
            navigationBarBackgroundHeightC?.constant = offset + searchViewModel.getTotalHeight()
            self.updateBlur(
                baseSearchBarOffset: topViewController.baseSearchBarOffset,
                additionalSearchBarOffset: topViewController.additionalSearchBarOffset
            )
        }
    }
    
    /// Make sure that the view controller doesn't have a nil `additionalSearchBarOffset` - in this case, always return 1
    func getViewControllerBlurPercentage(for viewController: Searchable) -> CGFloat {
        let percentage: CGFloat
        if let additionalSearchBarOffset = viewController.additionalSearchBarOffset {
            percentage = self.getBlurPercentage(
                baseSearchBarOffset: viewController.baseSearchBarOffset,
                additionalSearchBarOffset: additionalSearchBarOffset
            )
        } else {
            percentage = 1
        }
        return percentage
    }
    
    /// 0 is nil, 1 is blur
    func getBlurPercentage(baseSearchBarOffset: CGFloat, additionalSearchBarOffset: CGFloat) -> CGFloat {
        /// make sure `additionalSearchBarOffset` is negative (scrolling up)
        guard additionalSearchBarOffset <= 0 else { return 0 }
        
        let percentage = additionalSearchBarOffset / -SearchNavigationConstants.blurFadeRange
        let constrainedPercentage = min(1, percentage)
        return constrainedPercentage
    }
    
    func updateBlur(baseSearchBarOffset: CGFloat, additionalSearchBarOffset: CGFloat?) {
        /// make sure no transition is happening currently
        guard navigation.transitionCoordinator == nil else { return }
        
        if let additionalSearchBarOffset = additionalSearchBarOffset {
            let blurPercentage = self.getBlurPercentage(
                baseSearchBarOffset: baseSearchBarOffset,
                additionalSearchBarOffset: additionalSearchBarOffset
            )
            animator?.fractionComplete = blurPercentage
            self.blurPercentage = blurPercentage
        } else {
            animator?.fractionComplete = 1
            self.blurPercentage = 1
        }
    }
}
