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
    
    /// update the counts of the slider filter
    func updateCounts(allCount: Int?, starredCount: Int?, screenshotsCount: Int?) {
        withAnimation {
            if let index = model.sliderViewModel.selections.firstIndex(where: { $0.filter == .all }) {
                model.sliderViewModel.selections[index].count = allCount
            }
            if let index = model.sliderViewModel.selections.firstIndex(where: { $0.filter == .starred }) {
                model.sliderViewModel.selections[index].count = starredCount
            }
            if let index = model.sliderViewModel.selections.firstIndex(where: { $0.filter == .screenshots }) {
                model.sliderViewModel.selections[index].count = screenshotsCount
            }
        }
    }
}
