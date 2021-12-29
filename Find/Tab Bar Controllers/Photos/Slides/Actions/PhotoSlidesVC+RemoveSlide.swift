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
        UIView.animate(withDuration: 0.4) {
            self.currentViewController.view.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.currentViewController.view.alpha = 0
        } completion: { _ in
            self.finishRemovingCurrentSlide()
        }
    }
    
    func finishRemovingCurrentSlide() {
        let indexBeforeRemoval = currentIndex
        resultPhotos.remove(at: currentIndex)
        
        var newIndex = 0
        
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SlideViewController") as! SlideViewController
        viewController.placeholderImage = firstPlaceholderImage
        let viewControllers = [viewController]
        
        if indexBeforeRemoval == resultPhotos.count {
            if indexBeforeRemoval == 0 { /// removed last photo
                transitionController.animator.removedLast = true
                transitionController.isInteractive = false
                _ = navigationController?.popViewController(animated: true)
            } else { /// this photo is the rightmost
                newIndex = indexBeforeRemoval - 1
                let resultPhoto = resultPhotos[newIndex]
                viewController.resultPhoto = resultPhoto
                viewController.index = newIndex
                
                let findPhoto = resultPhotos[newIndex].findPhoto
                if let editableModel = findPhoto.editableModel {
                    if editableModel.isHearted {
                        updateActions?(.shouldNotStar)
                    } else {
                        updateActions?(.shouldStar)
                    }
                    if editableModel.isDeepSearched {
                        updateActions?(.shouldNotCache)
                        
                        var transcripts = [Component]()
                        for content in editableModel.contents {
                            let transcript = Component()
                            transcript.text = content.text
                            transcript.x = content.x
                            transcript.y = content.y
                            transcript.width = content.width
                            transcript.height = content.height
                            transcripts.append(transcript)
                        }
                        
                        resultPhotos[currentIndex].transcripts = transcripts
                        drawHighlightsAndTranscripts()
                    } else {
                        updateActions?(.shouldCache)
                        
                        if UIAccessibility.isVoiceOverRunning {
                            fastFind(resultPhoto: resultPhotos[currentIndex], index: currentIndex)
                        }
                    }
                } else {
                    updateActions?(.shouldStar)
                    updateActions?(.shouldCache)
                    
                    if UIAccessibility.isVoiceOverRunning {
                        fastFind(resultPhoto: resultPhotos[currentIndex], index: currentIndex)
                    }
                }
                
                view.isUserInteractionEnabled = false
                pageViewController.setViewControllers(viewControllers, direction: .reverse, animated: true) { _ in
                    self.view.isUserInteractionEnabled = true
                }
                
                updatedIndex?.indexUpdated(to: newIndex)
            }
        } else {
            newIndex = indexBeforeRemoval
            let resultPhoto = resultPhotos[newIndex]
            viewController.resultPhoto = resultPhoto
            viewController.index = newIndex
            
            let findPhoto = resultPhotos[newIndex].findPhoto
            if let editableModel = findPhoto.editableModel {
                if editableModel.isHearted {
                    updateActions?(.shouldNotStar)
                } else {
                    updateActions?(.shouldStar)
                }
                if editableModel.isDeepSearched {
                    updateActions?(.shouldNotCache)
                    
                    var transcripts = [Component]()
                    for content in editableModel.contents {
                        let transcript = Component()
                        transcript.text = content.text
                        transcript.x = content.x
                        transcript.y = content.y
                        transcript.width = content.width
                        transcript.height = content.height
                        transcripts.append(transcript)
                    }
                    
                    resultPhotos[currentIndex].transcripts = transcripts
                    drawHighlightsAndTranscripts()
                } else {
                    updateActions?(.shouldCache)
                    
                    if UIAccessibility.isVoiceOverRunning {
                        fastFind(resultPhoto: resultPhotos[currentIndex], index: currentIndex)
                    }
                }
            } else {
                updateActions?(.shouldStar)
                updateActions?(.shouldCache)
                
                if UIAccessibility.isVoiceOverRunning {
                    fastFind(resultPhoto: resultPhotos[currentIndex], index: currentIndex)
                }
            }
            
            view.isUserInteractionEnabled = false
            pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true) { _ in
                self.view.isUserInteractionEnabled = true
            }
            updatedIndex?.indexUpdated(to: newIndex)
        }
        
        currentIndex = newIndex
        voiceOverSlidesControl.currentIndex = newIndex
        voiceOverSlidesControl.totalNumberOfPhotos = resultPhotos.count
        UIAccessibility.post(notification: .layoutChanged, argument: voiceOverSlidesControl)
    }
}
