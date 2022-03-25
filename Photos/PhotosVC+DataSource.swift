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
    
    /// sort and update data for a specified filter
    func load(for filter: SliderViewModel.Filter) {
        model.sort()
        switch filter {
        case .starred:
            model.displayedSections = model.starredSections
        case .screenshots:
            model.displayedSections = model.screenshotsSections
        case .all:
            model.displayedSections = model.allSections
        }
        update()
        updateResults()
    }

    func update(animate: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections(model.displayedSections)
        model.displayedSections.forEach { section in
            snapshot.appendItems(section.photos, toSection: section)
        }
        dataSource.apply(snapshot, animatingDifferences: animate)
    }

    /// reload the collection view at an index path.
    func update(at indexPath: IndexPath, with metadata: PhotoMetadata) {
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotosCollectionCell {
            PhotoMetadata.apply(metadata: metadata, to: cell)
        }
    }

    func sortCollectionView() {}

    func makeDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, cachedPhoto -> UICollectionViewCell? in

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
                    cell.view.imageView.image = thumbnail
                    self.model.photoToThumbnail[photo] = thumbnail
                }
            }

            PhotoMetadata.apply(metadata: photo.metadata, to: cell)

            cell.tapped = { [weak self] in
                guard let self = self else { return }

                self.presentSlides(startingAtPhoto: photo)
            }

            /// selection
            cell.buttonView.isUserInteractionEnabled = !self.model.isSelecting
            let selected = self.model.isSelecting && self.model.selectedPhotos.contains(photo)
            self.configureCellSelection(cell: cell, selected: selected)

            return cell
        }

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "PhotosCollectionHeader",
                for: indexPath
            ) as? PhotosCollectionHeader else { return nil }

            return header
        }
        return dataSource
    }
}

func configureCellSelection(cell: PhotosCollectionCell, selected: Bool) {
    cell.view.selectOverlayIconView.setState(selected ? .selected : .hidden)
    cell.view.selectOverlayView.backgroundColor = selected ? PhotosCellConstants.selectedBackgroundColor : .clear
}
