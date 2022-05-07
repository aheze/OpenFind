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
        addChildViewController(hostingController, in: landscapeToolbarContainer)
        
        updateLandscapeToolbar()

        switch traitCollection.orientation {
        case .phoneLandscape, .phonePortrait:
            let landscapeTabBarHeight = TabBarAttributes.darkBackgroundLandscape.backgroundHeight
            
            let cellHeight = landscapeTabBarHeight
                - searchViewModel.configuration.barTopPaddingLandscape
                - searchViewModel.configuration.barBottomPaddingLandscape
            
            let height = max(cellHeight, CameraConstants.minimumLandscapeSearchBarHeight)
            searchViewModel.configuration.cellHeightLandscape = height
        default: break
        }
    }
    
    func updateLandscapeToolbar() {
        switch traitCollection.orientation {
        case .phoneLandscape:
            landscapeToolbarContainer.alpha = 1
            model.toolbarState = .sideCompact
        case .phonePortrait:
            landscapeToolbarContainer.alpha = 0
            model.toolbarState = .inTabBar
        case .pad:
            landscapeToolbarContainer.alpha = 1
            model.toolbarState = .sideExpanded
        }
    }
}
