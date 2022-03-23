//
//  PhotosSlidesVC+Delegate.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension PhotosSlidesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard var findPhoto = model.slidesState?.findPhotos[safe: indexPath.item] else { return }

        let photoSlidesViewController: PhotosSlidesItemViewController
        if let viewController = findPhoto.associatedViewController {
            viewController.loadViewIfNeeded()
            viewController.reloadImage()
            photoSlidesViewController = viewController
            addChildViewController(viewController, in: cell.contentView)
        } else {
            let storyboard = UIStoryboard(name: "PhotosContent", bundle: nil)
            let viewController = storyboard.instantiateViewController(identifier: "PhotosSlidesItemViewController") { coder in
                PhotosSlidesItemViewController(
                    coder: coder,
                    model: self.model,
                    findPhoto: findPhoto
                )
            }

            photoSlidesViewController = viewController
            addChildViewController(viewController, in: cell.contentView)

            /// adding a child seems to take control of the navigation bar. stop this
            navigationController?.isNavigationBarHidden = model.slidesState?.isFullScreen ?? false
            findPhoto.associatedViewController = viewController
            model.slidesState?.findPhotos[indexPath.item] = findPhoto
        }

        if !slidesSearchViewModel.stringToGradients.isEmpty {
            /// if keys are same, show the highlights.
            if
                let highlightsSet = findPhoto.highlightsSet,
                highlightsSet.stringToGradients == slidesSearchViewModel.stringToGradients
            {
                photoSlidesViewController.highlightsViewModel.highlights = highlightsSet.highlights
            } else {
                /// else, find again.
                startFinding(for: findPhoto)
            }
        }

        if model.animatingSlides {
            photoSlidesViewController.containerView.alpha = 0
        } else {
            photoSlidesViewController.containerView.alpha = 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let findPhoto = model.slidesState?.findPhotos[safe: indexPath.item] {
            /// make sure the photo isn't being shown/focused (prevent white screen)
            guard model.slidesState?.currentPhoto != findPhoto.photo else { return }

            if let viewController = findPhoto.associatedViewController {
                removeChildViewController(viewController)
                model.slidesState?.findPhotos[indexPath.item].associatedViewController = nil
            }
        }
    }
}

/// detect stopped at a new photo
extension PhotosSlidesViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            model.updateAllowed = false
        } else if scrollView == self.scrollView {
            self.infoScrollViewDidScroll()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            notifyIfScrolledToStop()
            model.updateAllowed = true
        } else if scrollView == self.scrollView {
            self.infoScrollViewDidEndDecelerating()
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        notifyIfScrolledToStop()
    }

    /// stopped scrolling
    func notifyIfScrolledToStop() {
        if let slidesState = model.slidesState, let findPhoto = slidesState.getCurrentFindPhoto() {
            slidesSearchPromptViewModel.resultsText = findPhoto.getResultsText()
            slidesSearchPromptViewModel.updateBarHeight?()
            configureToolbar(for: findPhoto.photo)
        }
    }
}
