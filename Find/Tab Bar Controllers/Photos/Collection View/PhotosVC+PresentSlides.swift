//
//  PhotosVC+PresentSlides.swift
//  Find
//
//  Created by Zheng on 1/8/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotosViewController {
    func presentFromIndexPath(indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        self.performSegue(withIdentifier: "ShowSlides", sender: self)
    }
      
    func configureSlides(navigationController: UINavigationController, slidesViewController: PhotoSlidesViewController) {
        if let indexPath = selectedIndexPath, let findPhoto = dataSource.itemIdentifier(for: indexPath) {
            navigationController.delegate = slidesViewController.transitionController
            slidesViewController.transitionController.fromDelegate = self
            slidesViewController.transitionController.toDelegate = slidesViewController
            slidesViewController.updatedIndex = self
            
            slidesViewController.findPhotos = allPhotosToDisplay
            
            
            if let currentIndex = allPhotosToDisplay.firstIndex(of: findPhoto) {
                slidesViewController.currentIndex = currentIndex
            }
            
            if let cell = collectionView.cellForItem(at: indexPath) as? ImageCell {
                slidesViewController.firstPlaceholderImage = cell.imageView.image
                
                if let model = findPhoto.model {
                    if model.isDeepSearched {
                        cell.cacheImageView.alpha = 0
                    }
                    if model.isHearted {
                        cell.starImageView.alpha = 0
                    }
                    if model.isDeepSearched || model.isHearted {
                        cell.shadowImageView.alpha = 0
                    }
                }
                
            }
            print("Setting")
//            slidesViewController.photoSlideControlPressed = photoSlideControlPressed
            currentSlidesController = slidesViewController
            changePresentationMode(presentingSlides: true)
        }
    }
    
    /// set the currentlyPresenting and change the tab bar
    func changePresentationMode(presentingSlides: Bool) {
        if presentingSlides {
            currentlyPresentingSlides = true
            changePresentationMode?(true)
        } else {
            currentlyPresentingSlides = false
            changePresentationMode?(false)
        }
    }
}
