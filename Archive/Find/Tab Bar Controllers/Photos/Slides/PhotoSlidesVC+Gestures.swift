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
        if cameFromFind {
            transitionController.animator.cameFromFind = true
        }
        
        switch gestureRecognizer.state {
        case .began:
            currentViewController.scrollView.isScrollEnabled = false
            transitionController.isInteractive = true
            
            if cameFromFind {
                dismiss(animated: true, completion: nil)
            } else {
                _ = navigationController?.popViewController(animated: true)
            }
            
        case .ended:
            if transitionController.isInteractive {
                currentViewController.scrollView.isScrollEnabled = true
                transitionController.isInteractive = false
                transitionController.didPanWith(gestureRecognizer: gestureRecognizer)
            }
        default:
            if transitionController.isInteractive {
                transitionController.didPanWith(gestureRecognizer: gestureRecognizer)
            }
        }
    }

    @objc func didSingleTapWith(gestureRecognizer: UITapGestureRecognizer) {
        if !UIAccessibility.isVoiceOverRunning {
            if currentScreenMode == .full {
                changeScreenMode(to: .normal)
                currentScreenMode = .normal
            } else {
                changeScreenMode(to: .full)
                currentScreenMode = .full
            }
        }
    }
}

/// Determine cancellation / recognize at same time
extension PhotoSlidesViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = gestureRecognizer.velocity(in: view)
            
            var velocityCheck = false
            
            if UIWindow.currentInterfaceOrientation?.isLandscape ?? false {
                velocityCheck = velocity.x < 0
            } else {
                velocityCheck = velocity.y < 0
            }
            if velocityCheck {
                return false
            }
        }
        
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer == currentViewController.scrollView.panGestureRecognizer {
            if currentViewController.scrollView.contentOffset.y == 0 {
                return true
            }
        }
        
        return false
    }
}

extension UIWindow {
    static var currentInterfaceOrientation: UIInterfaceOrientation? {
        return UIApplication.shared.windows
            .first?
            .windowScene?
            .interfaceOrientation
    }
}
