//
//  PhotoSlidesVC+ZoomDelegate.swift
//  Find
//
//  Created by Zheng on 1/8/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotoSlidesViewController: ZoomAnimatorDelegate {

    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {
        print("starting")
    }

    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {
        print("ending")
    }

    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView? {
        print("ref")
        print("ref, cur: \(currentViewController)")
        return currentViewController.imageView
    }

    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect? {
        print("trans")
        return currentViewController.scrollView.convert(currentViewController.contentView.frame, to: currentViewController.view)
    }
}
