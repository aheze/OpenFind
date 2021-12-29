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
        presentingInfo?(false)
    }
}

extension PhotoSlidesViewController {
    func infoPressed() {
        let currentPhoto = resultPhotos[currentIndex].findPhoto
        
        let unknown = NSLocalizedString("unknown", comment: "")
        var dateCreatedString = unknown
        if let dateCreated = currentPhoto.asset.creationDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM d, yyyy' at 'h:mm a"
            dateCreatedString = dateFormatter.string(from: dateCreated)
        }
        
        var origin = NSLocalizedString("photosApp", comment: "")
        var isHearted = false
        var isCached = false
        var transcript = NSLocalizedString("cachePhotoToView", comment: "")
        
        if let editableModel = currentPhoto.editableModel {
            if editableModel.isTakenLocally {
                origin = NSLocalizedString("savedFromFind", comment: "")
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
        present(infoVC, animated: true)
    }
}
