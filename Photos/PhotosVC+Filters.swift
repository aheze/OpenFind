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

        sliderContainerView.alpha = 0
        sliderContainerView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
    }

    func showFiltersView(_ show: Bool, animate: Bool) {
        func changeFiltersViewVisibility() {
            if show {
                sliderContainerView.alpha = 1
                sliderContainerView.transform = .identity
            } else {
                sliderContainerView.alpha = 0
                sliderContainerView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }
        }

        if animate {
            UIView.animate(duration: 0.5, dampingFraction: 0.8) {
                changeFiltersViewVisibility()
            }
        } else {
            changeFiltersViewVisibility()
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
