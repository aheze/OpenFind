//
//  PhotosVM+Delete.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/26/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import UIKit

extension PhotosViewModel {
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
                        self.realmModel.deletePhotoMetadata(metadata: metadata)
                    }
                }
                self.refresh(afterDeleting: photos)
                self.reloadCollectionViewsAfterDeletion?()
                if let photo = photos.first {
                    self.deletePhotoInSlides?(photo)
                }
                self.ignoredPhotos = photos.filter { $0.metadata?.isIgnored ?? false }
                self.photosToScan = photos.filter { $0.metadata.map { !$0.isIgnored && $0.dateScanned == nil } ?? true }
            }
        }
    }

    func refresh(afterDeleting photos: [Photo]) {
        self.photos = self.photos.filter { !photos.contains($0) }

        deletePhotos(deletedPhotos: photos, in: &displayedSections)
        deletePhotos(deletedPhotos: photos, in: &allSections)
        deletePhotos(deletedPhotos: photos, in: &starredSections)
        deletePhotos(deletedPhotos: photos, in: &screenshotsSections)
        if resultsState != nil {
            deletePhotos(deletedPhotos: photos, in: \PhotosResultsState.displayedFindPhotos)
            deletePhotos(deletedPhotos: photos, in: \PhotosResultsState.allFindPhotos)
            deletePhotos(deletedPhotos: photos, in: \PhotosResultsState.starredFindPhotos)
            deletePhotos(deletedPhotos: photos, in: \PhotosResultsState.screenshotsFindPhotos)
        }


        /// if `slidesState` exists, then it must be a singular photo that's deleted.
//        if let slidesState = slidesState {
//            /// check indices before deletion
//            if let currentIndex = slidesState.getCurrentIndex() {
//                var slidesTargetIndexBeforeDeletion: Int?
//                var slidesTargetIndexAfterDeletion: Int?
//                if slidesState.findPhotos.count == 1 { /// last photo. After deletion, go back to the collection view.
//                    slidesTargetIndexBeforeDeletion = nil
//                    slidesTargetIndexAfterDeletion = nil
//                } else if currentIndex == slidesState.findPhotos.count - 1 { /// rightmost photo
//                    slidesTargetIndexBeforeDeletion = currentIndex - 1
//
//                    /// no need for this actually, will already be scrolled here.
//                    /// But `reloadAfterDeletion` checks for both `slidesTargetIndexBeforeDeletion` and `slidesTargetIndexAfterDeletion` being not nil,
//                    /// so set this too.
//                    slidesTargetIndexAfterDeletion = currentIndex - 1
//                } else {
//                    slidesTargetIndexBeforeDeletion = currentIndex + 1 /// photo slides in from the right
//                    slidesTargetIndexAfterDeletion = currentIndex
//                }
//
//                self.slidesTargetIndexBeforeDeletion = slidesTargetIndexBeforeDeletion
//                self.slidesTargetIndexAfterDeletion = slidesTargetIndexAfterDeletion
//            }
//
//            deletePhotos(deletedPhotos: photos, in: \PhotosSlidesState.findPhotos)
//        }
    }

    func deletePhotos(deletedPhotos: [Photo], in sections: inout [PhotosSection]) {
        var newSections = [PhotosSection]()
        for sectionIndex in sections.indices {
            var section = sections[sectionIndex]
            let photos = section.photos.filter { !deletedPhotos.contains($0) }
            section.photos = photos
            newSections.append(section)
        }
        let filteredSections = newSections.filter { !$0.photos.isEmpty }
        sections = filteredSections
    }

    func deletePhotos(deletedPhotos: [Photo], in keyPath: WritableKeyPath<PhotosResultsState, [FindPhoto]>) {
        let photos = resultsState?[keyPath: keyPath].filter { !deletedPhotos.contains($0.photo) } ?? []
        resultsState?[keyPath: keyPath] = photos
    }

    func deletePhotos(deletedPhotos: [Photo], in keyPath: WritableKeyPath<PhotosSlidesState, [FindPhoto]>) {
        let photos = slidesState?[keyPath: keyPath].filter { !deletedPhotos.contains($0.photo) } ?? []
        slidesState?[keyPath: keyPath] = photos
    }
}
