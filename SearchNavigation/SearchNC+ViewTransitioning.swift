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
                let slidesViewController = fromVC as? InteractivelyDismissible,
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
        let searchBarOffset = viewController.baseSearchBarOffset + max(0, viewController.additionalSearchBarOffset ?? 0)
        let promptOffset = searchBarOffset + searchViewModel.getTotalHeight()
        let promptHeight = getAdditionalSearchPromptHeight(for: viewController)
        let barHeight = promptOffset + promptHeight
        
        searchContainerViewTopC?.constant = searchBarOffset
        detailsSearchPromptViewContainerTopC?.constant = promptOffset
        detailsSearchPromptViewContainerHeightC?.constant = promptHeight
        navigationBarBackgroundHeightC?.constant = barHeight
        
        
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
            var offset = currentViewController.baseSearchBarOffset + max(0, currentViewController.additionalSearchBarOffset ?? 0)
                
            self.searchContainerViewTopC?.constant = offset
            
            offset += self.getAdditionalSearchPromptHeight(for: currentViewController)
            
            self.navigationBarBackgroundHeightC?.constant = offset + self.searchViewModel.getTotalHeight()
            self.updateBlur(
                baseSearchBarOffset: currentViewController.baseSearchBarOffset,
                additionalSearchBarOffset: currentViewController.additionalSearchBarOffset
            )
        }
    }
    
    // MARK: - Convenience methods for interactive dismissal
    
    /// from = top view controller, to == original view controller
    func setOffset(from: Searchable, to: Searchable, percentage: CGFloat) {
        let searchBarOffsetFrom = from.baseSearchBarOffset + max(0, from.additionalSearchBarOffset ?? 0)
        let promptOffsetFrom = searchBarOffsetFrom + searchViewModel.getTotalHeight()
        let promptHeightFrom = getAdditionalSearchPromptHeight(for: from)
        let barHeightFrom = promptOffsetFrom + promptHeightFrom
        
        let searchBarOffsetTo = to.baseSearchBarOffset + max(0, to.additionalSearchBarOffset ?? 0)
        let promptOffsetTo = searchBarOffsetTo + searchViewModel.getTotalHeight()
        let promptHeightTo = getAdditionalSearchPromptHeight(for: to)
        let barHeightTo = promptOffsetTo + promptHeightTo
        
        let searchBarOffset = AnimatableUtilities.mixedValue(from: searchBarOffsetFrom, to: searchBarOffsetTo, progress: percentage)
        let promptOffset = AnimatableUtilities.mixedValue(from: promptOffsetFrom, to: promptOffsetTo, progress: percentage)
        let promptHeight = AnimatableUtilities.mixedValue(from: promptHeightFrom, to: promptHeightTo, progress: percentage)
        let barHeight = AnimatableUtilities.mixedValue(from: barHeightFrom, to: barHeightTo, progress: percentage)
        
        searchContainerViewTopC?.constant = searchBarOffset
        detailsSearchPromptViewContainerTopC?.constant = promptOffset
        detailsSearchPromptViewContainerHeightC?.constant = promptHeight
        navigationBarBackgroundHeightC?.constant = barHeight
        
//        
//        
//        var fromOffset = from.baseSearchBarOffset + max(0, from.additionalSearchBarOffset ?? 0)
//        let toOffset = to.baseSearchBarOffset + max(0, to.additionalSearchBarOffset ?? 0)
//        
//        let offset = fromOffset + (toOffset - fromOffset) * percentage
//        searchContainerViewTopC?.constant = offset
//        
//        /// navigation bar height
//        fromOffset += self.getAdditionalSearchPromptHeight(for: from)
//        /// recalculate
//        let barHeight = fromOffset + (toOffset - fromOffset) * percentage
//        navigationBarBackgroundHeightC?.constant = barHeight + searchViewModel.getTotalHeight()
    }
    
    func setBlur(from: Searchable, to: Searchable, percentage: CGFloat) {
        let fromBlurPercentage = getViewControllerBlurPercentage(for: from)
        let toBlurPercentage = getViewControllerBlurPercentage(for: to)
        
        let blurPercentage = fromBlurPercentage + (toBlurPercentage - fromBlurPercentage) * percentage
        updateBlur(to: blurPercentage)
    }
    
    func getAdditionalSearchPromptHeight(for toViewController: Searchable) -> CGFloat {
        var additionalBarHeight = CGFloat(0)
        if
            let detailsSearchPromptViewModel = detailsSearchPromptViewModel,
            detailsSearchPromptViewModel.show,
            let toViewController = toViewController as? NavigationNamed,
            toViewController.name == .photosDetail || toViewController.name == .listsDetail
        {
            additionalBarHeight = detailsSearchPromptViewModel.height()
        }
        return additionalBarHeight
    }
}
