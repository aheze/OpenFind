//
//  PhotosVM+Actions.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/10/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit
extension PhotosViewModel {
    func configureToolbar(for photo: Photo) {
        if let metadata = photo.metadata {
            if metadata.isStarred {
                slidesState?.toolbarStarOn = true
                return
            }
        }
        
        slidesState?.toolbarStarOn = false
    }
    
    func star(photos: [Photo]) {
        for photo in photos {
            var newPhoto = photo
            if let metadata = newPhoto.metadata {
                newPhoto.metadata?.isStarred = !metadata.isStarred
                updatePhotoMetadata(photo: newPhoto, reloadCell: true)
            } else {
                let metadata = PhotoMetadata(
                    assetIdentifier: photo.asset.localIdentifier,
                    sentences: [],
                    dateScanned: nil,
                    isStarred: true,
                    isIgnored: false
                )
                newPhoto.metadata = metadata
                updatePhotoMetadata(photo: newPhoto, reloadCell: true)
            }
        }
    }
}
