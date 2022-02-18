//
//  SearchNC+ViewTransitioning.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension SearchNavigationController {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        var animator: UIViewControllerAnimatedTransitioning?

        switch operation {
        case .push:
            animator = pushAnimator
        case .pop:
            if
                let slidesViewController = fromVC as? PhotosSlidesViewController,
                slidesViewController.isInteractivelyDismissing
            {
                animator = dismissAnimator
            } else {
                animator = popAnimator
            }
        default:
            break
        }

        self.currentAnimator = animator
        return animator
    }

    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.currentAnimator as? UIViewControllerInteractiveTransitioning
    }
}

extension SearchNavigationController {
    func beginSearchBarTransitionAnimation(to viewController: Searchable, targetPercentage: CGFloat) {
        let offset = viewController.baseSearchBarOffset + max(0, viewController.additionalSearchBarOffset ?? 0)
            
        searchContainerViewTopC?.constant = offset
        navigationBarBackgroundHeightC?.constant = offset + searchViewModel.getTotalHeight()
        
        /// first reset to start, if there's going to be a change
        if targetPercentage == 0, blurPercentage != 0 {
            self.navigationBarBackgroundBorderView.alpha = 1
            self.navigationBarBackgroundBlurView.effect = SearchNavigationConstants.blurEffect
        } else if targetPercentage == 1, blurPercentage != 1 {
            self.navigationBarBackgroundBorderView.alpha = 0
            self.navigationBarBackgroundBlurView.effect = nil
        }
    }
    
    func continueSearchBarTransitionAnimation(targetPercentage: CGFloat) {
        self.searchContainerViewContainer.layoutIfNeeded()
        self.navigationBarBackgroundContainer.layoutIfNeeded()
            
        /// manually animate the line
        if targetPercentage == 0, self.blurPercentage != 0 {
            self.navigationBarBackgroundBorderView.alpha = 0
            self.navigationBarBackgroundBlurView.effect = nil
        } else if targetPercentage == 1, self.blurPercentage != 1 {
            self.navigationBarBackgroundBorderView.alpha = 1
            self.navigationBarBackgroundBlurView.effect = SearchNavigationConstants.blurEffect
        }
    }
    
    func finishSearchBarTransitionAnimation(to viewController: Searchable) {
        /// restart the animator
        self.setupBlur()
        
        self.updateBlur(
            baseSearchBarOffset: viewController.baseSearchBarOffset,
            additionalSearchBarOffset: viewController.additionalSearchBarOffset
        )
    }
    
    func cancelSearchBarPopAnimation() {
        if let currentViewController = self.navigation.topViewController as? Searchable {
            let offset = currentViewController.baseSearchBarOffset + max(0, currentViewController.additionalSearchBarOffset ?? 0)
                
            self.searchContainerViewTopC?.constant = offset
            self.navigationBarBackgroundHeightC?.constant = offset + self.searchViewModel.getTotalHeight()
            self.updateBlur(
                baseSearchBarOffset: currentViewController.baseSearchBarOffset,
                additionalSearchBarOffset: currentViewController.additionalSearchBarOffset
            )
        }
    }
    
    // MARK: - Convenience methods for interactive dismissal
    
    func setOffset(from: Searchable, to: Searchable, percentage: CGFloat) {
        let fromOffset = from.baseSearchBarOffset + max(0, from.additionalSearchBarOffset ?? 0)
        let toOffset = to.baseSearchBarOffset + max(0, to.additionalSearchBarOffset ?? 0)
        
        let offset = fromOffset + (toOffset - fromOffset) * percentage
        searchContainerViewTopC?.constant = offset
        navigationBarBackgroundHeightC?.constant = offset + searchViewModel.getTotalHeight()
    }
    
    func setBlur(from: Searchable, to: Searchable, percentage: CGFloat) {
        let fromBlurPercentage = getViewControllerBlurPercentage(for: from)
        let toBlurPercentage = getViewControllerBlurPercentage(for: to)
        
        let blurPercentage = fromBlurPercentage + (toBlurPercentage - fromBlurPercentage) * percentage
        updateBlur(to: blurPercentage)
    }
}
