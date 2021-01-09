//
//  PhotoSlidesVC+Gestures.swift
//  Find
//
//  Created by Zheng on 1/9/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

/// Handle gestures
extension PhotoSlidesViewController {
    @objc func didPanWith(gestureRecognizer: UIPanGestureRecognizer) {
        print("did pan")
        switch gestureRecognizer.state {
        case .began:
            self.currentViewController.scrollView.isScrollEnabled = false
            self.transitionController.isInteractive = true
            self.dismiss(animated: true, completion: nil)
        case .ended:
            if self.transitionController.isInteractive {
                self.currentViewController.scrollView.isScrollEnabled = true
                self.transitionController.isInteractive = false
                self.transitionController.didPanWith(gestureRecognizer: gestureRecognizer)
            }
        default:
            if self.transitionController.isInteractive {
                self.transitionController.didPanWith(gestureRecognizer: gestureRecognizer)
            }
        }
    }
}

/// Determine cancellation / recognize at same time
extension PhotoSlidesViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = gestureRecognizer.velocity(in: self.view)
            
            var velocityCheck : Bool = false
            
            if UIDevice.current.orientation.isLandscape {
                velocityCheck = velocity.x < 0
            }
            else {
                velocityCheck = velocity.y < 0
            }
            if velocityCheck {
                return false
            }
        }
        
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer == self.currentViewController.scrollView.panGestureRecognizer {
            if self.currentViewController.scrollView.contentOffset.y == 0 {
                return true
            }
        }
        
        return false
    }
}
