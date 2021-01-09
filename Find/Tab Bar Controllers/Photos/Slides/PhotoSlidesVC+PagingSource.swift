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
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        print("before")
        
        if currentIndex == 0 {
            return nil
        }
        
        let leftFindPhoto = findPhotos[currentIndex - 1] /// findPhoto for this zoom vc
        
        guard let currentViewController = viewController as? PhotoZoomViewController else { return nil }
        let leftViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhotoZoomViewController") as! PhotoZoomViewController
        
        leftViewController.findPhoto = leftFindPhoto
        leftViewController.index = currentViewController.index - 1
        
        print("left index from current vc: \(currentViewController.index - 1)")
        print("left index from curr: \(currentIndex - 1)")
        
        return leftViewController
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        print("after")
        if currentIndex == (self.findPhotos.count - 1) {
            return nil
        }
        
        let rightFindPhoto = findPhotos[currentIndex + 1] /// findPhoto for this zoom vc
        
        guard let currentViewController = viewController as? PhotoZoomViewController else { return nil }
        let rightViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhotoZoomViewController") as! PhotoZoomViewController
        
        rightViewController.findPhoto = rightFindPhoto
        rightViewController.index = currentViewController.index + 1
        
        return rightViewController
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        let currentVC = currentViewController
        if completed {
            let index = currentVC.index
            //            currentVC.returnNumber = self
            currentIndex = index
        }
        previousViewControllers.forEach { vc in
            let zoomVC = vc as! PhotoZoomViewController
            zoomVC.scrollView.zoomScale = zoomVC.scrollView.minimumZoomScale
        }
        
        self.updatedIndex?.indexUpdated(to: currentIndex)
        
//        if !cameFromFind {
//            if completed {
//                self.changedTerms = currentVC
//                changedTerms?.returnTerms(matchToColorsR: matchToColors)
//            }
//            if photoModels[currentIndex].isHearted == true {
//                let newImage = UIImage(systemName: "heart.fill")
//                heartButton.setImage(newImage, for: .normal)
//                heartButton.tintColor = UIColor(named: "FeedbackGradientRight")
//            } else {
//                let newImage = UIImage(systemName: "heart")
//                heartButton.setImage(newImage, for: .normal)
//                heartButton.tintColor = UIColor(hexString: "5287B6")
//            }
//            if photoModels[currentIndex].isDeepSearched == true {
//                cacheButton.setImage(UIImage(named: "YesCachedThin"), for: .normal)
//                cacheButton.tintColor = UIColor(named: "FeedbackGradientRight")
//            } else {
//                cacheButton.setImage(UIImage(named: "NotCachedThin"), for: .normal)
//                cacheButton.tintColor = UIColor(hexString: "5287B6")
//            }
//        }
    }
}
