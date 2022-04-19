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
    func findAfterQueuedSentencesUpdate(in photos: [Photo]) async {
        /// **Scenario 1:** searching inside a single photo in slides
        if let slidesState = model.slidesState {
            if self.searchNavigationProgressViewModel.percentageShowing {
                self.searchNavigationProgressViewModel.finishAutoProgress()
                    
                if
                    let photo = photos.first,
                    let index = slidesState.getSlidesPhotoIndex(photo: photo),
                    let slidesPhoto = slidesState.slidesPhotos[safe: index]
                {
                    if let viewController = slidesState.viewController?.getViewController(for: slidesPhoto.findPhoto.photo) {
                        slidesState.viewController?.findFromMetadata(in: slidesPhoto, viewController: viewController, animate: false)
                    }
                }
                    
                Find.prioritizedAction = nil
            }
            
            /// **Scenario 2:** searching inside results screen while scanning
        } else if model.resultsState != nil {
            let displayedFindPhotos: [FindPhoto]
//            let (allFindPhotos, starredFindPhotos, screenshotsFindPhotos) = await self.findAndGetFindPhotos(realmModel: realmModel, from: photos)
//
//            switch sliderViewModel.selectedFilter ?? .all {
//            case .starred:
//                displayedFindPhotos = starredFindPhotos
//            case .screenshots:
//                displayedFindPhotos = screenshotsFindPhotos
//            case .all:
//                displayedFindPhotos = allFindPhotos
//            }
//
//            model.resultsState?.displayedFindPhotos.insert(contentsOf: displayedFindPhotos, at: 0)
//            model.resultsState?.starredFindPhotos.insert(contentsOf: starredFindPhotos, at: 0)
//            model.resultsState?.screenshotsFindPhotos.insert(contentsOf: screenshotsFindPhotos, at: 0)
//            model.resultsState?.allFindPhotos.insert(contentsOf: allFindPhotos, at: 0)
//
//            /// only add live results when results state isn't nil
//            /// updates can't occur when slides are shown, so no need to update `slidesState`
//            self.updateResults()
        }
    }
}
