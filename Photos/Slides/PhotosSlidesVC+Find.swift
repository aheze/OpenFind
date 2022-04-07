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
    func startFinding(for slidesPhoto: SlidesPhoto) {
        /// if is ignored, don't find
        guard slidesPhoto.findPhoto.photo.metadata.map({ !$0.isIgnored }) ?? true else {
            slidesSearchPromptViewModel.update(show: true, resultsText: "Photo is ignored")
            slidesSearchPromptViewModel.updateBarHeight?()
            return
        }

        if let metadata = slidesPhoto.findPhoto.photo.metadata, metadata.dateScanned != nil {
            self.findFromMetadata(in: slidesPhoto)
        } else {
            self.scanPhoto(slidesPhoto: slidesPhoto)
        }
    }
    
    func scanPhoto(slidesPhoto: SlidesPhoto) {
        Find.prioritizedAction = .individualPhoto
        self.searchNavigationProgressViewModel.start(progress: .auto(estimatedTime: 1.5))

        var findOptions = FindOptions()
        findOptions.priority = .waitUntilNotBusy
        findOptions.action = .individualPhoto
        self.model.scanPhoto(slidesPhoto.findPhoto.photo, findOptions: findOptions, inBatch: false)
    }

    /// find and show results, if there is text in the slides search view model
    func findFromMetadata(in slidesPhoto: SlidesPhoto) {
        guard let metadata = slidesPhoto.findPhoto.photo.metadata else { return }
        guard !slidesSearchViewModel.isEmpty else { return }
        let highlights = metadata.sentences.getHighlights(stringToGradients: self.slidesSearchViewModel.stringToGradients)

        let highlightSet = FindPhoto.HighlightsSet(
            stringToGradients: self.slidesSearchViewModel.stringToGradients,
            highlights: highlights
        )

        getViewController(for: slidesPhoto.findPhoto.photo)?.highlightsViewModel.update(with: highlights, replace: true)
        if let slidesState = model.slidesState, let index = slidesState.getSlidesPhotoIndex(photo: slidesPhoto.findPhoto.photo) {
            self.model.slidesState?.slidesPhotos[index].findPhoto.highlightsSet = highlightSet

            let resultsText = self.model.slidesState?.slidesPhotos[index].findPhoto.getResultsText() ?? ""
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
