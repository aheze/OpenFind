//
//  PhotosVM+Actions.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/10/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI
import Photos

/**
 Star / Ignore
 */

extension PhotosViewModel {
    func share(photos: [Photo]) {
        self.sharePhotos?(photos)
    }

    /// toggle star for a single photo. If multiple photos and one photo is unstarred, star all.
    /// **must** also call `self?.model.updateAfterStarChange()` after this function to reload collection views.
    /// Unless - in slides, in which case set `sortNeededAfterStarChanged = true`.
    func star(photos: [Photo]) {
        let photosStarred: [Bool] = photos.map {
            let starred = $0.metadata.map { $0.isStarred } ?? false
            return starred
        }

        let shouldStar = photosStarred.contains(false)

        for photo in photos {
            var newPhoto = photo
            if newPhoto.metadata != nil {
                newPhoto.metadata?.isStarred = shouldStar
                updatePhotoMetadata(photo: newPhoto, reloadCell: true)
            } else {
                let metadata = PhotoMetadata(
                    assetIdentifier: photo.asset.localIdentifier,
                    dateScanned: nil,
                    sentences: [],
                    scannedInLanguages: [],
                    isStarred: shouldStar,
                    isIgnored: false
                )
                newPhoto.metadata = metadata
                updatePhotoMetadata(photo: newPhoto, reloadCell: true)
            }
        }
    }

    func ignore(photos: [Photo]) {
        /// see which of the passed-in photos are ignored
        let photosIgnored: [Bool] = photos.map {
            let ignored = $0.isIgnored
            return ignored
        }

        let shouldIgnore = photosIgnored.contains(false)

        for photo in photos {
            var newPhoto = photo
            /// metadata exists, delete sentences
            if newPhoto.metadata != nil {
                newPhoto.metadata?.isIgnored = shouldIgnore
                newPhoto.metadata?.dateScanned = nil /// delete saved sentences anyway
                newPhoto.metadata?.sentences = []
                withAnimation {
                    updatePhotoMetadata(photo: newPhoto, reloadCell: true)
                }
            } else {
                let metadata = PhotoMetadata(
                    assetIdentifier: photo.asset.localIdentifier,
                    dateScanned: nil,
                    sentences: [],
                    scannedInLanguages: [],
                    isStarred: false,
                    isIgnored: shouldIgnore
                )
                newPhoto.metadata = metadata
                withAnimation {
                    updatePhotoMetadata(photo: newPhoto, reloadCell: true)
                }
            }
        }
    }

    func delete(photos: [Photo]) {
        let assetIdentifiers = photos.map { $0.asset.localIdentifier }
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: assetIdentifiers, options: nil)
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets(assets)
        } completionHandler: { [weak self] success, _ in
            guard success else { return }
            guard let self = self else { return }

            DispatchQueue.main.async {
                for photo in photos {
                    if let metadata = photo.metadata {
                        self.getRealmModel?().container.deletePhotoMetadata(metadata: metadata)
                    }
                }
                self.refreshCollectionViews(afterDeleting: photos)
                self.reloadCollectionViewsAfterDeletion?()

                /// refresh slides model and reload slides collection view
                if let photo = photos.first {
                    self.deletePhotoInSlides?(photo)
                }
                self.ignoredPhotos = photos.filter { $0.isIgnored }
                self.photosToScan = photos.filter { $0.metadata.map { !$0.isIgnored && $0.dateScanned == nil } ?? true }
            }
        }
    }

    // MARK: - Toolbar

    func configureToolbar(for photo: Photo) {
        if let metadata = photo.metadata {
            if metadata.isStarred {
                self.slidesState?.toolbarStarOn = true
                return
            }
        }
        self.slidesState?.toolbarStarOn = false
    }
}
