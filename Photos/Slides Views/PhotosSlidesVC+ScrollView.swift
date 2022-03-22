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
        infoViewContainerHeightC.constant = 0
    }
}

extension PhotosSlidesViewController {
    func infoScrollViewDidScroll() {
        flowLayout.invalidateLayout()
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        /// make sure it's the info scroll view
        guard scrollView == self.scrollView else { return }
        let currentOffset = scrollView.contentOffset.y /// make positive for now
        let threshold = getInfoHeight() / 2
        print("currentOffset \(currentOffset) vs threshold \(threshold)")
        if currentOffset < threshold {
            targetContentOffset.pointee.y = 0
            model.slidesState?.toolbarInformationOn = false
            model.slidesState?.toolbarInformationOnChanged?()
        }
    }
}
