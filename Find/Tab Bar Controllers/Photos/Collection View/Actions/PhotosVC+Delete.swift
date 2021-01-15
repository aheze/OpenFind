//
//  PhotosVC+Delete.swift
//  Find
//
//  Created by Zheng on 1/14/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import Photos

class PhotoForDeletion {
    var indexPath = IndexPath(item: 0, section: 0)
    var findPhoto = FindPhoto()
}
extension PhotosViewController {
    func deleteSelectedPhotos() {
        var assetIdentifiers = [String]()
        
        var photosForDeletion = [PhotoForDeletion]()
        
        for indexPath in indexPathsSelected { /// indexPath is still the one with filters applied
            if let findPhoto = dataSource.itemIdentifier(for: indexPath) {
                assetIdentifiers.append(findPhoto.asset.localIdentifier)
                
                let photoForDeletion = PhotoForDeletion()
                
                for (monthIndex, month) in allMonths.enumerated() {
                    let samePhotos = month.photos.filter { $0.asset.localIdentifier == findPhoto.asset.localIdentifier}
                    
                    /// same photo in allMonths found, get its index
                    if let samePhoto = samePhotos.first, let itemIndex = month.photos.firstIndex(of: samePhoto) {
                        let indexPath = IndexPath(item: itemIndex, section: monthIndex)
                        photoForDeletion.indexPath = indexPath
                    }
                }
                
                photoForDeletion.findPhoto = findPhoto
                photosForDeletion.append(photoForDeletion)
            }
        }
        
        photosForDeletion.sort { $0.indexPath.section == $1.indexPath.section ? $0.indexPath.item < $1.indexPath.item : $0.indexPath.section < $1.indexPath.section  }
        photosForDeletion.reverse() /// start removing from the end
        
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: assetIdentifiers, options: nil)
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets(assets)
        } completionHandler: { (success, error) in
            if success {
                for photoToDelete in photosForDeletion {
                    var hasError = false
                    if let editableModel = photoToDelete.findPhoto.editableModel {
                        DispatchQueue.main.async {
                            if let realModel = self.getRealRealmModel(from: editableModel) {

                                do {
                                    try self.realm.write {
                                        self.realm.delete(realModel.contents)
                                        self.realm.delete(realModel)
                                    }
                                } catch {
                                    hasError = true
                                    print("Error starring photo \(error)")
                                }
                            }
                        }
                    }
                    if !hasError {
                        let indexPath = photoToDelete.indexPath
                        self.allMonths[indexPath.section].photos.remove(at: indexPath.item)
                    }
                }
                
                self.allMonths = self.allMonths.filter { month in
                    return !month.photos.isEmpty
                }
                
                DispatchQueue.main.async {
                    self.sortPhotos(with: self.currentFilter)
                    self.applySnapshot()
                }
            }
        }
        
        doneWithSelect()
    }
}
