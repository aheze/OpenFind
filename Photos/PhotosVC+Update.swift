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
        for photo in photos {
            guard let metadata = photo.metadata else { return }
            
            if let slidesState = model.slidesState {
                if self.searchNavigationProgressViewModel.percentageShowing {
                    self.searchNavigationProgressViewModel.finishAutoProgress()
                    
                    if
                        let index = slidesState.getSlidesPhotoIndex(photo: photo),
                        let slidesPhoto = slidesState.slidesPhotos[safe: index]
                    {
                        slidesState.viewController?.find(in: slidesPhoto)
                    }
                    Find.prioritizedAction = nil
                }
            } else if let resultsState = model.resultsState {
                let (highlights, lines) = self.getHighlightsAndDescription(
                    from: metadata.sentences,
                    with: searchViewModel.stringToGradients
                )
                if highlights.count >= 1 {
                    let highlightsSet = FindPhoto.HighlightsSet(stringToGradients: self.searchViewModel.stringToGradients, highlights: highlights)
                    
                    if let index = resultsState.getFindPhotoIndex(for: photo, in: \.displayedFindPhotos) {
                        model.resultsState?.displayedFindPhotos[index].highlightsSet = highlightsSet
//                        model.resultsState?.displayedFindPhotos[index].associatedViewController?.highlightsViewModel.update(with: highlights, replace: true)
                    }

                    let thumbnail = self.model.photoToThumbnail[photo] ?? nil
                    let findPhoto = FindPhoto(
                        id: UUID(),
                        photo: photo,
                        thumbnail: thumbnail,
                        highlightsSet: highlightsSet,
                        descriptionText: description,
                        descriptionLines: lines
                    )
                    
                    if let index = resultsState.getFindPhotoIndex(for: photo, in: \.allFindPhotos) {
                        model.resultsState?.allFindPhotos[index].highlightsSet = highlightsSet
                    } else {
                        model.resultsState?.allFindPhotos.append(findPhoto)
                    }

                    if let index = resultsState.getFindPhotoIndex(for: photo, in: \.starredFindPhotos) {
                        model.resultsState?.starredFindPhotos[index].highlightsSet = highlightsSet
                    } else {
                        model.resultsState?.starredFindPhotos.append(findPhoto)
                    }

                    if let index = resultsState.getFindPhotoIndex(for: photo, in: \.screenshotsFindPhotos) {
                        model.resultsState?.screenshotsFindPhotos[index].highlightsSet = highlightsSet
                    } else {
                        model.resultsState?.screenshotsFindPhotos.append(findPhoto)
                    }
                    
                    let filter = sliderViewModel.selectedFilter ?? .all
                    switch filter {
                    case .starred:
                        if let starredFindPhotos = model.resultsState?.starredFindPhotos {
                            model.resultsState?.displayedFindPhotos = starredFindPhotos
                        }
                    case .screenshots:
                        if let screenshotsFindPhotos = model.resultsState?.screenshotsFindPhotos {
                            model.resultsState?.displayedFindPhotos = screenshotsFindPhotos
                        }
                    case .all:
                        if let allFindPhotos = model.resultsState?.allFindPhotos {
                            model.resultsState?.displayedFindPhotos = allFindPhotos
                        }
                    }
                }
            }
        }
        
        /// only add live results when results state isn't nil
        if model.resultsState != nil {
            self.updateResultsCollectionViews()
        }
    }

    /// update the results collection view and the slides collection view
    func updateResultsCollectionViews() {
        self.updateResults()
        self.model.slidesState?.viewController?.update(animate: false)
  
        if
            let slidesState = model.slidesState,
            let currentIndex = slidesState.getCurrentIndex()
        {
            self.model.slidesState?.viewController?.collectionView.scrollToItem(
                at: currentIndex.indexPath,
                at: .centeredHorizontally,
                animated: false
            )
        }
    }
}
