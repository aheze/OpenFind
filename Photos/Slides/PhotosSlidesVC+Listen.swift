//
//  PhotosSlidesVC+Listen.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension PhotosSlidesViewController {
    func listen() {
        model.updateSlidesAt = { [weak self] index, metadata in
            guard let self = self else { return }
            if self.searchNavigationProgressViewModel.percentageShowing {
                self.searchNavigationProgressViewModel.finishAutoProgress()
                let highlights = metadata.sentences.getHighlights(stringToGradients: self.slidesSearchViewModel.stringToGradients)

                if let slidesState = self.model.slidesState, let findPhoto = slidesState.findPhotos[safe: index] {
                    DispatchQueue.main.async {
                        findPhoto.associatedViewController?.highlightsViewModel.update(with: highlights, replace: true)
                    }
                }
            }
        }

        slidesSearchViewModel.fieldsChanged = { [weak self] textChanged in
            guard let self = self else { return }

            guard let slidesState = self.model.slidesState else { return }
            guard let currentIndex = slidesState.currentIndex else { return }
            let findPhoto = slidesState.findPhotos[currentIndex]

            /// metadata already exists, directly find
            if let metadata = findPhoto.photo.metadata {
                if textChanged {
                    let highlights = metadata.sentences.getHighlights(stringToGradients: self.slidesSearchViewModel.stringToGradients)
                    DispatchQueue.main.async {
                        findPhoto.associatedViewController?.highlightsViewModel.update(with: highlights, replace: true)
                    }
                } else {
                    /// update the highlights back in `resultsCollectionView`
                    self.model.updateFieldOverrides?(self.slidesSearchViewModel.fields)

                    /// replace all highlights
                    for index in slidesState.findPhotos.indices {
                        if let highlights = slidesState.findPhotos[index].highlights {
                            let newHighlights = self.getUpdatedHighlightsColors(oldHighlights: highlights, newStringToGradients: self.slidesSearchViewModel.stringToGradients)
                            self.model.slidesState?.findPhotos[index].highlights = newHighlights
                            self.model.slidesState?.findPhotos[index].associatedViewController?.highlightsViewModel.highlights = newHighlights
                        }
                    }
                }
            } else {
                Find.prioritizedAction = .individualPhoto
                self.searchNavigationProgressViewModel.start(progress: .auto(estimatedTime: 1.5))

                var findOptions = FindOptions()
                findOptions.priority = .waitUntilNotBusy
                findOptions.action = .individualPhoto
                self.model.scanningState = .scanning
                self.model.scanPhoto(findPhoto.photo, findOptions: findOptions)
            }
        }
    }
}
