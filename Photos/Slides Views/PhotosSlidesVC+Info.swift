//
//  PhotosSlidesVC+Info.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension PhotosSlidesViewController {
    func setupInfo() {
        let viewController = PhotosSlidesInfoViewController(model: model)
        addChildViewController(viewController, in: infoViewContainer)
    }

    func getInfoHeight() -> CGFloat {
        let height = PhotosSlidesConstants.infoHeightPercentageOfScreen * view.bounds.height
        return height
    }

    func showInfo(_ show: Bool) {
        var offset: CGFloat
        if show {
            infoViewContainerHeightC.constant = getInfoHeight()
            dismissPanGesture.isEnabled = false
            scrollView.alwaysBounceVertical = true
            offset = getInfoHeight()
        } else {
            resetInfoToHidden()
            offset = 0
        }

        UIView.animate(duration: 0.6, dampingFraction: 1) {
            self.scrollView.contentOffset = CGPoint(x: 0, y: offset)

            /// don't also call `self.flowLayout.invalidateLayout()`, otherwise there will be a glitch
            /// `currentViewController.setAspectRatio(scaleToFill: show)` also seems to be automatically animated
            self.scrollView.layoutIfNeeded()
        }
    }

    /// set constraints to 0
    func resetInfoToHidden() {
        infoViewContainerHeightC.constant = 0
        dismissPanGesture.isEnabled = true
        scrollView.alwaysBounceVertical = false
    }
}
