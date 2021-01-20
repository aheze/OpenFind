//
//  PhotoSlidesVC+RemoveSlide.swift
//  Find
//
//  Created by Zheng on 1/19/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotoSlidesViewController {
    func removeCurrentSlide() {
        
        let indexBeforeRemoval = currentIndex
        resultPhotos.remove(at: currentIndex)
        
        var newIndex = 0
        
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SlideViewController") as! SlideViewController
        viewController.placeholderImage = firstPlaceholderImage
        let viewControllers = [ viewController ]
        
        if indexBeforeRemoval == resultPhotos.count {
            if indexBeforeRemoval == 0 { /// removed last photo
                self.transitionController.animator.removedLast = true
                self.transitionController.isInteractive = false
                let _ = self.navigationController?.popViewController(animated: true)
            } else { /// this photo is the rightmost
                newIndex = indexBeforeRemoval - 1
                let resultPhoto = resultPhotos[newIndex]
                viewController.resultPhoto = resultPhoto
                viewController.index = newIndex
                
                let findPhoto = resultPhotos[newIndex].findPhoto
                if let editableModel = findPhoto.editableModel, editableModel.isHearted {
                    updateActions?(.shouldNotStar)
                } else {
                    updateActions?(.shouldStar)
                }
                self.pageViewController.setViewControllers(viewControllers, direction: .reverse, animated: true, completion: nil)
                self.updatedIndex?.indexUpdated(to: newIndex)
            }
        } else {
            newIndex = indexBeforeRemoval
            let resultPhoto = resultPhotos[newIndex]
            viewController.resultPhoto = resultPhoto
            viewController.index = newIndex
            
            let findPhoto = resultPhotos[newIndex].findPhoto
            if let editableModel = findPhoto.editableModel, editableModel.isHearted {
                updateActions?(.shouldNotStar)
            } else {
                updateActions?(.shouldStar)
            }
            self.pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
            self.updatedIndex?.indexUpdated(to: newIndex)
        }
        
        self.currentIndex = newIndex
        
    }
}
