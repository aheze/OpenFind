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

    func sortCollectionView() {}

    func makeDataSource() -> DataSource {
        let dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, photo -> UICollectionViewCell? in

                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "PhotosCollectionCell",
                    for: indexPath
                ) as! PhotosCollectionCell

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

                cell.tapped = { [weak self] in
                    guard let self = self else { return }
                    self.presentSlides(startingAt: photo)
                }

                return cell
            }
        )
        return dataSource
    }
}
