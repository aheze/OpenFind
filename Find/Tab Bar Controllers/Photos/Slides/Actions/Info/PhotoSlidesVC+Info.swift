//
//  PhotoSlidesVC+Info.swift
//  Find
//
//  Created by Zheng on 1/23/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotoSlidesViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print("dismissed!!!")
        presentingInfo?(false)
    }
}
extension PhotoSlidesViewController {
    func infoPressed() {
        let currentPhoto = resultPhotos[currentIndex].findPhoto
        
        var dateCreatedString = "Unknown"
        if let dateCreated = currentPhoto.asset.creationDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM d, yyyy' at 'h:mm a"
            dateCreatedString = dateFormatter.string(from: dateCreated)
        }
        
        var origin = "Photos app"
        var isHearted = false
        var isCached = false
        var transcript = "[Cache photo to generate transcript]"
        
        if let editableModel = currentPhoto.editableModel {
            if editableModel.isTakenLocally {
                origin = "Saved from Find"
            }
            if editableModel.isHearted {
                isHearted = true
            }
            if editableModel.isDeepSearched {
                isCached = true
                
                var newTranscript = ""
                
                for (index, content) in editableModel.contents.enumerated() {
                    let text = content.text
                    if index == editableModel.contents.count - 1 {
                        newTranscript += text
                    } else {
                        newTranscript += text + "\n"
                    }
                    
                }
                transcript = newTranscript
            }
        }
        
        let infoVC = InfoViewHoster()
        infoVC.dateTaken = dateCreatedString
        infoVC.origin = origin
        infoVC.isStarred = isHearted
        infoVC.isCached = isCached
        infoVC.transcript = transcript
        
        infoVC.pressedDone = { [weak self] in
            self?.presentingInfo?(false)
        }
        
        infoVC.presentationController?.delegate = self
        
        presentingInfo?(true)
        self.present(infoVC, animated: true)
    }
}
