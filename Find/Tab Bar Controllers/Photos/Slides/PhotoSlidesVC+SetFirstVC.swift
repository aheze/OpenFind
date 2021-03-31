//
//  PhotoSlidesVC+SetFirstVC.swift
//  Find
//
//  Created by Zheng on 1/8/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotoSlidesViewController {
    func setFirstVC() {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SlideViewController") as! SlideViewController
        
        let resultPhoto = resultPhotos[currentIndex]
        viewController.resultPhoto = resultPhoto
        viewController.index = currentIndex
        viewController.placeholderImage = firstPlaceholderImage
        
        if cameFromFind {
            viewController.cameFromFind = true
            viewController.matchToColors = matchToColors
        } else {
            let findPhoto = resultPhotos[currentIndex].findPhoto
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
                    
                } else {
                    updateActions?(.shouldCache)
                    
                    fastFind(resultPhoto: resultPhotos[currentIndex], index: currentIndex)
                }
            } else {
                updateActions?(.shouldStar)
                updateActions?(.shouldCache)
                
                fastFind(resultPhoto: resultPhotos[currentIndex], index: currentIndex)
            }
        }
        
        let viewControllers = [ viewController ]
            
        self.pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
    }
}
