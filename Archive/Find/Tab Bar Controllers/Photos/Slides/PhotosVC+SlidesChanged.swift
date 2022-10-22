//
//  PhotosVC+SlidesChanged.swift
//  Find
//
//  Created by Zheng on 1/21/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotosViewController {
    func slidesChanged(findPhoto: FindPhoto) {
        for month in allMonths {
            for photo in month.photos {
                if photo.asset.localIdentifier == findPhoto.asset.localIdentifier {
                    photo.editableModel = findPhoto.editableModel
                    break
                }
            }
        }
        
        sortPhotos(with: photoFilterState)
        applySnapshot(animatingDifferences: false)
    }
}

/// When the slides pages left or right
extension PhotosViewController: PhotoSlidesUpdatedIndex {
    func indexUpdated(to newIndex: Int) {
        if let previousIndexPath = selectedIndexPath {
            if let cell = collectionView.cellForItem(at: previousIndexPath) as? ImageCell { /// old index
                if let previousPhoto = dataSource.itemIdentifier(for: previousIndexPath) {
                    if let model = previousPhoto.editableModel {
                        cell.cacheImageView.alpha = model.isDeepSearched ? 1 : 0
                        cell.starImageView.alpha = model.isHearted ? 1 : 0
                        cell.shadowImageView.alpha = (model.isDeepSearched || model.isHearted) ? 1 : 0
                    }
                }
            }
        }
        let currentPhoto = allPhotosToDisplay[newIndex]
        if let newIndexPath = dataSource.indexPath(for: currentPhoto) {
            if let cell = collectionView.cellForItem(at: newIndexPath) as? ImageCell { /// new index
                if let model = currentPhoto.editableModel {
                    if model.isHearted || model.isDeepSearched {
                        cell.shadowImageView.alpha = 0
                    }
                    if model.isHearted {
                        cell.starImageView.alpha = 0
                    }
                    if model.isDeepSearched {
                        cell.cacheImageView.alpha = 0
                    }
                }
            }
            selectedIndexPath = newIndexPath
            collectionView.scrollToItem(at: newIndexPath, at: .centeredVertically, animated: false)
        }
    }
}
