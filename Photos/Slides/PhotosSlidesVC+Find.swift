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
    func startFinding(
        for slidesPhoto: SlidesPhoto,
        viewController: PhotosSlidesItemViewController,
        animate: Bool,
        showPromptIfResultsFoundInstantly: Bool /// if finding from metadata, show prompt
    ) {
        var resultsFoundInstantly = false
        if
            let note = realmModel.container.getNote(from: slidesPhoto.findPhoto.photo.asset.localIdentifier),
            var findPhoto = model.slidesState?.getUpToDateSlidesPhoto(for: slidesPhoto.findPhoto.photo)?.findPhoto
        {
            let search = Array(slidesSearchViewModel.stringToGradients.keys)
            let numberOfResultsInNote = Finding.getNumberOfMatches(
                realmModel: realmModel,
                stringToSearchFrom: note.string,
                matches: search
            )

            findPhoto.createDescriptionIfNeeded()
            findPhoto.description?.numberOfResultsInNote = numberOfResultsInNote

            if let index = model.slidesState?.getFindPhotoIndex(findPhoto: findPhoto) {
                model.slidesState?.slidesPhotos[index].findPhoto = findPhoto
            }
            resultsFoundInstantly = true
        }

        let photoIgnored = slidesPhoto.findPhoto.photo.isIgnored
        if
            let metadata = slidesPhoto.findPhoto.photo.metadata,
            metadata.dateScanned != nil || photoIgnored /// find from metadata even if ignored (show prompt)
        {
            self.findFromMetadata(in: slidesPhoto, viewController: viewController, animate: animate)
            resultsFoundInstantly = true
        } else {
            /// if is ignored, don't scan
            if !photoIgnored {
                self.scanPhoto(slidesPhoto: slidesPhoto)
            }
        }

        if resultsFoundInstantly, showPromptIfResultsFoundInstantly {
            self.updatePromptForCurrentPhoto()
        }
    }

    /// find and show results, if there is text in the slides search view model
    func findFromMetadata(in slidesPhoto: SlidesPhoto, viewController: PhotosSlidesItemViewController, animate: Bool) {
        guard let metadata = slidesPhoto.findPhoto.photo.metadata else { return }
        guard !slidesSearchViewModel.isEmpty else { return }

        guard let text = realmModel.container.getText(from: metadata.assetIdentifier) else { return }

        let highlights = text.sentences.getHighlights(
            stringToGradients: self.slidesSearchViewModel.stringToGradients,
            realmModel: realmModel,
            imageSize: slidesPhoto.findPhoto.photo.asset.getSize()
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
            self.model.slidesState?.slidesPhotos[index].findPhoto.createDescriptionIfNeeded()
            self.model.slidesState?.slidesPhotos[index].findPhoto.description?.numberOfResultsInText = highlights.count
            self.model.slidesState?.slidesPhotos[index].findPhoto.highlightsSet = highlightSet
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

    func updatePrompt(for currentPhoto: Photo) {
        guard !slidesSearchViewModel.isEmpty else { return }
        guard
            let slidesPhotoIndex = model.slidesState?.getSlidesPhotoIndex(photo: currentPhoto),
            let slidesPhoto = model.slidesState?.slidesPhotos[safe: slidesPhotoIndex]
        else { return }

        let numberOfResultsInText = slidesPhoto.findPhoto.description?.numberOfResultsInText
        let numberOfResultsInNote = slidesPhoto.findPhoto.description?.numberOfResultsInNote

        if slidesPhoto.findPhoto.photo.isIgnored {
            slidesSearchPromptViewModel.update(
                show: true,
                resultsString: "Photo is ignored",
                numberOfResultsInText: numberOfResultsInText,
                numberOfResultsInNote: numberOfResultsInNote
            )
            slidesSearchPromptViewModel.updateBarHeight?()
        } else {
            let resultsString = slidesPhoto.findPhoto.getResultsString()

            var resetString: String?
            if model.resultsState != nil, searchViewModel.text != slidesSearchViewModel.text {
                let summary = searchViewModel.getSummaryString()
                resetString = summary
            }

            slidesSearchPromptViewModel.update(
                show: true,
                resultsString: resultsString,
                numberOfResultsInText: numberOfResultsInText,
                numberOfResultsInNote: numberOfResultsInNote,
                resetString: resetString
            )
            slidesSearchPromptViewModel.updateBarHeight?()
        }
    }

    /// update prompt for the current photo
    func updatePromptForCurrentPhoto() {
        if let currentPhoto = model.slidesState?.currentPhoto {
            self.updatePrompt(for: currentPhoto)
        }
    }
}
