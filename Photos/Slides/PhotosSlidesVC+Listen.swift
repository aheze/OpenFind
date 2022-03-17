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
        slidesSearchViewModel.fieldsChanged = { [weak self] textChanged in
            guard let self = self else { return }

            guard let slidesState = self.model.slidesState else { return }
            guard let currentIndex = slidesState.currentIndex else { return }
            let findPhoto = slidesState.findPhotos[currentIndex]

            /// metadata already exists, directly find
            if textChanged {
                self.startFinding(for: findPhoto)
            } else {
                /// update the highlights back in `resultsCollectionView`
                self.model.updateFieldOverrides?(self.slidesSearchViewModel.fields)

                /// replace highlights for this photo only - update other photo colors once they are scrolled to.
                if
                    let slidesState = self.model.slidesState,
                    let index = slidesState.getFindPhotoIndex(photo: findPhoto.photo),
                    let highlightsSet = slidesState.findPhotos[index].highlightsSet
                {
                    let newHighlights = self.getUpdatedHighlightsColors(
                        oldHighlights: highlightsSet.highlights,
                        newStringToGradients: self.slidesSearchViewModel.stringToGradients
                    )
                    let newHighlightsSet = FindPhoto.HighlightsSet(
                        stringToGradients: self.slidesSearchViewModel.stringToGradients,
                        highlights: newHighlights
                    )
                    self.model.slidesState?.findPhotos[index].associatedViewController?.highlightsViewModel.highlights = newHighlights
                    self.model.slidesState?.findPhotos[index].highlightsSet = newHighlightsSet
                }
            }
        }

        /// called when `startFinding` finishes.
        model.updateSlidesAt = { [weak self] index, metadata in

            guard let self = self else { return }
            if self.searchNavigationProgressViewModel.percentageShowing {
                self.searchNavigationProgressViewModel.finishAutoProgress()
                let highlights = metadata.sentences.getHighlights(stringToGradients: self.slidesSearchViewModel.stringToGradients)

                if let slidesState = self.model.slidesState, let findPhoto = slidesState.findPhotos[safe: index] {
                    DispatchQueue.main.async {
                        let highlightSet = FindPhoto.HighlightsSet(
                            stringToGradients: self.slidesSearchViewModel.stringToGradients,
                            highlights: highlights
                        )
                        findPhoto.associatedViewController?.highlightsViewModel.update(with: highlights, replace: true)

                        self.model.slidesState?.findPhotos[index].highlightsSet = highlightSet
                    }
                }
            }
        }
    }
}
