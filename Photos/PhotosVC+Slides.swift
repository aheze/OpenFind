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
                searchViewModel: self.searchViewModel
            )
        }

        viewController.updateSearchBarOffset = { [weak self] in
            guard let self = self else { return }
            self.updateNavigationBar?()
        }
        
        let slidesState = PhotosSlidesState(
            viewController: viewController,
            findPhotos: model.photos.map { .init(photo: $0) },
            startingPhoto: photo
        )
        model.slidesState = slidesState
        navigationController?.pushViewController(viewController, animated: true)
    }
}
