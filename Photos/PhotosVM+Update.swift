//
//  PhotosVM+Update.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension PhotosViewModel {
    func updatePhotoMetadata(photo: Photo, metadata: PhotoMetadata, reloadCell: Bool) {
        /// for reloading at a specific index path
        /// 1. Index path inside `collectionView`
        /// 2. Index inside `resultsCollectionView`
        var collectionViewIndexPath: IndexPath?
        var resultsCollectionViewIndex: Int?
        var slidesCollectionViewIndex: Int?

        if
            let index = getPhotoIndex(photo: photo),
            let indexPath = getPhotoIndexPath(photo: photo)
        {
            collectionViewIndexPath = indexPath
            photos[index].metadata = metadata
            sections[indexPath.section].photos[indexPath.item].metadata = metadata

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
                
                print("updating index \(index) metadata. \(self.slidesState?.findPhotos[index].photo.metadata)")
            }
        }

        if reloadCell {
            reloadAt?(collectionViewIndexPath, resultsCollectionViewIndex, slidesCollectionViewIndex, metadata)
        }

        if photo.metadata == nil {
            realmModel.addPhotoMetadata(metadata: metadata)
        } else {
            realmModel.updatePhotoMetadata(metadata: metadata)
        }
    }
}
