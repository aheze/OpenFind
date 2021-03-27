//
//  PhotoSlidesVC+Accessibility.swift
//  Find
//
//  Created by Zheng on 3/27/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotoSlidesViewController {
    func setupAccessibility() {
        if UIAccessibility.isVoiceOverRunning {
            messageView.isHidden = true
            voiceOverBottomC.constant = CGFloat(ConstantVars.tabHeight)
            
            voiceOverSlidesControl.currentIndex = currentIndex
            voiceOverSlidesControl.totalNumberOfPhotos = resultPhotos.count
            voiceOverSlidesControl.goToNextPage = { [weak self] goToNextPage in
                guard let self = self else { return }
                
                if goToNextPage {
                    self.pageViewController.goToNextPage()
                } else {
                    self.pageViewController.goToPreviousPage()
                }
                
            }
        } else {
            voiceOverSlidesControl.isHidden = true
        }
    }
}

extension UIPageViewController {
    
    func goToNextPage() {
        guard let currentViewController = self.viewControllers?.first else { return }
        guard let nextViewController = dataSource?.pageViewController( self, viewControllerAfter: currentViewController ) else { return }
        setViewControllers([nextViewController], direction: .forward, animated: true) { completed in
            self.delegate?.pageViewController?(self, didFinishAnimating: true, previousViewControllers: [], transitionCompleted: completed)
        }
    }
    
    func goToPreviousPage() {
        guard let currentViewController = self.viewControllers?.first else { return }
        guard let previousViewController = dataSource?.pageViewController( self, viewControllerBefore: currentViewController ) else { return }
        setViewControllers([previousViewController], direction: .reverse, animated: true) { completed in
            self.delegate?.pageViewController?(self, didFinishAnimating: true, previousViewControllers: [], transitionCompleted: completed)
        }
    }

}

