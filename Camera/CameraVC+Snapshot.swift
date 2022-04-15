//
//  CameraVC+Snapshot.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import UIKit

extension CameraViewController {
    func snapshot() {
        /// only snapshot if the snapshot hasn't started saving yet
        if model.snapshotState == .inactive {
            if
                let image = model.pausedImage,
                image.cgImage != nil
            {
                model.setSnapshotState(to: .startedSaving)
                saveImage(image)
            } else {
                model.setSnapshotState(to: .noImageYet)
            }
        }
    }

    func saveImage(_ image: PausedImage) {
        guard let cgImage = image.cgImage else { return }
        let uiImage = UIImage(cgImage: cgImage)
        guard let jpegData = uiImage.jpegData(compressionQuality: 1) else { return }

        var assetIdentifier: String?

        PHPhotoLibrary.shared().performChanges {
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .photo, data: jpegData, options: nil)
            assetIdentifier = creationRequest.placeholderForCreatedAsset?.localIdentifier

        } completionHandler: { success, _ in

            if
                success,
                let assetIdentifier = assetIdentifier
            {
                DispatchQueue.main.async {
                    let metadata: PhotoMetadata

                    guard let currentPausedImage = self.model.pausedImage else { return }
                    if currentPausedImage.id == image.id {
                        self.model.pausedImage?.assetIdentifier = assetIdentifier
                        self.model.setSnapshotState(to: .saved)

                        /// the photo may have been scanned before the closure was called. if so, save the sentences.
                        metadata = PhotoMetadata(
                            assetIdentifier: assetIdentifier,
                            dateScanned: currentPausedImage.dateScanned,
                            sentences: currentPausedImage.sentences,
                            scannedInLanguages: currentPausedImage.scannedInLanguages,
                            isStarred: false,
                            isIgnored: false
                        )
                        
                        self.realmModel.container.updatePhotoMetadata(metadata: metadata)
                    }
                }
            }
        }
    }
}
