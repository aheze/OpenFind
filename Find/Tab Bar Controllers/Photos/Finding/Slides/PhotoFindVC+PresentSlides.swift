//
//  PhotoFindVC+PresentSlides.swift
//  Find
//
//  Created by Zheng on 1/17/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotoFindViewController {
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
    
    func presentFromIndexPath(indexPath: IndexPath) {
        selectedIndexPath = indexPath
        
        if numberCurrentlyFindingFromCache == 0, currentFastFindProcess == nil {
            let slidesViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhotoSlidesViewController") as! PhotoSlidesViewController
            
            slidesViewController.transitioningDelegate = slidesViewController.transitionController
            slidesViewController.transitionController.fromDelegate = self
            slidesViewController.transitionController.toDelegate = slidesViewController
            slidesViewController.updatedIndex = self
            slidesViewController.modalPresentationStyle = .fullScreen
            
            slidesViewController.resultPhotos = resultPhotos
            
            slidesViewController.currentIndex = indexPath.item
            
            slidesViewController.matchToColors = matchToColors
            slidesViewController.cameFromFind = true
            
            if let cell = tableView.cellForRow(at: indexPath) as? HistoryFindCell {
                slidesViewController.firstPlaceholderImage = cell.photoImageView.image
                
                let findPhoto = resultPhotos[indexPath.row].findPhoto
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
            present(slidesViewController, animated: true)
        }
    }
}
