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
        if let cell = cell as? PhotosSlidesContentCell {
            load(cell: cell, indexPath: indexPath)
        }

        guard
            let slidesPhoto = model.slidesState?.slidesPhotos[indexPath.item],
            let cell = cell as? PhotosSlidesContentCell,
            let viewController = cell.viewController
        else { return }

        viewController.highlightsViewModel.highlights.removeAll()
        if !slidesSearchViewModel.stringToGradients.isEmpty {
            /// if keys are same, show the highlights.
            if
                let highlightsSet = slidesPhoto.findPhoto.highlightsSet,
                highlightsSet.stringToGradients == self.slidesSearchViewModel.stringToGradients
            {
                viewController.highlightsViewModel.highlights = highlightsSet.highlights

            } else {
                /// else, find again.
                startFinding(for: slidesPhoto, viewController: viewController, animate: false)
            }
        }

        DispatchQueue.main.async {
            viewController.viewDidLayoutSubviews()
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
        if scrollView == self.scrollView {
            infoScrollViewDidEndDecelerating()
        }
    }
}
