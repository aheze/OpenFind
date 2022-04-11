//
//  IgnoredPhotosVC+DataSource.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension IgnoredPhotosViewController {
    func update(animate: Bool = true) {
        var snapshot = Snapshot()
        let section = DataSourceSectionTemplate()
        snapshot.appendSections([section])
        snapshot.appendItems(model.ignoredPhotos, toSection: section)
        dataSource.apply(snapshot, animatingDifferences: animate)
    }

    func makeDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, cachedPhoto -> UICollectionViewCell? in

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "PhotosCollectionCell",
                for: indexPath
            ) as! PhotosCollectionCell

            /// get the current up-to-date photo first.
            guard let photo = self.model.ignoredPhotos.first(where: { $0 == cachedPhoto }) else { return cell }

            // Request an image for the asset from the PHCachingImageManager.
            cell.representedAssetIdentifier = photo.asset.localIdentifier
            self.model.imageManager.requestImage(
                for: photo.asset,
                targetSize: self.model.getRealmModel?().thumbnailSize ?? .zero,
                contentMode: .aspectFill,
                options: nil
            ) { thumbnail, _ in
                // UIKit may have recycled this cell by the handler's activation time.
                // Set the cell's thumbnail image only if it's still showing the same asset.
                if cell.representedAssetIdentifier == photo.asset.localIdentifier {
                    cell.view.imageView.image = thumbnail
                    self.model.photoToThumbnail[photo] = thumbnail
                }
            }

            PhotoMetadata.apply(metadata: photo.metadata, to: cell.view)

            /// selection
            cell.buttonView.isUserInteractionEnabled = !self.model.ignoredPhotosIsSelecting
            let selected = self.model.ignoredPhotosIsSelecting && self.model.ignoredPhotosSelectedPhotos.contains(photo)
            self.configureCellSelection(cell: cell, selected: selected)

            return cell
        }
        return dataSource
    }
}
