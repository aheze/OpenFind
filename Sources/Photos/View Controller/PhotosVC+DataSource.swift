//
//  PhotosVC+DataSource.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import SwiftUI

extension PhotosViewController {
    func update(animate: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections(model.displayedSections)
        model.displayedSections.forEach { section in
            snapshot.appendItems(section.photos, toSection: section)
        }
        dataSource.apply(snapshot, animatingDifferences: animate)

        showEmptyContent(model.displayedSections.isEmpty)
        updateViewsEnabled()
    }

    /// reload the collection view at an index path.
    func update(at indexPath: IndexPath, with metadata: PhotoMetadata) {
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotosCell {
            cell.model.photo?.metadata = metadata
        }
    }

    func configureCell(cell: PhotosCell, indexPath: IndexPath) {
        guard let photo = model.getPhoto(from: indexPath) else { return }

        DispatchQueue.main.async {
            cell.model.image = nil

            if cell.containerView == nil {
                let contentView = PhotosCellImageView(model: cell.model)
                let hostingController = UIHostingController(rootView: contentView)
                hostingController.view.backgroundColor = .clear
                cell.contentView.addSubview(hostingController.view)
                hostingController.view.pinEdgesToSuperview()
                cell.containerView = hostingController.view
            }

            cell.model.photo = photo

            let selected = self.model.isSelecting && self.model.selectedPhotos.contains(photo)
            cell.model.selected = selected

            let description = photo.getVoiceoverDescription()
            cell.isAccessibilityElement = true
            cell.accessibilityLabel = description

            cell.representedAssetIdentifier = photo.asset.localIdentifier

            cell.fetchingID = self.model.getImage(
                from: photo.asset,
                targetSize: self.realmModel.thumbnailSize
            ) { [weak cell] image in
                // UIKit may have recycled this cell by the handler's activation time.
                // Set the cell's thumbnail image only if it's still showing the same asset.
                if cell?.representedAssetIdentifier == photo.asset.localIdentifier {
                    cell?.model.image = image
                }
            }
        }
    }

    func teardownCell(cell: PhotosCell, indexPath: IndexPath) {
        if let id = cell.fetchingID {
            cell.fetchingID = nil

            model.imageManager.cancelImageRequest(id)
        }
        cell.model.image = nil
    }

    func makeDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, cachedPhoto -> UICollectionViewCell? in

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "PhotosCell",
                for: indexPath
            ) as! PhotosCell

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
