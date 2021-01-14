//
//  PhotosVC+Delete.swift
//  Find
//
//  Created by Zheng on 1/14/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import Photos
//import RealmSwift

extension PhotosViewController {
    func deleteSelectedPhotos() {
        var selectedPhotos = [FindPhoto]()
        var assetIdentifiers = [String]()
        
        for indexPath in indexPathsSelected {
            if let findPhoto = dataSource.itemIdentifier(for: indexPath) {
                selectedPhotos.append(findPhoto)
                assetIdentifiers.append(findPhoto.asset.localIdentifier)
            }
        }
        
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: assetIdentifiers, options: nil)
        
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets(assets)
        } completionHandler: { (success, error) in
            if success {
                for selectedPhoto in selectedPhotos {
                    if let editableModel = selectedPhoto.editableModel {
                        DispatchQueue.main.async {
                            if let realModel = self.getRealRealmModel(from: editableModel) {
                                
                                do {
                                    try self.realm.write {
                                        self.realm.delete(realModel.contents)
                                        self.realm.delete(realModel)
                                    }
                                } catch {
                                    print("Error starring photo \(error)")
                                }
                            }
                        }
                    }
                }
            }
            
            
        }
        
        doneWithSelect()

//        PHPhotoLibrary.shared().performChanges({
//
//            let creationRequest = PHAssetCreationRequest.forAsset()
//            creationRequest.addResource(with: .photo, data: data, options: nil)
//            if let identifier = creationRequest.placeholderForCreatedAsset?.localIdentifier {
//                photoIdentifier = identifier
//            } else {
//            }
//        }) { (success, error) in
//
//            if
//                success,
//                let identifier = photoIdentifier
//            {
//                editablePhoto.assetIdentifier = identifier
//                finishedEditablePhotos.append(editablePhoto)
//            } else {
//                editablePhotosWithErrors.append(editablePhoto)
//                let readableError = String(describing: error?.localizedDescription)
//                errorMessages.append(readableError)
//            }
//
//            self.dispatchSemaphore.signal() /// signal and animate number completed regardless
//            DispatchQueue.main.async {
//                self.savedAnotherImage()
//            }
//        }
    }
}
