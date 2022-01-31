//
//  VC+Frames.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/30/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension ViewController {
    func updateExcludedFrames() {
        let cameraSearchBarFrame = camera.viewController.searchContainerView.windowFrame()
        let listsSearchBarFrame = lists.searchNavigationController.searchContainerView.windowFrame()
        tabController.viewController.excludedFrames = [cameraSearchBarFrame, listsSearchBarFrame]
    }
}
