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
            PhotosSlidesViewController(coder: coder, model: self.model)
        }
        
        let slidesState = PhotosSlidesState(photos: model.photos, startingPhoto: photo)
        model.slidesState = slidesState
        navigationController?.pushViewController(viewController, animated: true)
    }
}
