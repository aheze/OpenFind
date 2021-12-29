//
//  ZoomTransitionController.swift
//  FluidPhoto
//
//  Created by Masamichi Ueta on 2016/12/29.
//  Copyright © 2016 Masmichi Ueta. All rights reserved.
//

import UIKit

class ZoomTransitionController: NSObject {
    let animator: ZoomAnimator
    let interactionController: ZoomDismissalInteractionController
    var isInteractive: Bool = false

    weak var fromDelegate: ZoomAnimatorDelegate?
    weak var toDelegate: ZoomAnimatorDelegate?
    
    override init() {
        animator = ZoomAnimator()
        interactionController = ZoomDismissalInteractionController()
        super.init()
    }
    
    func didPanWith(gestureRecognizer: UIPanGestureRecognizer) {
        interactionController.didPanWith(gestureRecognizer: gestureRecognizer)
    }
}

extension ZoomTransitionController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.isPresenting = true
        animator.fromDelegate = fromDelegate
        animator.toDelegate = toDelegate
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.isPresenting = false
        let tmp = fromDelegate
        animator.fromDelegate = toDelegate
        animator.toDelegate = tmp
        return animator
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if !isInteractive {
            return nil
        }
        
        interactionController.animator = animator
        return interactionController
    }
}

extension ZoomTransitionController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            animator.isPresenting = true
            animator.fromDelegate = fromDelegate
            animator.toDelegate = toDelegate
        } else {
            animator.isPresenting = false
            let tmp = fromDelegate
            animator.fromDelegate = toDelegate
            animator.toDelegate = tmp
        }
        
        return animator
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if !isInteractive {
            return nil
        }
        
        interactionController.animator = animator
        return interactionController
    }
}

// class ZoomTransitionController: NSObject {
//
//    let animator: ZoomAnimator
//    let interactionController: ZoomDismissalInteractionController
//    var isInteractive: Bool = false
//    var deletedLast: Bool = false
//
//    weak var fromDelegate: ZoomAnimatorDelegate?
//    weak var toDelegate: ZoomAnimatorDelegate?
//    weak var deleteLastDel: RecieveDeleteLast?
//
//    override init() {
//        animator = ZoomAnimator()
//        interactionController = ZoomDismissalInteractionController()
//        super.init()
//    }
//
//    func didPanWith(gestureRecognizer: UIPanGestureRecognizer) {
//        self.interactionController.didPanWith(gestureRecognizer: gestureRecognizer)
//    }
// }
//
// extension ZoomTransitionController: UIViewControllerTransitioningDelegate {
//    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        self.animator.isPresenting = true
//        self.animator.fromDelegate = fromDelegate
//        self.animator.toDelegate = toDelegate
//
//        deleteLastDel = self.animator
//        return self.animator
//    }
//
//    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        self.animator.isPresenting = false
//        let tmp = self.fromDelegate
//        self.animator.fromDelegate = self.toDelegate
//        self.animator.toDelegate = tmp
//
//        return self.animator
//    }
//
//    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//
//        if deletedLast {
//            deleteLastDel?.deletedLastPhoto()
//        }
//        if !self.isInteractive || self.deletedLast {
//            return nil
//        }
//
//        self.interactionController.animator = animator
//        return self.interactionController
//    }
//
// }
