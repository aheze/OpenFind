//
//  PhotosVC+DataSource.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import UIKit

extension PhotosViewController {
    func update(animate: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections(model.sections)
        model.sections.forEach { section in
            snapshot.appendItems(section.photos, toSection: section)
        }
        dataSource.apply(snapshot, animatingDifferences: animate)
    }

    /// reload the collection view at an index path.
    func update(at indexPath: IndexPath, with metadata: PhotoMetadata) {
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotosCollectionCell {
            configureCell(cell: cell, metadata: metadata)
        }
    }

    func sortCollectionView() {}

    func makeDataSource() -> DataSource {
        let dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, cachedPhoto -> UICollectionViewCell? in

                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "PhotosCollectionCell",
                    for: indexPath
                ) as! PhotosCollectionCell

                /// get the current up-to-date photo first.
                guard let photo = self.model.photos.first(where: { $0 == cachedPhoto }) else { return cell }

                // Request an image for the asset from the PHCachingImageManager.
                cell.representedAssetIdentifier = photo.asset.localIdentifier
                self.model.imageManager.requestImage(
                    for: photo.asset,
                    targetSize: PhotosConstants.thumbnailSize,
                    contentMode: .aspectFill,
                    options: nil
                ) { thumbnail, _ in
                    // UIKit may have recycled this cell by the handler's activation time.
                    // Set the cell's thumbnail image only if it's still showing the same asset.
                    if cell.representedAssetIdentifier == photo.asset.localIdentifier {
                        cell.imageView.image = thumbnail
                        self.model.photoToThumbnail[photo] = thumbnail
                    }
                }

                self.configureCell(cell: cell, metadata: photo.metadata)

                cell.tapped = { [weak self] in
                    guard let self = self else { return }

                    self.presentSlides(startingAtPhoto: photo)
                }

                return cell
            }
        )

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "PhotosCollectionHeader",
                for: indexPath
            ) as? PhotosCollectionHeader else { return nil }
            
            header.label.text = "Hi!"

            return header
        }
        return dataSource
    }

    func configureCell(cell: PhotosCollectionCell, metadata: PhotoMetadata?) {
        if let metadata = metadata {
            if metadata.isStarred {
                cell.overlayGradientImageView.alpha = 1
                cell.overlayStarImageView.alpha = 1
                return
            }
        }

        cell.overlayGradientImageView.alpha = 0
        cell.overlayStarImageView.alpha = 0
    }
}
