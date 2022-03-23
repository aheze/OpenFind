//
//  PhotosVM+Update.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension PhotosViewModel {
    func deleteAllMetadata() {
        let metadatas = realmModel.realm.objects(RealmPhotoMetadata.self)

        do {
            try realmModel.realm.write {
                realmModel.realm.delete(metadatas)
            }
        } catch {
            Debug.log("Error deleting all metadata: \(error)", .error)
        }

        self.load()
    }

    /// `photo.metadata` should be the new metadata
    func updatePhotoMetadata(photo: Photo, reloadCell: Bool) {
        /// for reloading at a specific index path
        /// 1. Index path inside `collectionView`
        /// 2. Index inside `resultsCollectionView`
        var collectionViewIndexPath: IndexPath?
        var resultsCollectionViewIndex: Int?

        if
            let index = getPhotoIndex(photo: photo),
            let indexPath = getPhotoIndexPath(photo: photo)
        {
            collectionViewIndexPath = indexPath
            photos[index] = photo
            sections[indexPath.section].photos[indexPath.item] = photo
        }

        if
            let resultsState = resultsState,
            let index = resultsState.getFindPhotoIndex(photo: photo)
        {
            resultsCollectionViewIndex = index
            self.resultsState?.findPhotos[index].photo = photo
        }

        if
            let slidesState = slidesState,
            let index = slidesState.getFindPhotoIndex(photo: photo)
        {

            /// must update `currentPhoto` as well
            if let currentIndex = slidesState.getCurrentIndex() {
                if currentIndex == index {
                    self.slidesState?.currentPhoto = photo
                }
            }
            self.slidesState?.findPhotos[index].photo = photo
        }

        guard let metadata = photo.metadata else { return }

        if reloadCell {
            
            /// inside `PhotosVC+Listen`
            reloadAt?(collectionViewIndexPath, resultsCollectionViewIndex, metadata)
        }

        realmModel.updatePhotoMetadata(metadata: metadata)
    }
}
