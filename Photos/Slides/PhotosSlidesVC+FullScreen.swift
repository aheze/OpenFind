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
        switchToFullScreen(isFullScreen)
    }

    func switchToFullScreen(_ fullScreen: Bool) {
        if fullScreen {
            searchViewModel.dismissKeyboard?()
            searchNavigationModel.showNavigationBar?(false)
            tabViewModel.showBars(false, with: .tabAndStatusBar)

            UIView.animate(withDuration: 0.2) {
                self.view.backgroundColor = .black
            }
        } else {
            searchNavigationModel.showNavigationBar?(true)
            tabViewModel.showBars(true, with: .tabAndStatusBar)

            UIView.animate(withDuration: 0.2) {
                self.view.backgroundColor = .systemBackground
            }
        }
    }
}
