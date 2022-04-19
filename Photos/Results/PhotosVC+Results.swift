//
//  PhotosVC+Results.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/23/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

/**
 The results collection view, which should present slides as finding slides
 */

extension PhotosViewController {
    /// `removeFromSuperview` is necessary to update the large title scrolling behavior
    func showResults(_ show: Bool) {
        if show {
            if resultsCollectionView.window == nil {
                collectionViewContainer.addSubview(resultsCollectionView)
                resultsCollectionView.pinEdgesToSuperview()
                setupResultsHeader()
            }

            collectionView.removeFromSuperview()
            updateNavigationBlur(with: resultsCollectionView)
            showCancelNavigationBar()
            showScanningButton(false)
            contentContainer.isHidden = true
        } else {
            model.resultsState = nil
            if collectionView.window == nil {
                collectionViewContainer.addSubview(collectionView)
                collectionView.pinEdgesToSuperview()
            }
            resultsCollectionView.removeFromSuperview()
            updateNavigationBlur(with: collectionView)
            hideCancelNavigationBar()
            showScanningButton(true)
            updateCounts(
                allCount: nil,
                starredCount: nil,
                screenshotsCount: nil
            )
            contentContainer.isHidden = false
        }
        updateViewsEnabled()
    }
}
