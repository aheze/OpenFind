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
        self.addChildViewController(viewController, in: infoViewContainer)
        collectionViewContainer.addDebugBorders(.green)
        infoViewContainer.addDebugBorders(.red)
    }

    func showInfo(_ show: Bool) {
        if show {
            let infoHeight = PhotosSlidesConstants.infoHeightPercentageOfScreen * view.bounds.height

            infoViewContainerHeightC.constant = infoHeight
            collectionViewContainerHeightC.constant = view.bounds.height - infoHeight
        } else {
            infoViewContainerHeightC.constant = 0
            collectionViewContainerHeightC.constant = view.bounds.height
        }
        UIView.animate(withDuration: 1) {
            self.contentView.layoutIfNeeded()
        }
    }
}
