//
//  PhotosSlidesVC+FullScreen.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension PhotosSlidesViewController {
    func toggleFullScreen() {
        guard let slidesState = model.slidesState else { return }
        let isFullScreen = !slidesState.isFullScreen
        model.slidesState?.isFullScreen = isFullScreen
        if isFullScreen {
            searchNavigationModel.showNavigationBar?(false)
            tabViewModel.showBars(false, with: .tabAndStatusBar)
        } else {
            searchNavigationModel.showNavigationBar?(true)
            tabViewModel.showBars(true, with: .tabAndStatusBar)
        }
    }
}
