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
    /// If metadata does not exist, start scanning. Once done, `model.updateSlidesAt` in `PhotosSlidesVC+Listen` will be called.
    func startFinding(for findPhoto: FindPhoto) {
        if let metadata = findPhoto.photo.metadata, metadata.isScanned {
            let highlights = metadata.sentences.getHighlights(stringToGradients: self.slidesSearchViewModel.stringToGradients)

            let highlightSet = FindPhoto.HighlightsSet(
                stringToGradients: self.slidesSearchViewModel.stringToGradients,
                highlights: highlights
            )
            findPhoto.associatedViewController?.highlightsViewModel.update(with: highlights, replace: true)
            if let slidesState = model.slidesState, let index = slidesState.getFindPhotoIndex(photo: findPhoto.photo) {
                self.model.slidesState?.findPhotos[index].highlightsSet = highlightSet
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
