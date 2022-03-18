//
//  PhotosVM+Add.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

/// Separate add from update
extension PhotosViewModel {
    /// unlike `updatePhotoMetadata`, this doesn't have a `metadata: PhotoMetadata` parameter.
    /// Instead, the photo should already be loaded with metadata.
    func addPhotoMetadata(photo: Photo, reloadCell: Bool) {
        print("adding metadata! \(photo.metadata != nil)")
        guard let metadata = photo.metadata else { return }

        /// for reloading at a specific index path
        /// 1. Index path inside `collectionView`
        /// 2. Index inside `resultsCollectionView`
        var collectionViewIndexPath: IndexPath?
        var resultsCollectionViewIndex: Int?
        var slidesCollectionViewIndex: Int?

        /// update the main collection view
        if
            let index = getPhotoIndex(photo: photo),
            let indexPath = getPhotoIndexPath(photo: photo)
        {
            collectionViewIndexPath = indexPath
            photos[index] = photo
            sections[indexPath.section].photos[indexPath.item] = photo
        }

        /// currently in finding mode
        if self.resultsState != nil, metadata.isScanned {
            print("finding currently.")
            metadataAddedFor?(photo)
        }
        
        if
            let resultsState = resultsState,
            let index = resultsState.getFindPhotoIndex(photo: photo)
        {
            resultsCollectionViewIndex = index
            self.resultsState?.findPhotos[index].photo.metadata = metadata
        }

        if
            let slidesState = slidesState,
            let index = slidesState.getFindPhotoIndex(photo: photo)
        {
            slidesCollectionViewIndex = index
            self.slidesState?.findPhotos[index].photo.metadata = metadata
        }

        if reloadCell {
            reloadAt?(collectionViewIndexPath, resultsCollectionViewIndex, slidesCollectionViewIndex, metadata)
        }

        realmModel.addPhotoMetadata(metadata: metadata)
    }
}
