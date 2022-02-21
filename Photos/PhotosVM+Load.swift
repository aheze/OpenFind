//
//  PhotosVM+Load.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/14/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import Photos
import UIKit

extension PhotosViewModel {
    
    // MARK: - Listen to realm refreshes
    func listenToRealm() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(photoMetadatasUpdated),
            name: .photoMetadatasUpdated,
            object: nil
        )
    }

    @objc func photoMetadatasUpdated(notification: Notification) {
        load()
    }
    
    func load() {
        loadAssets()
        loadPhotos { [weak self] in
            guard let self = self else { return }
            self.sort()
            self.reload?()
        }
    }
    
    func loadAssets() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
    }
    
    func loadPhotos(completion: (() -> Void)?) {
        var photos = [Photo]()
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            /// how many scanned photos
            var currentScannedCount = 0
            self.assets?.enumerateObjects { [weak self] asset, _, _ in
                guard let self = self else { return }
                
                let photo: Photo
                let identifier = asset.localIdentifier
                if let metadata = self.realmModel.getPhotoMetadata(from: identifier) {
                    photo = Photo(asset: asset, metadata: metadata)
                    
                    if !metadata.sentences.isEmpty {
                        currentScannedCount += 1
                    }
                } else {
                    photo = Photo(asset: asset)
                }
                
                photos.append(photo)
            }
            
            DispatchQueue.main.async {
                self.photos = photos
                self.photosScanningModel.scannedPhotosCount = currentScannedCount
                self.photosScanningModel.totalPhotosCount = photos.count
                completion?()
            }
        }
    }
}
