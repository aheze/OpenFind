//
//  PhotosSlidesVC+DataSource.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension PhotosSlidesViewController {
    func update(animate: Bool = true) {
        guard let slidesState = model.slidesState else { return }
        var snapshot = Snapshot()
        let section = DataSourceSectionTemplate()
        snapshot.appendSections([section])
        snapshot.appendItems(slidesState.slidesPhotos, toSection: section)
        dataSource?.apply(snapshot, animatingDifferences: animate)
    }

    func makeDataSource() -> DataSource? {
        guard let collectionView = collectionView else { return nil }
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, photo -> UICollectionViewCell? in

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "PhotosSlidesContentCell",
                for: indexPath
            ) as! PhotosSlidesContentCell

            return cell
        }

        return dataSource
    }

    func load(cell: PhotosSlidesContentCell, indexPath: IndexPath) {
        guard let slidesPhoto = model.slidesState?.slidesPhotos[safe: indexPath.item] else { return }

        let photoSlidesViewController: PhotosSlidesItemViewController
        if let viewController = cell.viewController {
            /// recover after deletion
            viewController.view.alpha = 1
            viewController.view.transform = .identity

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
                    realmModel: self.realmModel,
                    findPhoto: slidesPhoto.findPhoto
                )
            }

            photoSlidesViewController = viewController
            addChildViewController(viewController, in: cell.contentView)
            cell.contentView.bringSubviewToFront(viewController.view)

            /// adding a child seems to take control of the navigation bar. stop this
            navigationController?.isNavigationBarHidden = model.slidesState?.isFullScreen ?? false
            cell.viewController = viewController
            viewController.view.layoutIfNeeded()
        }

        model.slidesState?.slidesPhotos[indexPath.item] = slidesPhoto
        photoSlidesViewController.scrollZoomController.imageView.accessibilityTraits = .none
        photoSlidesViewController.scrollZoomController.drawingView.accessibilityTraits = .none

        /// hide views when pushing

        if model.animatingSlides {
            photoSlidesViewController.containerView.alpha = 0
        } else {
            photoSlidesViewController.containerView.alpha = 1
        }
    }
}
