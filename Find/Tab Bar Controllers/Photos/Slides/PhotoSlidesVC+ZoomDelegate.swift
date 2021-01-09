//
//  PhotoSlidesVC+ZoomDelegate.swift
//  Find
//
//  Created by Zheng on 1/8/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import AVFoundation

extension PhotoSlidesViewController: ZoomAnimatorDelegate {

    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {
    }

    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {
    }

    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView? {
        return currentViewController.imageView
    }

    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect? {
        if
            let imageView = currentViewController.imageView,
            let image = imageView.image
        {
            let aspectFrame = AVMakeRect(aspectRatio: image.size, insideRect: imageView.frame)
            return currentViewController.scrollView.convert(aspectFrame, to: currentViewController.view)
        }
        return currentViewController.scrollView.convert(currentViewController.imageView.frame, to: currentViewController.view)
    }
}
