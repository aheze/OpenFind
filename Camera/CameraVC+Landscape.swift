//
//  CameraVC+Landscape.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/8/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import SwiftUI

extension CameraViewController {
    func setupLandscapeToolbar() {
        let landscapeToolbar = CameraLandscapeToolbarView(tabViewModel: tabViewModel, model: model) { [weak self] size in
            self?.landscapeToolbarWidthC.constant = size.width
        }
        let hostingController = UIHostingController(rootView: landscapeToolbar)
        hostingController.view.backgroundColor = .clear
        landscapeToolbarContainer.backgroundColor = .clear
        addChildViewController(hostingController, in: landscapeToolbarContainer)
        
        updateLandscapeToolbar()
        let landscapeTabBarHeight = TabBarAttributes.darkBackgroundLandscape.backgroundHeight
        
        let cellHeight = landscapeTabBarHeight
            - searchViewModel.configuration.barTopPaddingLandscape
            - searchViewModel.configuration.barBottomPaddingLandscape
        searchViewModel.configuration.cellHeightLandscape = cellHeight
    }
    
    func updateLandscapeToolbar() {
        /// iPhone horizontal
        if traitCollection.verticalSizeClass == .compact {
            landscapeToolbarContainer.alpha = 1
            model.toolbarState = .sideCompact
        } else {
            /// iPhone vertical
            if traitCollection.horizontalSizeClass == .compact {
                landscapeToolbarContainer.alpha = 0
                model.toolbarState = .inTabBar
            } else { /// iPad
                landscapeToolbarContainer.alpha = 1
                model.toolbarState = .sideExpanded
            }
        }
    }
}
