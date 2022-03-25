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
            applySentenceMetadata(for: photo)
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
            applySentenceMetadata(for: photo)
        }

        photosWithQueuedSentencesAdded?(photosWithQueuedSentences)
        photosWithQueuedSentences.removeAll()
        lastResultsUpdateTime = Date()
    }

    func applySentenceMetadata(for photo: Photo) {
        /// apply metadata to a single photo inside an array of photos
        /// only modify the changed properties `dateScanned` and `sentences`
        func applyMetadata(in photos: inout [Photo], at index: Int, with metadata: PhotoMetadata?) {
            if photos[index].metadata != nil {
                photos[index].metadata?.dateScanned = metadata?.dateScanned
                photos[index].metadata?.sentences = metadata?.sentences ?? []
            } else {
                photos[index].metadata = metadata
            }
        }

        if let index = getPhotoIndex(photo: photo) {
            /// if `index` is not nil, just modify the changed properties - prevent overriding other properties that might have changed while the queue was waiting
            applyMetadata(in: &photos, at: index, with: photo.metadata)
        }

        if let indexPath = getIndexPath(for: photo, in: \.displayedSections) {
            applyMetadata(in: &displayedSections[indexPath.section].photos, at: indexPath.item, with: photo.metadata)
        }

        if let indexPath = getIndexPath(for: photo, in: \.allSections) {
            applyMetadata(in: &allSections[indexPath.section].photos, at: indexPath.item, with: photo.metadata)
        }
        if let indexPath = getIndexPath(for: photo, in: \.starredSections) {
            applyMetadata(in: &starredSections[indexPath.section].photos, at: indexPath.item, with: photo.metadata)
        }
        if let indexPath = getIndexPath(for: photo, in: \.screenshotsSections) {
            applyMetadata(in: &screenshotsSections[indexPath.section].photos, at: indexPath.item, with: photo.metadata)
        }

        /// these should only be called when the results are already there/exists (the photo was not added dynamically)
        /// If added dynamically, append inside `findAfterQueuedSentencesUpdate` in `PhotosVC+Update`
        if let resultsState = resultsState {
            if let index = resultsState.getFindPhotoIndex(for: photo, in: \.displayedFindPhotos) {
                self.resultsState?.displayedFindPhotos.applyMetadata(at: index, with: photo.metadata)
            }

            if let index = resultsState.getFindPhotoIndex(for: photo, in: \.allFindPhotos) {
                self.resultsState?.allFindPhotos.applyMetadata(at: index, with: photo.metadata)
            }

            if let index = resultsState.getFindPhotoIndex(for: photo, in: \.starredFindPhotos) {
                self.resultsState?.starredFindPhotos.applyMetadata(at: index, with: photo.metadata)
            }

            if let index = resultsState.getFindPhotoIndex(for: photo, in: \.screenshotsFindPhotos) {
                self.resultsState?.screenshotsFindPhotos.applyMetadata(at: index, with: photo.metadata)
            }
        }

        if
            let slidesState = slidesState,
            let index = slidesState.getFindPhotoIndex(photo: photo)
        {
            self.slidesState?.findPhotos.applyMetadata(at: index, with: photo.metadata)
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
