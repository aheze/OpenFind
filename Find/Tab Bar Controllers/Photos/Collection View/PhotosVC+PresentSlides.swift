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
            
            slidesViewController.resultPhotos = allPhotosToDisplay.map {
                let resultPhoto = ResultPhoto()
                resultPhoto.findPhoto = $0
                return resultPhoto
            }
            
            slidesViewController.getRealModel = { [weak self] editableModel in
                guard let self = self else { return nil }
                return self.getRealRealmModel(from: editableModel)
            }
            
            slidesViewController.updateActions = { [weak self] newAction in
                guard let self = self else { return }
                self.updateSlideActions?(newAction)
            }
            slidesViewController.findPhotoChanged = { [weak self] index in
                guard let self = self else { return }
                self.slidesChanged(at: index)
            }
            slidesViewController.checkIfPhotoExists = { [weak self] findPhoto in
                guard let self = self else { return false }
                if self.allPhotosToDisplay.contains(where: { $0.asset.localIdentifier == findPhoto.asset.localIdentifier }) {
                    print("Contains!")
                    return true
                }
                return false
            }
            if let currentIndex = allPhotosToDisplay.firstIndex(of: findPhoto) {
                slidesViewController.currentIndex = currentIndex
            }
            
            if let cell = collectionView.cellForItem(at: indexPath) as? ImageCell {
                slidesViewController.firstPlaceholderImage = cell.imageView.image
                
                if let model = findPhoto.editableModel {
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
