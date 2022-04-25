//
//  PhotosVC+Observe.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/8/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import Photos
import UIKit

extension PhotosViewController: PHPhotoLibraryChangeObserver {
    func startObservingChanges() {
        PHPhotoLibrary.shared().register(self)
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        model.scheduleLoadingExternalPhotos()
    }
}
