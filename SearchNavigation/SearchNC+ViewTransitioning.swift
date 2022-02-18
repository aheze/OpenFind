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
