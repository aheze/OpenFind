//
//  PhotosVM+Scanning.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/20/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Foundation

extension PhotosViewModel {
    
    /// a photo was just scanned
    func photoScanned(photo: Photo, sentences: [Sentence]) {
        print("phoot zcanned!")
        if let metadata = photo.metadata {
            var newMetadata = metadata
            newMetadata.sentences = sentences
            newMetadata.isScanned = true
            print("already meta")
            updatePhotoMetadata(photo: photo, metadata: newMetadata, reloadCell: true)
        } else {
            let metadata = PhotoMetadata(
                assetIdentifier: photo.asset.localIdentifier,
                sentences: sentences,
                isScanned: true,
                isStarred: false
            )
            print("added meta")
            updatePhotoMetadata(photo: photo, metadata: metadata, reloadCell: true)
        }

        
        photosToScan = photosToScan.filter { $0 != photo }
        scannedPhotosCount = photos.count - photosToScan.count /// update the text
        resumeScanning()
    }

    func startScanning() {
        scanningState = .scanning
        if let lastPhoto = photosToScan.last {
            var findOptions = FindOptions()
            findOptions.priority = .waitUntilNotBusy
            findOptions.action = .photosScanning
            scanPhoto(lastPhoto, findOptions: findOptions)
        }
    }

    func resumeScanning() {
        if
            shouldResumeScanning(),
            let lastPhoto = photosToScan.last
        {
            scanningState = .scanning
            var findOptions = FindOptions()
            findOptions.priority = .waitUntilNotBusy
            findOptions.action = .photosScanning
            scanPhoto(lastPhoto, findOptions: findOptions)
        } else {
            scanningState = .dormant
        }
    }

    func pauseScanning() {
        scanningState = .dormant
    }

    /// scan a photo
    /// make sure to call `self.model.scanningState = .scanning`.
    func scanPhoto(_ photo: Photo, findOptions: FindOptions) {
        Task {
            let image = await getFullImage(from: photo)
            if let cgImage = image?.cgImage {
                var visionOptions = VisionOptions()
                visionOptions.level = .accurate
                let request = await Find.find(in: .cgImage(cgImage), visionOptions: visionOptions, findOptions: findOptions)
                let sentences = Find.getSentences(from: request)
                
                /// discard value if not scanning
                if scanningState == .scanning {
                    photoScanned(photo: photo, sentences: sentences)
                }
            }
        }
    }

    /// true if should resume
    func shouldResumeScanning() -> Bool {
        if photosToScan.isEmpty {
            return false
        }

        if scanningState == .dormant {
            return false
        }

        if Find.prioritizedAction != .photosScanning {
            return false
        }

        return true
    }
}
