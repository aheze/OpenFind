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
            if let metadata = findPhoto.photo.metadata {
                if textChanged {
                    let highlights = metadata.sentences.getHighlights(stringToGradients: self.slidesSearchViewModel.stringToGradients)
                    DispatchQueue.main.async {
                        findPhoto.associatedViewController?.highlightsViewModel.update(with: highlights, replace: true)
                    }
                } else {

                    self.model.updateFieldOverrides?(self.slidesSearchViewModel.fields)
                    
                    /// replace all highlights
                    if let model = findPhoto.associatedViewController?.highlightsViewModel {
                        self.updateHighlightColors(for: model, with: self.slidesSearchViewModel.stringToGradients)
                    }
                }
            } else {
                print("No metadata for finding!")
                
                self.searchNavigationProgressViewModel.start(progress: .auto(estimatedTime: 1.5))
            }
        }
    }
}
