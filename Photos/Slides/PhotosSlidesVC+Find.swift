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
        if let metadata = findPhoto.photo.metadata {
            let highlights = metadata.sentences.getHighlights(stringToGradients: self.slidesSearchViewModel.stringToGradients)
            DispatchQueue.main.async {
                findPhoto.associatedViewController?.highlightsViewModel.update(with: highlights, replace: true)
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
