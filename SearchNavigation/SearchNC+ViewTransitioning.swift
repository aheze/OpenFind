//
//  SearchNC+ViewTransitioning.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

/// default push/pop
extension SearchNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard
            let transitionCoordinator = navigation.transitionCoordinator,
            let viewController = viewController as? Searchable,
            currentAnimator == nil
        else { return }
        
        let targetPercentage = getViewControllerBlurPercentage(for: viewController)
        beginSearchBarTransitionAnimation(to: viewController, targetPercentage: targetPercentage)
    
        transitionCoordinator.animate { _ in
            self.continueSearchBarTransitionAnimation(targetPercentage: targetPercentage)
            
            /// check if is presenting
            if let namedViewController = viewController as? NavigationNamed, namedViewController.name == .listsDetail {
                self.showDetailsSearchBar(true)
            } else {
                self.showDetailsSearchBar(false)
            }
        } completion: { context in
                
            /// restart the animator
            self.setupBlur()
                
            if context.isCancelled {
                self.cancelSearchBarPopAnimation()
            } else {
                self.finishSearchBarTransitionAnimation(to: viewController)
            }
        }
    }
}

/// animations
extension SearchNavigationController {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        var animator: UIViewControllerAnimatedTransitioning?

        switch operation {
        case .push:
            animator = pushAnimator
        case .pop:
            if let slidesViewController = fromVC as? InteractivelyDismissible, slidesViewController.isInteractivelyDismissing {
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
        if viewController.showSearchBar {
            searchContainerViewLeftC?.constant = 0
        } else {
            searchContainerViewLeftC?.constant = -searchContainerView.bounds.width
        }
        
        let searchBarOffset = viewController.baseSearchBarOffset + max(0, viewController.additionalSearchBarOffset ?? 0)
        let searchBarHeight = viewController.showSearchBar ? searchViewModel.getTotalHeight() : 0
        let promptOffset = searchBarOffset + searchBarHeight
        let promptHeight = self.getAdditionalSearchPromptHeight(for: viewController)
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
            let searchBarHeight = currentViewController.showSearchBar ? searchViewModel.getTotalHeight() : 0
            self.navigationBarBackgroundHeightC?.constant = offset + searchBarHeight
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
        let searchBarHeightFrom = from.showSearchBar ? searchViewModel.getTotalHeight() : 0
        let promptOffsetFrom = searchBarOffsetFrom + searchBarHeightFrom
        let promptHeightFrom = self.getAdditionalSearchPromptHeight(for: from)
        let barHeightFrom = promptOffsetFrom + promptHeightFrom
        
        let searchBarOffsetTo = to.baseSearchBarOffset + max(0, to.additionalSearchBarOffset ?? 0)
        let searchBarHeightTo = to.showSearchBar ? searchViewModel.getTotalHeight() : 0
        let promptOffsetTo = searchBarOffsetTo + searchBarHeightTo
        let promptHeightTo = self.getAdditionalSearchPromptHeight(for: to)
        let barHeightTo = promptOffsetTo + promptHeightTo
        
        let searchBarOffset = AnimatableUtilities.mixedValue(from: searchBarOffsetFrom, to: searchBarOffsetTo, progress: percentage)
        let promptOffset = AnimatableUtilities.mixedValue(from: promptOffsetFrom, to: promptOffsetTo, progress: percentage)
        let promptHeight = AnimatableUtilities.mixedValue(from: promptHeightFrom, to: promptHeightTo, progress: percentage)
        let barHeight = AnimatableUtilities.mixedValue(from: barHeightFrom, to: barHeightTo, progress: percentage)
        
        /// vertical offset
        searchContainerViewTopC?.constant = searchBarOffset
        detailsSearchPromptViewContainerTopC?.constant = promptOffset
        detailsSearchPromptViewContainerHeightC?.constant = promptHeight
        navigationBarBackgroundHeightC?.constant = barHeight
        
        /// search bar hiding
        let toLeftOffset = to.showSearchBar ? 0 : -searchContainerView.bounds.width
        let leftOffset = AnimatableUtilities.mixedValue(from: 0, to: toLeftOffset, progress: percentage)
        searchContainerViewLeftC?.constant = leftOffset
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
