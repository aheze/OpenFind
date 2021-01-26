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
    func saveImageToPhotos(cachePressed: Bool) {
        guard
            let pausedPhoto = currentPausedImage,
            let pngData = pausedPhoto.pngData()
        else { return }
        
        let currentContents = self.cachedContents
        print("curr count: \(self.cachedContents)")
        
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
                        for cachedContent in currentContents {
                            print("looping")
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
                        print("Error saving model \(error)")
                    }
                }
            }
        }
    }
}
