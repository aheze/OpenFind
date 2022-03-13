//
//  PhotosVM+Update.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension PhotosViewModel {
    func updatePhotoMetadata(photo: Photo, metadata: PhotoMetadata) {
        if
            let index = getPhotoIndex(photo: photo),
            let indexPath = getPhotoIndexPath(photo: photo)
        {
            photos[index].metadata = metadata
            sections[indexPath.section].photos[indexPath.item].metadata = metadata
            
            if
                let resultsState = resultsState,
                let index = resultsState.getFindPhotoIndex(photo: photo)
            {
                print("Results index exists")
                self.resultsState?.findPhotos[index].photo.metadata = metadata
            }
            
            if
                let slidesState = slidesState,
                let index = slidesState.getFindPhotoIndex(photo: photo)
            {
                print("slidesState index exists")
                self.slidesState?.findPhotos[index].photo.metadata = metadata
            }
        }
    }
}
