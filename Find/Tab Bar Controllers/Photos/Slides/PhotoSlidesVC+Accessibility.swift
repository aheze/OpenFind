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
            
            if cameFromFind {
                voiceOverBottomC.constant = view.safeAreaInsets.bottom
                backButtonView.isAccessibilityElement = true
                backButtonView.accessibilityLabel = "Back"
                backButtonView.accessibilityTraits = .button
                backButtonView.accessibilityHint = "Go back to the Finding screen"
            } else {
                voiceOverBottomC.constant = CGFloat(ConstantVars.tabHeight)
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
        } else {
            voiceOverSlidesControl.isHidden = true
        }
    }
    
    func speakPhotoDescription(at newIndex: Int) {
        
        if self.resultPhotos.indices.contains(newIndex) {
            if let model = self.resultPhotos[newIndex].findPhoto.editableModel {
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
                    
                    var shouldAnnounce = false
                    if model.isDeepSearched {
                        var transcript = ""
                        
                        for (index, content) in model.contents.enumerated() {
                            let text = content.text
                            if index == model.contents.count - 1 {
                                transcript += text
                            } else {
                                transcript += text + "\n"
                            }
                        }
                        
                        accessibilityString.append(AccessibilityText(text: "Status: ", isRaised: true))
                        accessibilityString.append(AccessibilityText(text: information, isRaised: false))
                        accessibilityString.append(AccessibilityText(text: " Cached transcript (\(model.contents.count) lines):\n", isRaised: true))
                        accessibilityString.append(AccessibilityText(text: transcript, isRaised: false))
                        
                        shouldAnnounce = true
                    } else if !information.isEmpty {
                        accessibilityString.append(AccessibilityText(text: "Status: ", isRaised: true))
                        accessibilityString.append(AccessibilityText(text: information, isRaised: false))
                        accessibilityString.append(AccessibilityText(text: " No cached transcript available. Cache photo to generate.", isRaised: true))
                        
                        shouldAnnounce = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                        if shouldAnnounce && self.currentIndex == newIndex {
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

