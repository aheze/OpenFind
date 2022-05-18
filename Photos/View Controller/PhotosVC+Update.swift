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
            let realmModel = self.realmModel
            let photos = self.model.photos
            let stringToGradients = self.searchViewModel.stringToGradients
            
            Task.detached {
                
                // TODO: Optimize
                let (
                    allFindPhotos, starredFindPhotos, screenshotsFindPhotos
                ) = Finding.findAndGetFindPhotos(realmModel: realmModel, from: photos, stringToGradients: stringToGradients)
                
                await self.apply(
                    allFindPhotos: allFindPhotos,
                    starredFindPhotos: starredFindPhotos,
                    screenshotsFindPhotos: screenshotsFindPhotos,
                    context: .justFindFromExistingDoNotScan
                )
            }
        }
    }
}
