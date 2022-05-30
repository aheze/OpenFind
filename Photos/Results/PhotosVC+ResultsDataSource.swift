//
//  PhotosVC+ResultsDataSource.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/23/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import UIKit

extension PhotosViewController {
    func updateResults(animate: Bool = true) {
        guard let resultsState = model.resultsState else { return }
        var resultsSnapshot = ResultsSnapshot()
        let section = DataSourceSectionTemplate()
        resultsSnapshot.appendSections([section])
        resultsSnapshot.appendItems(resultsState.displayedFindPhotos, toSection: section)
        resultsDataSource.apply(resultsSnapshot, animatingDifferences: animate)

        resultsHeaderViewModel.text = model.resultsState?.getResultsText() ?? ""
        if model.scannedPhotosCount == model.totalPhotosCount {
            resultsHeaderViewModel.description = nil
        } else {
            resultsHeaderViewModel.description = ResultsHeaderViewModel.defaultDescription
        }
        updateCounts(
            allCount: resultsState.allFindPhotos.count,
            starredCount: resultsState.starredFindPhotos.count,
            screenshotsCount: resultsState.screenshotsFindPhotos.count
        )
        updateViewsEnabled()
    }

    /// reload the collection view at an index path.
    func updateResults(at index: Int, with metadata: PhotoMetadata) {
        if let cell = resultsCollectionView.cellForItem(at: index.indexPath) as? PhotosResultsCell {
            PhotoMetadata.apply(metadata: metadata, to: cell.view)
        }
    }

    /// returns the view controller, loading it if necessary
    func getAndLoadCellResultsViewController(cell: PhotosCellResults, findPhoto: FindPhoto) -> PhotosCellResultsImageViewController {
        let viewController: PhotosCellResultsImageViewController
        if let existingViewController = cell.viewController {
            viewController = self.reloadCellResults(cell: cell, existingViewController: existingViewController, findPhoto: findPhoto)
        } else {
            viewController = PhotosCellResultsImageViewController(realmModel: realmModel)
            addChildViewController(viewController, in: cell.contentView)
            cell.viewController = viewController
        }
        return viewController
    }

    func reloadVisibleCellResults() {
        guard let displayedFindPhotos = model.resultsState?.displayedFindPhotos else { return }
        for index in displayedFindPhotos.indices {
            if
                let cell = self.resultsCollectionView.cellForItem(at: index.indexPath) as? PhotosCellResults,
                let existingViewController = cell.viewController,
                let findPhoto = self.model.resultsState?.displayedFindPhotos[safe: index]
            {
                self.reloadCellResults(cell: cell, existingViewController: existingViewController, findPhoto: findPhoto)
            }
        }
    }

    /// also update the description highlights
    @discardableResult
    func reloadCellResults(cell: PhotosCellResults, existingViewController: PhotosCellResultsImageViewController, findPhoto: FindPhoto) -> PhotosCellResultsImageViewController {
        let newViewController = PhotosCellResultsImageViewController(
            model: existingViewController.model,
            resultsModel: existingViewController.resultsModel,
            textModel: existingViewController.textModel,
            highlightsViewModel: existingViewController.highlightsViewModel,
            realmModel: existingViewController.realmModel
        )

        self.addChildViewController(newViewController, in: cell.contentView)
        cell.viewController = newViewController
//        newViewController.view.alpha = 0

//        UIView.animate(withDuration: 0.3) {
//            existingViewController.view.alpha = 0
//            newViewController.view.alpha = 1
//        } completion: { _ in
        self.removeChildViewController(existingViewController)
//        }
        configureCellResultsDescription(cell: cell, findPhoto: findPhoto)
        return newViewController
    }

    func configureCellResults(cell: PhotosCellResults, indexPath: IndexPath) {
        guard
            let resultsState = model.resultsState,
            let findPhoto = resultsState.displayedFindPhotos[safe: indexPath.item]
        else { return }

        let viewController = self.getAndLoadCellResultsViewController(cell: cell, findPhoto: findPhoto)

        viewController.highlightsViewModel.highlights.removeAll()
        viewController.resultsModel.findPhoto = findPhoto
        viewController.model.photo = findPhoto.photo

        let selected = self.model.isSelecting && self.model.selectedPhotos.contains(findPhoto.photo)
        viewController.model.selected = selected

        viewController.model.image = nil
        cell.representedAssetIdentifier = findPhoto.photo.asset.localIdentifier

        cell.fetchingID = self.model.getImage(
            from: findPhoto.photo.asset,
            targetSize: CGSize(width: 300, height: 300)
        ) { [weak viewController] image in
            // UIKit may have recycled this cell by the handler's activation time.
            // Set the cell's thumbnail image only if it's still showing the same asset.
            if cell.representedAssetIdentifier == findPhoto.photo.asset.localIdentifier {
                viewController?.model.image = image
            }
        }

        configureCellResultsDescription(cell: cell, findPhoto: findPhoto)
    }

    func teardownCellResults(cell: PhotosCellResults, indexPath: IndexPath) {}

    /// call after bounds or filter change
    /// Only works when `resultsState` isn't nil
    /// If add completion, must call `updateResults()` later.
    /// If completion is `nil`, `invalidateLayout` will be called.
    func updateResultsCellSizes(completion: (() -> Void)? = nil) {
        if let displayedFindPhotos = model.resultsState?.displayedFindPhotos {
            let (_, columnWidth) = resultsFlowLayout.getColumns(bounds: collectionView.bounds.width, insets: collectionView.safeAreaInsets)

            DispatchQueue.global(qos: .userInitiated).async {
                let sizes = self.getDisplayedCellSizes(from: displayedFindPhotos, columnWidth: columnWidth)

                DispatchQueue.main.async {
                    self.model.resultsState?.displayedCellSizes = sizes
                    if let completion = completion {
                        completion()
                    } else {
                        self.resultsFlowLayout.invalidateLayout()
                    }
                }
            }
        }
    }

    func makeResultsDataSource() -> ResultsDataSource {
        let dataSource = ResultsDataSource(collectionView: resultsCollectionView) { collectionView, indexPath, cachedFindPhoto -> UICollectionViewCell? in

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "PhotosCellResults",
                for: indexPath
            ) as! PhotosCellResults

            return cell
        }

        return dataSource
    }
}
