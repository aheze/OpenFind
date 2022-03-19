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
    func addSentences(of photo: Photo, immediately: Bool) {
        if immediately {
            applyMetadata(for: photo)
            photosWithQueuedSentencesAdded?([photo])
        } else {
            scheduleUpdate(for: photo)
        }
    }

    func scheduleUpdate(for photo: Photo) {
        photosWithQueuedSentences.append(photo)

        if canUpdateDueToTimeout() {
            if updateAllowed {
                addQueuedSentencesToMetadatas()
            } else {
                updateState = .waitingForPermission
            }
        } else {
            if updateState == nil {
                updateState = .scheduled
                DispatchQueue.main.asyncAfter(deadline: .now() + PhotosConstants.minimumResultsUpdateDuration) {
                    if self.updateAllowed {
                        self.addQueuedSentencesToMetadatas()
                    } else {
                        self.updateState = .waitingForPermission
                    }
                }
            }
        }
    }

    /// update each array's photo metadata to include sentences
    func addQueuedSentencesToMetadatas() {
        updateState = nil

        for photo in photosWithQueuedSentences {
            applyMetadata(for: photo)
        }

        photosWithQueuedSentencesAdded?(photosWithQueuedSentences)
        photosWithQueuedSentences.removeAll()
        lastResultsUpdateTime = Date()
    }

    func applyMetadata(for photo: Photo) {
        
        /// apply metadata to a single photo inside an array of photos
        func applyMetadata(in photos: inout [Photo], at index: Int, with metadata: PhotoMetadata?) {
            if photos[index].metadata != nil {
                photos[index].metadata?.isScanned = metadata?.isScanned ?? false
                photos[index].metadata?.sentences = metadata?.sentences ?? []
            } else {
                photos[index].metadata = metadata
            }
        }

        if
            let index = getPhotoIndex(photo: photo),
            let indexPath = getPhotoIndexPath(photo: photo)
        {
            /// if not nil, just modify the changed fields - prevent overriding other properties that might have changed while the queue was waiting

            applyMetadata(in: &photos, at: index, with: photo.metadata)
            applyMetadata(in: &sections[indexPath.section].photos, at: indexPath.item, with: photo.metadata)
        }

        /// these should only be called when the results are already there/exists (the photo was not added dynamically)
        /// If added dynamically, append inside `findAfterQueuedSentencesUpdate` in `PhotosVC+Update`
        if
            let resultsState = resultsState,
            let index = resultsState.getFindPhotoIndex(photo: photo)
        {
            if self.resultsState?.findPhotos[index].photo.metadata != nil {
                self.resultsState?.findPhotos[index].photo.metadata?.isScanned = photo.metadata?.isScanned ?? false
                self.resultsState?.findPhotos[index].photo.metadata?.sentences = photo.metadata?.sentences ?? []
            } else {
                self.resultsState?.findPhotos[index].photo.metadata = photo.metadata
            }
        }

        if
            let slidesState = slidesState,
            let index = slidesState.getFindPhotoIndex(photo: photo)
        {
            if self.slidesState?.findPhotos[index].photo.metadata != nil {
                self.slidesState?.findPhotos[index].photo.metadata?.isScanned = photo.metadata?.isScanned ?? false
                self.slidesState?.findPhotos[index].photo.metadata?.sentences = photo.metadata?.sentences ?? []
            } else {
                self.slidesState?.findPhotos[index].photo.metadata = photo.metadata
            }
        }
    }

    func canUpdateDueToTimeout() -> Bool {
        if let lastResultsUpdateTime = lastResultsUpdateTime {
            /// check if passed minimum duration
            if abs(lastResultsUpdateTime.timeIntervalSinceNow) > PhotosConstants.minimumResultsUpdateDuration {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }
}
