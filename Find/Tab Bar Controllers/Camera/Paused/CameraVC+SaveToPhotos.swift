//
//  CameraVC+SaveToPhotos.swift
//  Find
//
//  Created by Zheng on 1/24/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import Photos

extension CameraViewController {
    func animatePhotosIcon() {
        if TipViews.inTutorial {
            TipViews.finishTutorial()
        }
        
        if self.savePressed {
            UIView.animate(withDuration: Double(FindConstants.transitionDuration)) {
                self.saveToPhotos.photosIcon.makeActiveState(offset: true)()
            }
            self.saveLabel.fadeTransition(0.2)
            
            let savedText = NSLocalizedString("savedText", comment: "")
            self.saveLabel.text = savedText
            
            saveToPhotos.accessibilityLabel = "Saved"
            saveToPhotos.accessibilityHint = "Tap to remove the current paused image from the photo library"
            
        } else {
            UIView.animate(withDuration: Double(FindConstants.transitionDuration)) {
                self.saveToPhotos.photosIcon.makeNormalState(details: FindConstants.detailIconColorDark, foreground: FindConstants.foregroundIconColorDark, background: FindConstants.backgroundIconColorDark)()
            }
            self.saveLabel.fadeTransition(0.2)
            let saveText = NSLocalizedString("saveText", comment: "")
            self.saveLabel.text = saveText
            
            saveToPhotos.accessibilityLabel = "Save to Photos"
            saveToPhotos.accessibilityHint = "Saves the current paused image to the photo library"
        }
    }
    
    func saveImageToPhotos(cachePressed: Bool) {
        guard
            let pausedPhoto = currentPausedImage,
            let pngData = pausedPhoto.pngData()
        else { return }
        
        let currentRawContents = self.rawCachedContents
        
        var photoIdentifier: String?
        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .photo, data: pngData, options: nil)
            if let identifier = creationRequest.placeholderForCreatedAsset?.localIdentifier {
                photoIdentifier = identifier
            }
        }) { (success, error) in

            if
                success,
                let identifier = photoIdentifier
            {
                DispatchQueue.main.async {
                    let newModel = HistoryModel()
                    newModel.assetIdentifier = identifier
                    newModel.isTakenLocally = true
                    
                    if cachePressed {
                        newModel.isDeepSearched = true
                        for cachedContent in currentRawContents {
                            let newContent = SingleHistoryContent()
                            newContent.x = Double(cachedContent.x)
                            newContent.y = Double(cachedContent.y)
                            newContent.width = Double(cachedContent.width)
                            newContent.height = Double(cachedContent.height)
                            newContent.text = cachedContent.text
                            newModel.contents.append(newContent)
                        }
                    }
                    
                    
                    do {
                        try self.realm.write {
                            self.realm.add(newModel)
                        }
                    } catch {

                    }
                }
            }
        }
    }
}
