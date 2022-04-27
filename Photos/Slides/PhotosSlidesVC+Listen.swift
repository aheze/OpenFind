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
            guard let slidesPhoto = slidesState.getCurrentSlidesPhoto() else { return }

            /// metadata already exists, directly find
            if textChanged {
                if self.slidesSearchViewModel.isEmpty {
                    self.slidesSearchPromptViewModel.update(show: false)
                    self.slidesSearchPromptViewModel.updateBarHeight?()

                    if let index = slidesState.getSlidesPhotoIndex(photo: slidesPhoto.findPhoto.photo) {
                        let highlightSet = FindPhoto.HighlightsSet(
                            stringToGradients: [:],
                            highlights: []
                        )
                        self.getViewController(for: slidesPhoto.findPhoto.photo)?.highlightsViewModel.update(with: [], replace: true)
                        self.model.slidesState?.slidesPhotos[index].findPhoto.highlightsSet = highlightSet
                    }

                    /// if showing, that means Find is currently scanning, so don't scan a second time.
                } else if !self.searchNavigationProgressViewModel.percentageShowing {
                    if let viewController = self.getViewController(for: slidesPhoto.findPhoto.photo) {
                        self.startFinding(for: slidesPhoto, viewController: viewController, animate: true)
                    }
                }
            } else {
                /// update the highlights back in `resultsCollectionView`
                self.model.updateFieldOverrides?(self.slidesSearchViewModel.fields)

                /// replace highlights for this photo only - update other photo colors once they are scrolled to.
                if
                    let slidesState = self.model.slidesState,
                    let index = slidesState.getSlidesPhotoIndex(photo: slidesPhoto.findPhoto.photo),
                    let highlightsSet = slidesState.slidesPhotos[index].findPhoto.highlightsSet
                {
                    let newHighlights = self.getUpdatedHighlightsColors(
                        oldHighlights: highlightsSet.highlights,
                        newStringToGradients: self.slidesSearchViewModel.stringToGradients
                    )
                    let newHighlightsSet = FindPhoto.HighlightsSet(
                        stringToGradients: self.slidesSearchViewModel.stringToGradients,
                        highlights: newHighlights
                    )

                    self.getViewController(for: slidesPhoto.findPhoto.photo)?.highlightsViewModel.highlights = newHighlights
                    self.model.slidesState?.slidesPhotos[index].findPhoto.highlightsSet = newHighlightsSet
                }
            }
        }

        model.slidesCurrentPhotoChanged = { [weak self] in
            guard let self = self else { return }

            if let currentPhoto = self.model.slidesState?.currentPhoto {
                self.updateNavigationBarTitle(for: currentPhoto)
                self.updatePrompt(for: currentPhoto)
                self.model.configureToolbar(for: currentPhoto)
            }
        }

        model.slidesToolbarInformationOnChanged = { [weak self] in
            guard let self = self else { return }
            if let slidesState = self.model.slidesState {
                self.showInfo(slidesState.toolbarInformationOn)
            }
        }

        model.scanSlidesPhoto = { [weak self] slidesPhoto in
            self?.scanPhoto(slidesPhoto: slidesPhoto)
        }

        model.deletePhotoInSlides = { [weak self] photo in
            guard let self = self else { return }
            self.delete(photo: photo)
        }

        model.sharePhotoInSlides = { [weak self] photo in
            guard let self = self else { return }
            
            let sourceRect = CGRect(
                x: 0,
                y: self.view.bounds.height - self.tabViewModel.tabBarAttributes.backgroundHeight,
                width: 50,
                height: 50
            )
            
            self.share(photos: [photo], model: self.model, sourceRect: sourceRect)
        }

        model.slidesUpdateFullScreenStateTo = { [weak self] photo in
            guard let self = self else { return }
            self.toggleFullScreen()
        }
    }
}
