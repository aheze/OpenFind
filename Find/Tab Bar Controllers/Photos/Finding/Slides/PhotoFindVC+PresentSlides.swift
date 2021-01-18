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
        self.selectedIndexPath = indexPath
        
        print("Tableview did select, \(shouldAllowPressRow), \(fastFinding)")
        
        if shouldAllowPressRow && !fastFinding {
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
            
            self.present(slidesViewController, animated: true)
        }
    }
}
