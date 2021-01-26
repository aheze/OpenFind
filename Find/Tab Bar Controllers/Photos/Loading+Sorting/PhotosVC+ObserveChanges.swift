//
//  PhotosVC+ObserveChanges.swift
//  Find
//
//  Created by Zheng on 1/24/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import Photos

extension PhotosViewController: PHPhotoLibraryChangeObserver {
    
    func startObservingChanges() {
        PHPhotoLibrary.shared().register(self)
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let allPhotos = allPhotos else { return }
        if let changes = changeInstance.changeDetails(for: allPhotos) {
            self.allPhotos = changes.fetchResultAfterChanges
            refreshNeeded = true
        }
    }
    
}
