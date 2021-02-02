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
        if !currentlyObservingChanges {
            PHPhotoLibrary.shared().register(self)
            currentlyObservingChanges = true
        }
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let allPhotos = allPhotos else { return }
        if let changes = changeInstance.changeDetails(for: allPhotos) {
            self.allPhotos = changes.fetchResultAfterChanges
            
            if ViewControllerState.currentVC is PhotosWrapperController {
                if currentSlidesController != nil {
                    refreshNeededAfterDismissPhoto = true
                } else {
                    refreshing = true
                    DispatchQueue.main.async {
                        self.loadImages { (allPhotos, allMonths) in
                            self.allMonths = allMonths
                            self.monthsToDisplay = allMonths
                            self.allPhotosToDisplay = allPhotos
                            self.sortPhotos(with: self.currentFilter)
                            self.applySnapshot(animatingDifferences: true)
                            self.refreshing = false
                        }
                    }
                }
            } else {
                refreshNeededAtLoad = true
            }
        }
    }
    
}
