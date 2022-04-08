//
//  PhotosVC+Update.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/17/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

/**
 Update for finding
 */

extension PhotosViewController {
    /// find after a new photo was scanned
    func findAfterQueuedSentencesUpdate(in photos: [Photo]) {
        /// **Scenario 1:** searching inside a single photo in slides
        if let slidesState = model.slidesState {
            if self.searchNavigationProgressViewModel.percentageShowing {
                self.searchNavigationProgressViewModel.finishAutoProgress()
                    
                if
                    let photo = photos.first,
                    let index = slidesState.getSlidesPhotoIndex(photo: photo),
                    let slidesPhoto = slidesState.slidesPhotos[safe: index]
                {
                    slidesState.viewController?.findFromMetadata(in: slidesPhoto)
                }
                    
                Find.prioritizedAction = nil
            }
            
            /// **Scenario 2:** searching inside results screen while scanning
        } else if model.resultsState != nil {
            let displayedFindPhotos: [FindPhoto]
            let (allFindPhotos, starredFindPhotos, screenshotsFindPhotos) = self.findAndGetFindPhotos(from: photos)
            
            switch sliderViewModel.selectedFilter ?? .all {
            case .starred:
                displayedFindPhotos = starredFindPhotos
            case .screenshots:
                displayedFindPhotos = screenshotsFindPhotos
            case .all:
                displayedFindPhotos = allFindPhotos
            }
            
            model.resultsState?.displayedFindPhotos.insert(contentsOf: displayedFindPhotos, at: 0)
            model.resultsState?.starredFindPhotos.insert(contentsOf: starredFindPhotos, at: 0)
            model.resultsState?.screenshotsFindPhotos.insert(contentsOf: screenshotsFindPhotos, at: 0)
            model.resultsState?.allFindPhotos.insert(contentsOf: allFindPhotos, at: 0)
            
            /// only add live results when results state isn't nil
            /// updates can't occur when slides are shown, so no need to update `slidesState`
            self.updateResults()
        }
    }
}

// extension PhotosViewController {
//    /// find after a new photo was scanned
//    func findAfterQueuedSentencesUpdate(in photos: [Photo]) {
//        for photo in photos {
//            guard let metadata = photo.metadata else { return }
//
//            /// **Scenario 1:** searching inside a single photo in slides
//            if let slidesState = model.slidesState {
//                if self.searchNavigationProgressViewModel.percentageShowing {
//                    self.searchNavigationProgressViewModel.finishAutoProgress()
//
//                    if
//                        let index = slidesState.getSlidesPhotoIndex(photo: photo),
//                        let slidesPhoto = slidesState.slidesPhotos[safe: index]
//                    {
//                        slidesState.viewController?.findFromMetadata(in: slidesPhoto)
//                    }
//
//                    Find.prioritizedAction = nil
//                }
//
//                /// **Scenario 2:** searching inside results screen while scanning
//            } else if let resultsState = model.resultsState {
//                let (highlights, lines) = self.getHighlightsAndDescription(
//                    from: metadata.sentences,
//                    with: searchViewModel.stringToGradients
//                )
//                if highlights.count >= 1 {
//                    let thumbnail = self.model.photoToThumbnail[photo] ?? nil
//                    let highlightsSet = FindPhoto.HighlightsSet(stringToGradients: self.searchViewModel.stringToGradients, highlights: highlights)
//                    let description = getCellDescription(from: lines) /// don't forget this!
//
//                    if let index = resultsState.getFindPhotoIndex(for: photo, in: \.displayedFindPhotos) {
//                        model.resultsState?.displayedFindPhotos[index].highlightsSet = highlightsSet
//                    }
//
//                    let findPhoto = FindPhoto(
//                        id: UUID(),
//                        photo: photo,
//                        thumbnail: thumbnail,
//                        highlightsSet: highlightsSet,
//                        descriptionText: description,
//                        descriptionLines: lines
//                    )
//
//                    if let index = resultsState.getFindPhotoIndex(for: photo, in: \.allFindPhotos) {
//                        model.resultsState?.allFindPhotos[index].highlightsSet = highlightsSet
//                    } else {
//                        model.resultsState?.allFindPhotos.insert(findPhoto, at: 0)
//                    }
//
//                    if let index = resultsState.getFindPhotoIndex(for: photo, in: \.starredFindPhotos) {
//                        model.resultsState?.starredFindPhotos[index].highlightsSet = highlightsSet
//                    } else {
//                        model.resultsState?.starredFindPhotos.insert(findPhoto, at: 0)
//                    }
//
//                    if let index = resultsState.getFindPhotoIndex(for: photo, in: \.screenshotsFindPhotos) {
//                        model.resultsState?.screenshotsFindPhotos[index].highlightsSet = highlightsSet
//                    } else {
//                        model.resultsState?.screenshotsFindPhotos.insert(findPhoto, at: 0)
//                    }
//
//                    let filter = sliderViewModel.selectedFilter ?? .all
//                    switch filter {
//                    case .starred:
//                        if let starredFindPhotos = model.resultsState?.starredFindPhotos {
//                            model.resultsState?.displayedFindPhotos = starredFindPhotos
//                        }
//                    case .screenshots:
//                        if let screenshotsFindPhotos = model.resultsState?.screenshotsFindPhotos {
//                            model.resultsState?.displayedFindPhotos = screenshotsFindPhotos
//                        }
//                    case .all:
//                        if let allFindPhotos = model.resultsState?.allFindPhotos {
//                            model.resultsState?.displayedFindPhotos = allFindPhotos
//                        }
//                    }
//                }
//            }
//        }
//
//        /// only add live results when results state isn't nil
//        /// updates can't occur when slides are shown, so no need to update `slidesState`
//        if model.resultsState != nil {
//            self.updateResults()
//        }
//    }
// }
