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
        if let findPhoto = model.slidesState?.findPhotos[safe: indexPath.item] {
            let photoSlidesViewController: PhotosSlidesItemViewController
            if let viewController = findPhoto.associatedViewController {
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
                model.slidesState?.findPhotos[indexPath.item].associatedViewController = viewController
            }

            if let highlights = findPhoto.highlights {
                photoSlidesViewController.highlightsViewModel.highlights = highlights
            }

            if model.animatingSlides {
                photoSlidesViewController.containerView.alpha = 0
            } else {
                photoSlidesViewController.containerView.alpha = 1
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let findPhoto = model.slidesState?.findPhotos[safe: indexPath.item] {
            if let viewController = findPhoto.associatedViewController {
                removeChildViewController(viewController)
                model.slidesState?.findPhotos[indexPath.item].associatedViewController = nil
            }
        }
    }
}

extension PhotosSlidesViewController: UIGestureRecognizerDelegate {
//    func gesturere
}
