//
//  PhotosSlidesVC+Find.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension PhotosSlidesViewController {
    /// start finding for a photo.
    /// If metadata does not exist, start scanning.
    /// Once done, `model.photosWithQueuedSentencesAdded` in `PhotosVC+Listen` will be called.
    func startFinding(for slidesPhoto: SlidesPhoto, viewController: PhotosSlidesItemViewController, animate: Bool) {
        let photoIgnored = slidesPhoto.findPhoto.photo.isIgnored
        if
            let metadata = slidesPhoto.findPhoto.photo.metadata,
            metadata.dateScanned != nil || photoIgnored /// find from metadata even if ignored (show prompt)
        {
            self.findFromMetadata(in: slidesPhoto, viewController: viewController, animate: animate)
        } else {
            /// if is ignored, don't scan
            if !photoIgnored {
                self.scanPhoto(slidesPhoto: slidesPhoto)
            }
        }
    }

    /// find and show results, if there is text in the slides search view model
    func findFromMetadata(in slidesPhoto: SlidesPhoto, viewController: PhotosSlidesItemViewController, animate: Bool) {
        guard let metadata = slidesPhoto.findPhoto.photo.metadata else { return }
        guard !slidesSearchViewModel.isEmpty else { return }
        let highlights = metadata.sentences.getHighlights(
            stringToGradients: self.slidesSearchViewModel.stringToGradients,
            realmModel: realmModel
        )

        let highlightSet = FindPhoto.HighlightsSet(
            stringToGradients: self.slidesSearchViewModel.stringToGradients,
            highlights: highlights
        )

        if animate {
            viewController.highlightsViewModel.update(with: highlights, replace: true)
        } else {
            viewController.highlightsViewModel.highlights = highlights
        }

        if let slidesState = model.slidesState, let index = slidesState.getSlidesPhotoIndex(photo: slidesPhoto.findPhoto.photo) {
            self.model.slidesState?.slidesPhotos[index].findPhoto.highlightsSet = highlightSet
        }

        self.updatePrompt(for: slidesPhoto.findPhoto.photo)
    }

    func scanPhoto(slidesPhoto: SlidesPhoto) {
        Find.prioritizedAction = .individualPhoto
        self.searchNavigationProgressViewModel.start(progress: .auto(estimatedTime: 1.5))

        var findOptions = FindOptions()
        findOptions.priority = .waitUntilNotBusy
        findOptions.action = .individualPhoto
        self.model.scanPhoto(slidesPhoto.findPhoto.photo, findOptions: findOptions, inBatch: false)
    }

    func updatePrompt(for currentPhoto: Photo) {
        guard !slidesSearchViewModel.isEmpty else { return }
        guard
            let slidesPhotoIndex = model.slidesState?.getSlidesPhotoIndex(photo: currentPhoto),
            let slidesPhoto = model.slidesState?.slidesPhotos[safe: slidesPhotoIndex]
        else { return }

        if slidesPhoto.findPhoto.photo.isIgnored {
            slidesSearchPromptViewModel.update(show: true, resultsText: "Photo is ignored")
            slidesSearchPromptViewModel.updateBarHeight?()
        } else {
            let resultsText = slidesPhoto.findPhoto.getResultsText()
            var resetText: String?
            if model.resultsState != nil, searchViewModel.text != slidesSearchViewModel.text {
                let summary = searchViewModel.getSummaryString()
                resetText = summary
            }

            slidesSearchPromptViewModel.update(show: true, resultsText: resultsText, resetText: resetText)
            slidesSearchPromptViewModel.updateBarHeight?()
        }
    }
}
