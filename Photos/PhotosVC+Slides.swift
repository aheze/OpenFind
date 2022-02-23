//
//  PhotosVC+Slides.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension PhotosViewController {
    func presentSlides(startingAt photo: Photo) {
        
        /// keep it up to date. replacing!
        self.slidesSearchViewModel.replaceInPlace(with: searchViewModel)
        self.searchViewModel.dismissKeyboard?()

        let storyboard = UIStoryboard(name: "PhotosContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "PhotosSlidesViewController") { coder in
            PhotosSlidesViewController(
                coder: coder,
                model: self.model,
                slidesSearchViewModel: self.slidesSearchViewModel,
                toolbarViewModel: self.toolbarViewModel
            )
        }

        viewController.updateSearchBarOffset = { [weak self] in
            guard let self = self else { return }
            self.updateNavigationBar?()
        }

        let findPhotos: [FindPhoto] = model.photos.map { photo in
            let thumbnail = self.model.photoToThumbnail[photo] ?? nil
            return FindPhoto(
                photo: photo,
                thumbnail: thumbnail
            )
        }
        var slidesState = PhotosSlidesState(
            viewController: viewController,
            findPhotos: findPhotos,
            startingPhoto: photo
        )

        let findPhoto: FindPhoto
        let currentIndex: Int
        if let photoIndex = model.getPhotoIndex(photo: photo) {
            findPhoto = findPhotos[photoIndex]
            currentIndex = photoIndex
            slidesState.currentIndex = photoIndex
        } else {
            return
        }

        let photo = model.photos[currentIndex]
        Task {
            let fullImage = await model.getFullImage(from: photo)

            /// update the transition with the new image.
            self.model.imageUpdatedWhenPresentingSlides?(fullImage)

            if let index = self.model.slidesState?.getFindPhotoIndex(photo: findPhoto) {
                self.model.slidesState?.findPhotos[index].fullImage = fullImage
                self.model.slidesState?.findPhotos[index].associatedViewController?.reloadImage()
            }
        }

        model.slidesState = slidesState

        model.animatingSlides = true
        /// apply a custom transition
        model.transitionAnimatorsUpdated?(self, viewController)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
