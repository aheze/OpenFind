//
//  PhotosSlidesVC+Delegate.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension PhotosSlidesViewController: UICollectionViewDelegate {
    func display(cell: PhotosSlidesContentCell, indexPath: IndexPath) {
        guard let slidesPhoto = model.slidesState?.slidesPhotos[safe: indexPath.item] else { return }

        let photoSlidesViewController: PhotosSlidesItemViewController
        if let viewController = cell.viewController {
            viewController.findPhoto = slidesPhoto.findPhoto
            viewController.loadViewIfNeeded()
            viewController.reloadImage()
            photoSlidesViewController = viewController
        } else {
            let storyboard = UIStoryboard(name: "PhotosContent", bundle: nil)
            let viewController = storyboard.instantiateViewController(identifier: "PhotosSlidesItemViewController") { coder in
                PhotosSlidesItemViewController(
                    coder: coder,
                    model: self.model,
                    findPhoto: slidesPhoto.findPhoto
                )
            }

            photoSlidesViewController = viewController
            addChildViewController(viewController, in: cell.contentView)
            cell.contentView.bringSubviewToFront(viewController.view)

            /// adding a child seems to take control of the navigation bar. stop this
            navigationController?.isNavigationBarHidden = model.slidesState?.isFullScreen ?? false
            cell.viewController = viewController
        }
        
        model.slidesState?.slidesPhotos[indexPath.item] = slidesPhoto

        if !slidesSearchViewModel.stringToGradients.isEmpty {
            /// if keys are same, show the highlights.
            if
                let highlightsSet = slidesPhoto.findPhoto.highlightsSet,
                highlightsSet.stringToGradients == slidesSearchViewModel.stringToGradients
            {
                photoSlidesViewController.highlightsViewModel.highlights = highlightsSet.highlights
            } else {
                /// else, find again.
                startFinding(for: slidesPhoto)
            }
        }

        if model.animatingSlides {
            photoSlidesViewController.containerView.alpha = 0
        } else {
            photoSlidesViewController.containerView.alpha = 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if let slidesPhoto = model.slidesState?.slidesPhotos[safe: indexPath.item] {
//            /// make sure the photo isn't being shown/focused (prevent white screen)
//            guard model.slidesState?.currentPhoto != slidesPhoto.findPhoto.photo else { return }
//
//            if let viewController = slidesPhoto.associatedViewController {
//                removeChildViewController(viewController)
//                model.slidesState?.slidesPhotos[indexPath.item].associatedViewController = nil
//            }
//        }
    }
}

/// detect stopped at a new photo
extension PhotosSlidesViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            /// only disallow if **the user** scrolled, since `scrollViewDidScroll` is called even when programmatically setting the content offset
            if scrollView.isTracking || scrollView.isDragging || scrollView.isDecelerating {
                model.updateAllowed = false
            }
        } else if scrollView == self.scrollView {
            infoScrollViewDidScroll()
        }
    }

//    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//        if scrollView == collectionView {
//            finishDeleting()
//        }
//    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            notifyIfScrolledToStop()
            model.updateAllowed = true
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
