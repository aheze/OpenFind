//
//  PhotosVM+Scanning.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/20/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Foundation

extension PhotosViewModel {
    func photoScanned(photo: Photo, sentences: [Sentence]) {
        if let metadata = photo.metadata {
            var newMetadata = metadata
            newMetadata.sentences = sentences
            newMetadata.isScanned = true
            realmModel.updatePhotoMetadata(metadata: newMetadata)
        } else {
            let metadata = PhotoMetadata(
                assetIdentifier: photo.asset.localIdentifier,
                sentences: sentences,
                isScanned: true,
                isStarred: false
            )
            realmModel.addPhotoMetadata(metadata: metadata)
        }

        photosToScan.removeFirst()
        scannedPhotosCount = photos.count - photosToScan.count /// update the text
        resumeScanning()
    }

    func startScanning() {
        scanningState = .scanning
        if let firstPhoto = photosToScan.first {
            scanPhoto(firstPhoto)
        }
    }

    func resumeScanning() {
        if
            shouldResumeScanning(),
            let firstPhoto = photosToScan.first
        {
            scanningState = .scanning
            scanPhoto(firstPhoto)
        } else {
            scanningState = .dormant
        }
    }

    func updateState() {}

    func scanPhoto(_ photo: Photo) {
        Task {
            let image = await getFullImage(from: photo)
            if let cgImage = image?.cgImage {
                var options = FindOptions()
                options.level = .accurate
                let text = await Find.find(in: .cgImage(cgImage), options: options, action: .photos, wait: true) ?? []
                let sentences = text.map { Sentence(rect: $0.frame, string: $0.string) }
                photoScanned(photo: photo, sentences: sentences)
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

        if Find.prioritizedAction == .photos {
            return false
        }

        return true
    }
}
