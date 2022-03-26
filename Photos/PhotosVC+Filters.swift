//
//  PhotosVC+Filters.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

extension PhotosViewController {
    func setupFiltersView() {
        sliderContainerView.backgroundColor = .clear
        let sliderView = SliderView(model: model.sliderViewModel)
        let hostingController = UIHostingController(rootView: sliderView)
        hostingController.view.backgroundColor = .clear
        addChildViewController(hostingController, in: sliderContainerView)

        sliderContainerViewHeightC.constant = SliderConstants.height
        sliderContainerViewBottomC.constant = SliderConstants.bottomPadding

        model.sliderViewModel.filterChanged = { [weak self] filter in
            guard let self = self else { return }
            self.sliderChanged(filter: filter)
        }
    }

    /// slider changed to a new selection
    func sliderChanged(filter: SliderViewModel.Filter) {
        if model.sortNeeded {
            model.sort()
            if model.resultsState != nil {
                find() /// find again (handles star/unstar)
            }
        }
        
        switch filter {
        case .starred:
            model.displayedSections = model.starredSections
            if let starredFindPhotos = model.resultsState?.starredFindPhotos {
                model.resultsState?.displayedFindPhotos = starredFindPhotos
            }
        case .screenshots:
            model.displayedSections = model.screenshotsSections
            if let screenshotsFindPhotos = model.resultsState?.screenshotsFindPhotos {
                model.resultsState?.displayedFindPhotos = screenshotsFindPhotos
            }
        case .all:
            model.displayedSections = model.allSections
            if let allFindPhotos = model.resultsState?.allFindPhotos {
                model.resultsState?.displayedFindPhotos = allFindPhotos
            }
        }

        update()
        updateResults()
    }
}
