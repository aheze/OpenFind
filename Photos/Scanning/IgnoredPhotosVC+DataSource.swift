//
//  IgnoredPhotosVC+DataSource.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import SwiftUI

extension IgnoredPhotosViewController {
    func update(animate: Bool = true) {
        var snapshot = Snapshot()
        let section = DataSourceSectionTemplate()
        snapshot.appendSections([section])
        snapshot.appendItems(model.ignoredPhotos, toSection: section)
        dataSource.apply(snapshot, animatingDifferences: animate)
    }

    func configureCell(cell: PhotosCell, indexPath: IndexPath) {
        guard let photo = model.getPhoto(from: indexPath) else { return }

        if cell.view == nil {
            let contentView = PhotosCellImageView(model: cell.model)
            let hostingController = UIHostingController(rootView: contentView)
            cell.contentView.addSubview(hostingController.view)
            hostingController.view.pinEdgesToSuperview()
            cell.view = hostingController.view
        }

//        cell.model.photo = photo
//
//        let selected = self.model.isSelecting && self.model.selectedPhotos.contains(photo)
//        cell.model.selected = selected
//
//        let description = photo.getVoiceoverDescription()
//        cell.isAccessibilityElement = true
//        cell.accessibilityLabel = description
//
//        cell.model.image = nil
//        cell.representedAssetIdentifier = photo.asset.localIdentifier
//
//        cell.fetchingID = self.model.getImage(
//            from: photo.asset,
//            targetSize: self.realmModel.thumbnailSize
//        ) { [weak viewController] image in
//            // UIKit may have recycled this cell by the handler's activation time.
//            // Set the cell's thumbnail image only if it's still showing the same asset.
//            if cell.representedAssetIdentifier == photo.asset.localIdentifier {
//                viewController?.model.image = image
//            }
//        }
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
        return dataSource
    }
}
