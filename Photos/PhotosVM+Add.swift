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
    func addSentences(of photo: Photo) {
        self.scheduleUpdate(for: photo)
    }

    func scheduleUpdate(for photo: Photo) {
        photosWithQueuedSentences.append(photo)
        if self.shouldUpdate() {
            self.addQueuedSentencesToMetadatas()
        } else {
            if !updateScheduled {
                updateScheduled = true
                DispatchQueue.main.asyncAfter(deadline: .now() + PhotosConstants.minimumResultsUpdateDuration) {
                    self.addQueuedSentencesToMetadatas()
                }
            }
        }
    }

    /// update metadata to include sentences
    func addQueuedSentencesToMetadatas() {
        updateScheduled = false

        for photo in photosWithQueuedSentences {
            if
                let index = getPhotoIndex(photo: photo),
                let indexPath = getPhotoIndexPath(photo: photo)
            {
                photos[index].metadata?.isScanned = photo.metadata?.isScanned ?? false
                photos[index].metadata?.sentences = photo.metadata?.sentences ?? []
                sections[indexPath.section].photos[indexPath.item].metadata?.isScanned = photo.metadata?.isScanned ?? false
                sections[indexPath.section].photos[indexPath.item].metadata?.sentences = photo.metadata?.sentences ?? []
            }

            /// these should only be called when the results are already there (the photo was not added live)
            if
                let resultsState = resultsState,
                let index = resultsState.getFindPhotoIndex(photo: photo)
            {
                print("         Results exists: index \(index)")
                self.resultsState?.findPhotos[index].photo.metadata?.isScanned = photo.metadata?.isScanned ?? false
                self.resultsState?.findPhotos[index].photo.metadata?.sentences = photo.metadata?.sentences ?? []
            } else {
                print("         Results DOES NOT exist.")
            }

            if
                let slidesState = slidesState,
                let index = slidesState.getFindPhotoIndex(photo: photo)
            {
                print("         Slides exists: index \(index)")
                self.slidesState?.findPhotos[index].photo.metadata?.isScanned = photo.metadata?.isScanned ?? false
                self.slidesState?.findPhotos[index].photo.metadata?.sentences = photo.metadata?.sentences ?? []
            } else {
                print("      Slides DOES NOT exist.")
            }
        }

        photosWithQueuedSentencesAdded?(photosWithQueuedSentences)
        photosWithQueuedSentences.removeAll()
        lastResultsUpdateTime = Date()
    }

    func shouldUpdate() -> Bool {
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
