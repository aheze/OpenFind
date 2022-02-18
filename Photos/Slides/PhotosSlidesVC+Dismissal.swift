//
//  PhotosSlidesVC+Dismissal.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/18/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension PhotosSlidesViewController {
    func setupDismissGesture() {
        self.view.addGestureRecognizer(self.dismissPanGesture)
        self.dismissPanGesture.addTarget(self, action: #selector(self.dismissPanGestureDidChange(_:)))
    }

    @objc func dismissPanGestureDidChange(_ gesture: UIPanGestureRecognizer) {
        // Decide whether we're interactively-dismissing, and notify our navigation controller.
        switch gesture.state {
        case .began:
            self.isInteractivelyDismissing = true
            self.navigationController?.popViewController(animated: true)
        case .cancelled, .failed, .ended:
            self.isInteractivelyDismissing = false
        case .changed, .possible:
            break
        @unknown default:
            break
        }

        // We want to update our transition controller, too!
        self.transitionAnimator?.didPanWith(gestureRecognizer: gesture)
    }
}
