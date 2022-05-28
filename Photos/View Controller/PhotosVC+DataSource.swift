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
            cell.viewController?.model.photo?.metadata = metadata
        }
    }

    func sortCollectionView() {}

    func configureCell(cell: PhotosCell, indexPath: IndexPath) {
        guard let photo = model.getPhoto(from: indexPath) else { return }

        let viewController: PhotosCellImageViewController
        if let existingViewController = cell.viewController {
            viewController = existingViewController
        } else {
            viewController = PhotosCellImageViewController()
            cell.contentView.addSubview(viewController.view)
            viewController.view.pinEdgesToSuperview()
//            addChildViewController(viewController, in: cell.contentView)
            cell.viewController = viewController
        }
//
//
//
//        let selected = self.model.isSelecting && self.model.selectedPhotos.contains(photo)
//        viewController.model.selected = selected
//
//        let description = photo.getVoiceoverDescription()
//        cell.isAccessibilityElement = true
//        cell.accessibilityLabel = description
//
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        

        viewController.model.image = nil
        cell.representedAssetIdentifier = photo.asset.localIdentifier
        cell.fetchingID = PHImageManager.default().requestImage(
            for: photo.asset,
            targetSize: .init(width: 2, height: 2),
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            if cell.representedAssetIdentifier == photo.asset.localIdentifier {
                viewController.model.image = image
            }
        }

        ////

//
//        viewController.model.image = nil
//        let id = self.model.getImage(
//            from: photo.asset,
//            targetSize: self.realmModel.thumbnailSize
//        ) { image in
//                    if cell.representedAssetIdentifier == photo.asset.localIdentifier {
//                        viewController.model.image = image
//                    }
//        }
//        cell.fetchingID = id
    }

    func teardownCell(cell: PhotosCell, indexPath: IndexPath) {
        if let id = cell.fetchingID {
            cell.fetchingID = nil

            model.imageManager.cancelImageRequest(id)
        }
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
