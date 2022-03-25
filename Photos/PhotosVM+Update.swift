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
    /// Update realm and reload cell if needed
    /// This does not add append/remove photos from starred. To update that, use `sort`.
    func updatePhotoMetadata(photo: Photo, reloadCell: Bool) {
        /// for reloading at a specific index path
        /// 1. Index path inside `collectionView`
        /// 2. Index inside `resultsCollectionView`
        var collectionViewIndexPath: IndexPath?
        var resultsCollectionViewIndex: Int?

        /// update the main array
        if let index = getPhotoIndex(photo: photo) {
            photos[index] = photo
        }

        /// update displayed collection view
        if let indexPath = getIndexPath(for: photo, in: \.displayedSections) {
            collectionViewIndexPath = indexPath
            displayedSections[indexPath.section].photos[indexPath.item] = photo
        }

        if let indexPath = getIndexPath(for: photo, in: \.allSections) {
            allSections[indexPath.section].photos[indexPath.item] = photo
        }
        if let indexPath = getIndexPath(for: photo, in: \.starredSections) {
            starredSections[indexPath.section].photos[indexPath.item] = photo
        }
        if let indexPath = getIndexPath(for: photo, in: \.screenshotsSections) {
            screenshotsSections[indexPath.section].photos[indexPath.item] = photo
        }

        if let resultsState = resultsState {
            if let index = resultsState.getFindPhotoIndex(for: photo, in: \.displayedFindPhotos) {
                resultsCollectionViewIndex = index
                self.resultsState?.displayedFindPhotos[index].photo = photo
            }

            if let index = resultsState.getFindPhotoIndex(for: photo, in: \.allFindPhotos) {
                self.resultsState?.allFindPhotos[index].photo = photo
            }

            if let index = resultsState.getFindPhotoIndex(for: photo, in: \.starredFindPhotos) {
                self.resultsState?.starredFindPhotos[index].photo = photo
            }

            if let index = resultsState.getFindPhotoIndex(for: photo, in: \.screenshotsFindPhotos) {
                self.resultsState?.screenshotsFindPhotos[index].photo = photo
            }
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
        ignoredPhotos = photos.filter { $0.metadata?.isIgnored ?? false }
        photosToScan = photos.filter { $0.metadata.map { !$0.isIgnored && $0.dateScanned == nil } ?? true }
    }
}
