//
//  PhotosVM+Scanning.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/20/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

extension PhotosViewModel {
    /// a photo was just scanned
    /// if `inBatch`, no need for immediate add - check if the user's finger is touching the screen first
    @MainActor func photoScanned(photo: Photo, sentences: [Sentence], visionOptions: VisionOptions, inBatch: Bool) {
        var newPhoto = photo

        let text = PhotoMetadataText(
            sentences: sentences,
            scannedInLanguages: visionOptions.recognitionLanguages,
            scannedInVersion: Utilities.getVersionString()
        )

        if let metadata = photo.metadata {
            var newMetadata = metadata
            newMetadata.dateScanned = Date()
            newPhoto.metadata = newMetadata

            getRealmModel?().container.updatePhotoMetadata(metadata: newMetadata, text: text)
            addSentences(of: newPhoto, immediately: !inBatch)
        } else {
            let metadata = PhotoMetadata(
                assetIdentifier: photo.asset.localIdentifier,
                isStarred: false,
                isIgnored: false,
                dateScanned: Date()
            )

            newPhoto.metadata = metadata
            getRealmModel?().container.updatePhotoMetadata(metadata: metadata, text: text)
            addSentences(of: newPhoto, immediately: !inBatch)
        }

        photosToScan = photosToScan.filter { $0 != photo }
        resumeScanning()
    }

    @MainActor func photoFailedToScan(photo: Photo, inBatch: Bool) {
        addSentences(of: photo, immediately: !inBatch)

        /// if in slides, show alert
        if !inBatch {
            Debug.show("Failed to scan photo", message: "Because this photo is stored in iCloud, you must download it to your device first.")
        }

        /// skip
        photosToScan = photosToScan.filter { $0 != photo }

        addNote(.photosFailedToScanBecauseInCloud)
        resumeScanning()
    }

    func startScanning() {
        scanningState = .scanningAllPhotos
        if let lastPhoto = photosToScan.last {
            var findOptions = FindOptions()
            findOptions.priority = .waitUntilNotBusy
            findOptions.action = .photosScanning
            scanPhoto(lastPhoto, findOptions: findOptions, inBatch: true)
        }
    }

    /// call this after a photo was just scanned
    func resumeScanning() {
        if photosToScan.isEmpty {
            removeNote(.downloadingFromCloud)
        }
        if
            shouldResumeScanning(),
            let lastPhoto = photosToScan.last
        {
            scanningState = .scanningAllPhotos
            var findOptions = FindOptions()
            findOptions.priority = .waitUntilNotBusy
            findOptions.action = .photosScanning
            scanPhoto(lastPhoto, findOptions: findOptions, inBatch: true)
        } else {
            scanningState = .dormant
        }
    }

    func pauseScanning() {
        scanningState = .dormant
    }

    /// load photos and start scanning
    /// call this after "Try Again" when photos are in iCloud and failed to scan
    func loadAndStartScanning() {
        Task {
            await self.loadPhotos()
            startScanning()
        }
    }

    /// scan a photo
    /// `inBatch`: scanning all photos. If true, check `scanningState == .scanningAllPhotos`.
    func scanPhoto(_ photo: Photo, findOptions: FindOptions, inBatch: Bool) {
        Task {
            let image = await getFullImage(from: photo.asset)
            let realmModel = getRealmModel?()
            let languages = await realmModel?.getCurrentRecognitionLanguages(accurateMode: true) ?? [Settings.Values.RecognitionLanguage.english.rawValue]

            if let cgImage = image?.cgImage {
                var visionOptions = VisionOptions()
                visionOptions.level = .accurate
                visionOptions.recognitionLanguages = languages

                let request = await Find.find(in: .cgImage(cgImage), visionOptions: visionOptions, findOptions: findOptions)
                let sentences = Find.getSentences(from: request)

                /// discard value if not scanning and `inBatch` is true
                if !inBatch || scanningState == .scanningAllPhotos {
                    await photoScanned(photo: photo, sentences: sentences, visionOptions: visionOptions, inBatch: inBatch)
                }
            } else {
                await photoFailedToScan(photo: photo, inBatch: inBatch)
            }
        }
    }

    /// true if should resume
    func shouldResumeScanning() -> Bool {
        guard scanningState == .scanningAllPhotos else { return false }

        if photosToScan.isEmpty {
            return false
        }

        if
            let prioritizedAction = Find.prioritizedAction, prioritizedAction != .photosScanning
        {
            return false
        }

        return true
    }

    func getRemainingTime() -> String? {
        guard scannedPhotosCount != totalPhotosCount else { return nil }

        let secondsPerPhoto = CGFloat(1.2)
        let seconds = Int(secondsPerPhoto * CGFloat(photosToScan.count))
        if seconds > 60 {
            let minutes = Int(seconds / 60)
            if minutes == 1 {
                return "\(minutes) minute left"
            } else {
                return "\(minutes) minutes left"
            }
        }

        if seconds == 1 {
            return "\(seconds) second left"
        } else {
            return "\(seconds) seconds left"
        }
    }
}
