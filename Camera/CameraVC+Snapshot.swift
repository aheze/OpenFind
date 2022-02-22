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
        if !model.snapshotSaved {
            model.snapshotSaved = true
            if let image = model.pausedImage {
                saveImage(image)
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

                    if let currentPausedImage = self.model.pausedImage, currentPausedImage.id == image.id {
                        self.model.pausedImage?.assetIdentifier = assetIdentifier

                        /// the photo may have been scanned before the closure was called. if so, save the sentences.
                        metadata = PhotoMetadata(
                            assetIdentifier: assetIdentifier,
                            sentences: currentPausedImage.sentences,
                            isScanned: currentPausedImage.scanned,
                            isStarred: false
                        )
                    } else {
                        metadata = PhotoMetadata(
                            assetIdentifier: assetIdentifier,
                            sentences: image.sentences,
                            isScanned: image.scanned,
                            isStarred: false
                        )
                    }
                    self.realmModel.addPhotoMetadata(metadata: metadata)
                }
            }
        }
    }
}
