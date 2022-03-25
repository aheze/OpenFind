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

    func sliderChanged(filter: SliderViewModel.Filter) {
        print("slider changed")
        if model.sortNeeded {
            model.sort()
        }
        switch filter {
        case .starred:
            model.displayedSections = model.starredSections
            model.resultsState?.displayedFindPhotos = model.resultsState?.starredFindPhotos ?? []
        case .screenshots:
            model.displayedSections = model.screenshotsSections
            model.resultsState?.displayedFindPhotos = model.resultsState?.screenshotsFindPhotos ?? []
        case .all:
            model.displayedSections = model.allSections
            model.resultsState?.displayedFindPhotos = model.resultsState?.allFindPhotos ?? []
        }
        update()
        updateResults()
    }
}
