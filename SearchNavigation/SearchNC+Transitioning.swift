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
            let offset = viewController.baseSearchBarOffset + max(0, viewController.additionalSearchBarOffset)
            
            searchContainerViewTopC.constant = offset
            navigationBarBackgroundHeightC.constant = offset + searchConfiguration.getTotalHeight()
            

            let percentage = getBlurPercentage(
                baseSearchBarOffset: viewController.baseSearchBarOffset,
                additionalSearchBarOffset: viewController.additionalSearchBarOffset
            )
            
            if navigation.viewControllers.count < currentViewControllerCount {
                animator?.stopAnimation(false)
                animator?.finishAnimation(at: .end)
            } else {
                /// stop the animator fist
                animator?.stopAnimation(false)
                animator?.finishAnimation(at: .current)
                animator = nil
            }
            
            currentViewControllerCount = navigation.viewControllers.count
            
            transitionCoordinator.animate { _ in
                self.searchContainerViewContainer.layoutIfNeeded()
                self.navigationBarBackgroundContainer.layoutIfNeeded()
                
                /// manually animate the line
                if percentage == 0 {
                    self.navigationBarBackgroundBorderView.alpha = 0
                    self.navigationBarBackgroundBorderView.backgroundColor = .red
                } else if percentage == 1 {
                    self.navigationBarBackgroundBorderView.alpha = 1
                    self.navigationBarBackgroundBorderView.backgroundColor = .green
                }
            } completion: { context in
                
                /// restart the animator
                self.setupBlur()
                
                if context.isCancelled {
                    if let currentViewController = self.navigation.topViewController as? Searchable {
                        let offset = currentViewController.baseSearchBarOffset + max(0, currentViewController.additionalSearchBarOffset)
                        
                        self.searchContainerViewTopC.constant = offset
                        self.navigationBarBackgroundHeightC.constant = offset + self.searchConfiguration.getTotalHeight()
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
}

extension SearchNavigationController {
    func updateSearchBarOffset() {
        if let topViewController = navigation.topViewController as? Searchable {
            let offset = topViewController.baseSearchBarOffset + max(0, topViewController.additionalSearchBarOffset)
            
            searchContainerViewTopC.constant = offset
            navigationBarBackgroundHeightC.constant = offset + searchConfiguration.getTotalHeight()
            updateBlur(
                baseSearchBarOffset: topViewController.baseSearchBarOffset,
                additionalSearchBarOffset: topViewController.additionalSearchBarOffset
            )
        }
    }
    
    /// 0 is nil, 1 is blur
    func getBlurPercentage(baseSearchBarOffset: CGFloat, additionalSearchBarOffset: CGFloat) -> CGFloat {
        
        /// make sure `additionalSearchBarOffset` is negative (scrolling up)
        guard additionalSearchBarOffset <= 0 else { return 0 }
        
        let percentage = additionalSearchBarOffset / -SearchNavigationConstants.blurFadeRange
        let constrainedPercentage = min(1, percentage)
        return constrainedPercentage
    }
    
    func updateBlur(baseSearchBarOffset: CGFloat, additionalSearchBarOffset: CGFloat) {
        let blurPercentage = getBlurPercentage(
            baseSearchBarOffset: baseSearchBarOffset,
            additionalSearchBarOffset: additionalSearchBarOffset
        )
        animator?.fractionComplete = blurPercentage
        self.blurPercentage = blurPercentage
    }
}
