//
//  PhotosVC+UpdateForNewPhotos.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/17/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

/**
 Update after new photos were added
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
                        /// after scanning done, find
                        slidesState.viewController?.findFromMetadata(in: slidesPhoto, viewController: viewController, animate: false)
                        
                        /// then display the prompt
                        slidesState.viewController?.updatePromptForCurrentPhoto()
                    }
                }
                    
                Find.prioritizedAction = nil
            }
            
            /// **Scenario 2:** searching inside results screen while scanning
        } else if let resultsState = model.resultsState {
            let realmModel = self.realmModel
            let stringToGradients = self.searchViewModel.stringToGradients
            
            let existingAllFindPhotos = resultsState.allFindPhotos
            let existingStarredFindPhotos = resultsState.starredFindPhotos
            let existingScreenshotsFindPhotos = resultsState.screenshotsFindPhotos
            
            let photosResultsInsertNewMode = Settings.Values.PhotosResultsInsertNewMode(rawValue: realmModel.photosResultsInsertNewMode)
            
            Task.detached {
                let (
                    allFindPhotos, starredFindPhotos, screenshotsFindPhotos
                ) = Finding.findAndGetFindPhotos(
                    realmModel: realmModel,
                    from: photos,
                    stringToGradients: stringToGradients
                )
                
                /// just use `uniqued` instead of `FindPhoto.merge` - results should only be in text, so no need to check overlap between notes/text
                if
                    let photosResultsInsertNewMode = photosResultsInsertNewMode,
                    photosResultsInsertNewMode == .top
                {
                    await self.startApplyingResults(
                        allFindPhotos: (allFindPhotos + existingAllFindPhotos).uniqued(),
                        starredFindPhotos: (starredFindPhotos + existingStarredFindPhotos).uniqued(),
                        screenshotsFindPhotos: (screenshotsFindPhotos + existingScreenshotsFindPhotos).uniqued(),
                        context: .justFindFromExistingDoNotScan
                    )
                } else {
                    await self.startApplyingResults(
                        allFindPhotos: (existingAllFindPhotos + allFindPhotos).uniqued(),
                        starredFindPhotos: (existingStarredFindPhotos + starredFindPhotos).uniqued(),
                        screenshotsFindPhotos: (existingScreenshotsFindPhotos + screenshotsFindPhotos).uniqued(),
                        context: .justFindFromExistingDoNotScan
                    )
                }
            }
        }
    }
}
