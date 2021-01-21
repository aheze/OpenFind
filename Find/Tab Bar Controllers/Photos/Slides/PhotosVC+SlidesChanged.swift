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
        
        sortPhotos(with: currentFilter)
        applySnapshot(animatingDifferences: false)
        
        
//        if let indexPath = dataSource.indexPath(for: findPhoto) {
//            print("has index")
//            if let cell = collectionView.cellForItem(at: indexPath) as? ImageCell {
//                if let model = findPhoto.editableModel {
//                    if model.isDeepSearched {
//                        cell.cacheImageView.image = UIImage(named: "CacheActive-Light")
//                    } else {
//                        cell.cacheImageView.image = nil
//                    }
//                    if model.isHearted {
//                        cell.starImageView.image = UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysTemplate)
//                    } else {
//                        cell.starImageView.image = nil
//                    }
//                    if model.isDeepSearched || model.isHearted {
//                        cell.shadowImageView.image = UIImage(named: "DownShadow")
//                    } else {
//                        cell.shadowImageView.image = nil
//                    }
//                } else {
//                    cell.cacheImageView.image = nil
//                    cell.starImageView.image = nil
//                    cell.shadowImageView.image = nil
//                }
////                sortPhotos(with: currentFilter)
////                applySnapshot(animatingDifferences: true)
//            }
//        }
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
                        cell.shadowImageView.alpha = (model.isDeepSearched || model.isHearted ) ? 1 : 0
                    }
                }
            }
        }
        let currentPhoto = allPhotosToDisplay[newIndex]
        if let newIndexPath = dataSource.indexPath(for: currentPhoto) {
            if let cell = collectionView.cellForItem(at: newIndexPath) as? ImageCell { /// new index
                if let model = currentPhoto.editableModel {
                    if model.isHearted || model.isDeepSearched  {
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
