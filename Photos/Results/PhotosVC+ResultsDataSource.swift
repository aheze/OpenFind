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

    func makeResultsDataSource() -> ResultsDataSource {
        let dataSource = ResultsDataSource(collectionView: resultsCollectionView) { collectionView, indexPath, cachedFindPhoto -> UICollectionViewCell? in

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "PhotosResultsCell",
                for: indexPath
            ) as! PhotosResultsCell

            /// get the current up-to-date FindPhoto first.
            guard let findPhoto = self.model.resultsState?.displayedFindPhotos.first(where: { $0.photo == cachedFindPhoto.photo }) else { return cell }

            cell.titleLabel.text = findPhoto.dateString()
            cell.resultsLabel.text = findPhoto.resultsString()
            cell.descriptionTextView.text = findPhoto.descriptionText

            // Request an image for the asset from the PHCachingImageManager.
            cell.representedAssetIdentifier = findPhoto.photo.asset.localIdentifier
            self.model.imageManager.requestImage(
                for: findPhoto.photo.asset,
                targetSize: self.realmModel.thumbnailSize,
                contentMode: .aspectFill,
                options: nil
            ) { thumbnail, _ in
                // UIKit may have recycled this cell by the handler's activation time.
                // Set the cell's thumbnail image only if it's still showing the same asset.
                if cell.representedAssetIdentifier == findPhoto.photo.asset.localIdentifier {
                    cell.view.imageView.image = thumbnail
                    self.model.photoToThumbnail[findPhoto.photo] = thumbnail
                }
            }

            PhotoMetadata.apply(metadata: findPhoto.photo.metadata, to: cell.view)

            self.loadHighlights(for: cell, findPhoto: findPhoto)

            cell.tapped = { [weak self] in
                guard let self = self else { return }
                /// get the current up-to-date FindPhoto first.
                guard let findPhoto = self.model.resultsState?.displayedFindPhotos.first(where: { $0.photo == cachedFindPhoto.photo }) else { return }
                self.presentSlides(startingAtFindPhoto: findPhoto)
            }

            return cell
        }

        return dataSource
    }
}
