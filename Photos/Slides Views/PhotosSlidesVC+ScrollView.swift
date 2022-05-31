//
//  PhotosSlidesVC+ScrollView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/22/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension PhotosSlidesViewController {
    func setupScrollView() {
        scrollView.delegate = self
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.decelerationRate = .fast

        /// don't use `scrollView.bounds.height`, it will be less
        collectionViewContainerHeightC.constant = view.bounds.height
    }
}

extension PhotosSlidesViewController {
    /// update the photo height
    func infoScrollViewDidScroll() {
        /// only update after **the user** scrolled, since `scrollViewDidScroll` is called even when programmatically setting the content offset
        if scrollView.isTracking || scrollView.isDragging || scrollView.isDecelerating {
            flowLayout.invalidateLayout()
        }

        if traitCollection.horizontalSizeClass != .regular {
            let infoHeight = getInfoHeight()
            let percentage = 1 - ((infoHeight - scrollView.contentOffset.y) / infoHeight)
            getCurrentItemViewController()?.setAspectRatioToFill(percentage: percentage)
        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        /// make sure it's the info scroll view
        guard scrollView == self.scrollView else { return }
        let currentOffset = scrollView.contentOffset.y
        let infoHeight = getInfoHeight()

        let distanceToDetent = infoHeight - currentOffset
        if distanceToDetent < 100 {
            targetContentOffset.pointee.y = infoHeight
        } else {
            targetContentOffset.pointee.y = 0
            model.slidesState?.toolbarInformationOn = false
        }
    }

    /// reset to hidden after `scrollViewWillEndDragging`
    func infoScrollViewDidEndDecelerating() {
        if let slidesState = model.slidesState, !slidesState.toolbarInformationOn {
            resetInfoToHidden(scrollIfNeeded: false)
        }
    }
}
