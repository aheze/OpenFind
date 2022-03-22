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
        if show {
            infoViewContainerHeightC.constant = getInfoHeight()
            dismissPanGesture.isEnabled = false
        } else {
            infoViewContainerHeightC.constant = 0
            dismissPanGesture.isEnabled = true
        }

        UIView.animate(withDuration: 0.3) {
            self.flowLayout.invalidateLayout()
            self.contentView.layoutIfNeeded()
            if let currentViewController = self.model.slidesState?.getCurrentFindPhoto()?.associatedViewController {
                currentViewController.setAspectRatio(scaleToFill: show)
            }
        }
    }
}
