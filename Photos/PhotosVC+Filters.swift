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
        let sliderView = SliderView(model: sliderViewModel)
        let hostingController = UIHostingController(rootView: sliderView)
        hostingController.view.backgroundColor = .clear
        addChildViewController(hostingController, in: sliderContainerView)

        sliderContainerViewHeightC.constant = SliderConstants.height
        sliderContainerViewBottomC.constant = SliderConstants.bottomPadding

        sliderViewModel.filterChanged = { [weak self] filter in
            guard let self = self else { return }

            self.sliderChanged(filter: filter)
        }
    }

    /// slider changed to a new selection
    /// If `model.resultsState != nil`, will find again
    func sliderChanged(filter: SliderViewModel.Filter) {
        /// find again (handles star/unstar)
        findAndUpdateDisplayedPhotos(context: .justFindFromExistingDoNotScan)
    }

    /// update the counts of the slider filter
    func updateCounts(allCount: Int?, starredCount: Int?, screenshotsCount: Int?) {
        withAnimation {
            if let index = sliderViewModel.selections.firstIndex(where: { $0.filter == .all }) {
                sliderViewModel.selections[index].count = allCount
            }
            if let index = sliderViewModel.selections.firstIndex(where: { $0.filter == .starred }) {
                sliderViewModel.selections[index].count = starredCount
            }
            if let index = sliderViewModel.selections.firstIndex(where: { $0.filter == .screenshots }) {
                sliderViewModel.selections[index].count = screenshotsCount
            }
        }
    }
}
