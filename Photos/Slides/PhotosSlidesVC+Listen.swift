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
            guard let currentIndex = slidesState.getCurrentIndex() else { return }
            let findPhoto = slidesState.findPhotos[currentIndex]

            /// metadata already exists, directly find
            if textChanged {
                /// if showing, that means Find is currently scanning, so don't scan a second time.
                if !self.searchNavigationProgressViewModel.percentageShowing {
                    self.startFinding(for: findPhoto)
                }
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
    }
}
