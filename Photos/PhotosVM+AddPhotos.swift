//
//  PhotosVM+AddPhotos.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/8/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

/**
 Wait until update allowed, then add external photos or star/unstar filtering and find.
 */
extension PhotosViewModel {
    func scheduleUpdateAfterStarChange() {
        if updateAllowed {
            updateAfterStarChange()
        } else {
            sortNeededAfterStarChanged = true
        }
    }

    /// add photos that were just added
    func updateAfterStarChange() {
        sortNeededAfterStarChanged = false
        sort()
        reloadAfterStarChanged?()
    }
}

extension PhotosViewModel {
    func scheduleLoadingExternalPhotos() {
        if updateAllowed {
            loadExternalPhotos()
        } else {
            waitingToAddExternalPhotos = true
        }
    }

    /// add photos that were just added
    func loadExternalPhotos() {
        Task {
            self.waitingToAddExternalPhotos = false
            self.loadAssets()
            let (photos, ignoredPhotos, photosToScan) = await self.getPhotos()

            self.photos = photos
            self.ignoredPhotos = ignoredPhotos
            print("setting add")
            self.photosToScan = photosToScan.reversed() /// newest photos go first

            self.sort()

            self.reloadAfterExternalPhotosChanged?()
        }
    }
}
