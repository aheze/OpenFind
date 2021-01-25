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
    func saveImageToPhotos() {
        guard
            let pausedPhoto = currentPausedImage,
            let pngData = pausedPhoto.pngData()
        else { return }
        
        
        var photoIdentifier: String?
        PHPhotoLibrary.shared().performChanges({
//
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
                    do {
                        try self.realm.write {
                            self.realm.add(newModel)
                        }
                    } catch {
                        print("Error saving model \(error)")
                    }
                    
                    
                }
                //                editablePhoto.assetIdentifier = identifier
//                finishedEditablePhotos.append(editablePhoto)
            } else {
//                editablePhotosWithErrors.append(editablePhoto)
//                let readableError = String(describing: error?.localizedDescription)
//                errorMessages.append(readableError)
            }
//
//            self.dispatchSemaphore.signal() /// signal and animate number completed regardless
//            DispatchQueue.main.async {
//                self.savedAnotherImage()
//            }
        }
        
        
        
    }
}
