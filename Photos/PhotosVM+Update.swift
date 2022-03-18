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
            print("Error deleting all: \(error)")
        }

        self.load()
    }

    /// `photo.metadata` should be the new metadata
    /// `isNew` determines whether to add or update realm
    func updatePhotoMetadata(photo: Photo, reloadCell: Bool, isNew: Bool) {
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
            slidesCollectionViewIndex = index
            self.slidesState?.findPhotos[index].photo = photo
        }

        guard let metadata = photo.metadata else { return }

        if reloadCell {
            reloadAt?(collectionViewIndexPath, resultsCollectionViewIndex, slidesCollectionViewIndex, metadata)
        }

        if isNew {
            realmModel.addPhotoMetadata(metadata: metadata)
        } else {
            realmModel.updatePhotoMetadata(metadata: metadata)
        }
    }
}
