//
//  PhotosVC+Slides.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension PhotosViewController {
    func presentSlides(startingAtPhoto startingPhoto: Photo) {
        let viewController = createSlidesViewController()

        let findPhotos: [FindPhoto] = model.photos.map { photo in
            let thumbnail = self.model.photoToThumbnail[photo] ?? nil
            return FindPhoto(
                photo: photo,
                thumbnail: thumbnail
            )
        }

        let findPhoto: FindPhoto
        let currentIndex: Int
        if let photoIndex = model.getPhotoIndex(photo: startingPhoto) {
            findPhoto = findPhotos[photoIndex]
            currentIndex = photoIndex
        } else {
            return
        }

        /// set later inside `presentSlides`.
        let slidesState = PhotosSlidesState(
            viewController: viewController,
            findPhotos: findPhotos,
            startingFindPhoto: findPhoto,
            currentIndex: currentIndex
        )

        presentSlides(startingAt: findPhoto, with: slidesState)
    }

    func presentSlides(startingAtFindPhoto startingFindPhoto: FindPhoto) {
        let viewController = createSlidesViewController()

        guard let resultsState = model.resultsState else { return }

        let findPhotos: [FindPhoto] = resultsState.findPhotos.map { findPhoto in
            let thumbnail = self.model.photoToThumbnail[findPhoto.photo] ?? nil
            var newFindPhoto = findPhoto
            newFindPhoto.thumbnail = thumbnail
            return newFindPhoto
        }

        model.resultsState = resultsState

        let findPhoto: FindPhoto
        let currentIndex: Int
        if let photoIndex = resultsState.getFindPhotoIndex(findPhoto: startingFindPhoto) {
            findPhoto = resultsState.findPhotos[photoIndex]
            currentIndex = photoIndex
        } else {
            return
        }

        let slidesState = PhotosSlidesState(
            viewController: viewController,
            findPhotos: findPhotos,
            startingFindPhoto: findPhoto, /// should be inside the array
            currentIndex: currentIndex
        )

        presentSlides(startingAt: startingFindPhoto, with: slidesState)
    }

    func createSlidesViewController() -> PhotosSlidesViewController {
        /// keep it up to date. replacing!
        slidesSearchViewModel.replaceInPlace(with: searchViewModel)
        searchViewModel.dismissKeyboard?()
        let storyboard = UIStoryboard(name: "PhotosContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "PhotosSlidesViewController") { coder in
            PhotosSlidesViewController(
                coder: coder,
                model: self.model,
                tabViewModel: self.tabViewModel,
                searchNavigationModel: self.searchNavigationModel,
                slidesSearchViewModel: self.slidesSearchViewModel,
                slidesSearchPromptViewModel: self.slidesSearchPromptViewModel,
                toolbarViewModel: self.toolbarViewModel
            )
        }
        return viewController
    }

    func presentSlides(startingAt findPhoto: FindPhoto, with slidesState: PhotosSlidesState) {
        Task {
            let fullImage = await model.getFullImage(from: findPhoto.photo)

            /// update the transition with the new image.
            self.model.imageUpdatedWhenPresentingSlides?(fullImage)

            if let index = self.model.slidesState?.getFindPhotoIndex(findPhoto: findPhoto) {
                self.model.slidesState?.findPhotos[index].fullImage = fullImage
                self.model.slidesState?.findPhotos[index].associatedViewController?.reloadImage()
            }
        }

        /// update the search view model
        model.updateSlidesSearchCollectionView?()

        /// set the slides state
        model.slidesState = slidesState

        /// make the destination content view have 0 alpha
        model.animatingSlides = true

        /// retrieve the view controller from `slidesState`
        guard let viewController = slidesState.viewController else { return }
        viewController.updateSearchBarOffset = { [weak self] in
            guard let self = self else { return }
            self.updateNavigationBar?()
        }

        /// apply a custom transition
        model.transitionAnimatorsUpdated?(self, viewController)

        navigationController?.pushViewController(viewController, animated: true)
    }
}
