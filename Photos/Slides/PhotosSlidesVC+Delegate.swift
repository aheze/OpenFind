//
//  PhotosSlidesVC+Delegate.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension PhotosSlidesViewController: UICollectionViewDelegate {
    /// find when swipe to new cell
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard
            let slidesPhoto = model.slidesState?.slidesPhotos[indexPath.item],
            let cell = cell as? PhotosSlidesContentCell,
            let viewController = cell.viewController
        else { return }

        if !slidesSearchViewModel.stringToGradients.isEmpty {
            /// if keys are same, show the highlights.
            if
                let highlightsSet = slidesPhoto.findPhoto.highlightsSet,
                highlightsSet.stringToGradients == slidesSearchViewModel.stringToGradients
            {
                viewController.highlightsViewModel.highlights = highlightsSet.highlights
            } else {
                /// else, find again.
                startFinding(for: slidesPhoto)
            }
        }
    }
}

/// detect stopped at a new photo
extension PhotosSlidesViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            infoScrollViewDidScroll()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            notifyIfScrolledToStop()
        } else if scrollView == self.scrollView {
            infoScrollViewDidEndDecelerating()
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        notifyIfScrolledToStop()
    }

    /// stopped scrolling
    func notifyIfScrolledToStop() {
        if let slidesState = model.slidesState {
            /// update header
            if let slidesPhoto = slidesState.getCurrentSlidesPhoto() {
                slidesSearchPromptViewModel.resultsText = slidesPhoto.findPhoto.getResultsText()
                slidesSearchPromptViewModel.updateBarHeight?()
                configureToolbar(for: slidesPhoto.findPhoto.photo)
            }
        }
    }
}
