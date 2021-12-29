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
            voiceOverSlidesControl.isHidden = false
        }
        
        if cameFromFind {
            voiceOverBottomC.constant = view.safeAreaInsets.bottom
            backButtonView.isAccessibilityElement = true
            backButtonView.accessibilityLabel = "Back"
            backButtonView.accessibilityTraits = .button
            backButtonView.accessibilityHint = "Go back to the Finding screen"
            
            view.accessibilityElements = [backButtonView, containerView, voiceOverSlidesControl]
        } else {
            voiceOverBottomC.constant = CGFloat(FindConstantVars.tabHeight)
            
            view.accessibilityElements = nil
        }
        
        voiceOverSlidesControl.currentIndex = currentIndex
        voiceOverSlidesControl.totalNumberOfPhotos = resultPhotos.count
        
        voiceOverSlidesControl.goToNextPage = { [weak self] goToNextPage in
            guard let self = self else { return }
            
            let newIndex: Int
            if goToNextPage {
                self.pageViewController.goToNextPage()
                newIndex = self.currentIndex + 1
            } else {
                self.pageViewController.goToPreviousPage()
                newIndex = self.currentIndex - 1
            }
            
            self.speakPhotoDescription(at: newIndex)
        }
        
        speakPhotoDescription(at: currentIndex)
    }
    
    func observeVoiceOverChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(voiceOverChanged),
            name: UIAccessibility.voiceOverStatusDidChangeNotification,
            object: nil
        )
    }
    
    @objc func voiceOverChanged() {
        if UIAccessibility.isVoiceOverRunning {
            if resultPhotos.indices.contains(currentIndex) {
                fastFind(resultPhoto: resultPhotos[currentIndex], index: currentIndex)
            }
            changeScreenMode(to: .normal)
            currentScreenMode = .normal
            currentViewController.updateHighlightFrames()
            messageView.isHidden = true
            voiceOverSlidesControl.isHidden = false
        }
    }
    
    func speakPhotoDescription(at newIndex: Int) {
        if resultPhotos.indices.contains(newIndex) {
            if let model = resultPhotos[newIndex].findPhoto.editableModel {
                DispatchQueue.global(qos: .userInitiated).async {
                    var information = ""
                    if model.isHearted {
                        information.append("Starred")
                        if model.isDeepSearched {
                            information.append(" and Cached.")
                        } else {
                            information.append(".")
                        }
                    } else if model.isDeepSearched {
                        information.append("Cached.")
                    }
                    
                    var accessibilityString = [AccessibilityText]()
                    accessibilityString.append(AccessibilityText(text: "Status: ", isRaised: true))
                    accessibilityString.append(AccessibilityText(text: information, isRaised: false))
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                        if self.currentIndex == newIndex {
                            UIAccessibility.postAnnouncement(accessibilityString, delay: 0)
                        }
                    }
                }
            }
        }
    }
}

extension UIPageViewController {
    func goToNextPage() {
        guard let currentViewController = viewControllers?.first else { return }
        guard let nextViewController = dataSource?.pageViewController(self, viewControllerAfter: currentViewController) else { return }
        setViewControllers([nextViewController], direction: .forward, animated: true) { completed in
            self.delegate?.pageViewController?(self, didFinishAnimating: true, previousViewControllers: [], transitionCompleted: completed)
        }
    }
    
    func goToPreviousPage() {
        guard let currentViewController = viewControllers?.first else { return }
        guard let previousViewController = dataSource?.pageViewController(self, viewControllerBefore: currentViewController) else { return }
        setViewControllers([previousViewController], direction: .reverse, animated: true) { completed in
            self.delegate?.pageViewController?(self, didFinishAnimating: true, previousViewControllers: [], transitionCompleted: completed)
        }
    }
}
