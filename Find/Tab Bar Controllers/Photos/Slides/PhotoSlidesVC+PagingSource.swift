//
//  PhotoSlidesVC+PagingSource.swift
//  Find
//
//  Created by Zheng on 1/8/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

protocol PhotoSlidesUpdatedIndex: class {
    func indexUpdated(to newIndex: Int)
}
extension PhotoSlidesViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if currentIndex == 0 {
            return nil
        }
        
        let leftResultPhoto = resultPhotos[currentIndex - 1] /// findPhoto for this zoom vc
        
        guard let currentViewController = viewController as? SlideViewController else { return nil }
        let leftViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SlideViewController") as! SlideViewController
        
        leftViewController.resultPhoto = leftResultPhoto
        leftViewController.index = currentViewController.index - 1
        
        if cameFromFind {
            leftViewController.cameFromFind = true
            leftViewController.highlights = leftResultPhoto.components
            leftViewController.matchToColors = matchToColors
        }
        
        return leftViewController
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if currentIndex == (self.resultPhotos.count - 1) {
            return nil
        }
        
        let rightResultPhoto = resultPhotos[currentIndex + 1] /// findPhoto for this zoom vc
        
        guard let currentViewController = viewController as? SlideViewController else { return nil }
        let rightViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SlideViewController") as! SlideViewController
        
        rightViewController.resultPhoto = rightResultPhoto
        rightViewController.index = currentViewController.index + 1
        
        if cameFromFind {
            rightViewController.cameFromFind = true
            rightViewController.highlights = rightResultPhoto.components
            rightViewController.matchToColors = matchToColors
        }
        
        return rightViewController
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let currentVC = currentViewController
        if completed {
            let index = currentVC.index
            currentIndex = index
            
            
            if !cameFromFind {
                let resultPhoto = resultPhotos[currentIndex]
                if let editableModel = resultPhoto.findPhoto.editableModel {
                    if editableModel.isHearted {
                        updateActions?(.shouldNotStar)
                    } else {
                        updateActions?(.shouldStar)
                    }
                    if editableModel.isDeepSearched {
                        updateActions?(.shouldNotCache)
                    } else {
                        updateActions?(.shouldCache)
                    }
                } else {
                    updateActions?(.shouldStar)
                    updateActions?(.shouldCache)
                }
                
                updateNavigationTitle(to: resultPhoto.findPhoto)
                
                if findPressed {
                    if let editableModel = resultPhoto.findPhoto.editableModel, editableModel.isDeepSearched {
                        findFromCache(resultPhoto: resultPhotos[currentIndex], index: currentIndex)
                    } else {
                        setPromptToContinue()
                    }
                }
                
            }
        }
        previousViewControllers.forEach { vc in
            let zoomVC = vc as! SlideViewController
            zoomVC.scrollView.zoomScale = zoomVC.scrollView.minimumZoomScale
        }
        
        self.updatedIndex?.indexUpdated(to: currentIndex)
        
    }
}
