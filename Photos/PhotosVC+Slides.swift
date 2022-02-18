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
        let storyboard = UIStoryboard(name: "PhotosContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "PhotosSlidesViewController") { coder in
            PhotosSlidesViewController(
                coder: coder,
                model: self.model,
                searchViewModel: self.searchViewModel,
                toolbarViewModel: self.toolbarViewModel
            )
        }

        viewController.updateSearchBarOffset = { [weak self] in
            guard let self = self else { return }
            self.updateNavigationBar?()
        }

        let findPhotos: [FindPhoto] = model.photos.map { .init(photo: $0) }
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

        model.imageManager.requestImage(
            for: model.photos[currentIndex].asset,
            targetSize: .zero,
            contentMode: .aspectFill,
            options: nil
        ) { [weak self] image, _ in
            guard let self = self else { return }

            /// update the transition with the new image.
            self.model.imageUpdatedWhenPresentingSlides?(image)

            if let index = self.model.slidesState?.getFindPhotoIndex(photo: findPhoto) {
                self.model.slidesState?.findPhotos[index].image = image
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
