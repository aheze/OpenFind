//
//  PhotosVM+Scanning.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/20/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

extension PhotosViewModel {
    func listenToScanning() {
        photosScanningModel.photoScanned = { [weak self] photo, sentences in
            guard let self = self else { return }

            if
                let firstIndex = self.getPhotoIndex(photo: photo),
                let firstIndexPath = self.getPhotoIndexPath(photo: photo)
            {
                if self.photos[firstIndex].metadata != nil {
                    self.photos[firstIndex].metadata?.sentences = sentences
                } else {
                    let metadata = PhotoMetadata(
                        assetIdentifier: photo.asset.localIdentifier,
                        sentences: sentences,
                        isStarred: false
                    )
                    self.realmModel.addPhotoMetadata(metadata: metadata)
                }
            }
        }
    }
}
