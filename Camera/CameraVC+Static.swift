//
//  CameraVC+Static.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/31/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//

import UIKit

/**
 When the camera view controller is paused
 */

extension CameraViewController {
    func resume() {
        livePreviewViewController.livePreviewView.videoPreviewLayer.connection?.isEnabled = true
        endAutoProgress()
        removeScrollZoomImage()
        showLivePreview()
        showZoomView()
    }

    func pause() {
        Task {
            let pausedImage = PausedImage()

            await MainActor.run {
                model.pausedImage = pausedImage
                livePreviewViewController.livePreviewView.videoPreviewLayer.connection?.isEnabled = false
                startAutoProgress()
                hideZoomView()
            }

            let currentUUID = pausedImage.id
            let image = await livePreviewViewController.takePhoto()
            guard currentUUID == self.model.pausedImage?.id else { return }
            self.setScrollZoomImage(image: image)

            if let cgImage = image.cgImage {
                /// set the image
                self.model.pausedImage?.cgImage = cgImage
                if model.snapshotState == .noImageYet, let pausedImage = self.model.pausedImage {
                    saveImage(pausedImage)
                }

                await scan(currentUUID: currentUUID, cgImage: cgImage)
                self.endAutoProgress()
                self.hideLivePreview()
            }
        }
    }

    /// currentUUID is the id of the image to scan from
    func scan(currentUUID: UUID, cgImage: CGImage) async {
        Find.prioritizedAction = .camera
        let sentences = await self.findAndAddHighlights(image: cgImage, wait: true)
        let currentDate = Date()
        guard currentUUID == self.model.pausedImage?.id else { return }

        await MainActor.run {
            /// set the sentences
            self.model.pausedImage?.sentences = sentences
            self.model.pausedImage?.dateScanned = currentDate
        }

        /// photo was saved to the photo library. Update the sentences

        if let assetIdentifier = self.model.pausedImage?.assetIdentifier {
            let metadata = PhotoMetadata(
                assetIdentifier: assetIdentifier,
                sentences: sentences,
                dateScanned: currentDate,
                isStarred: false
            )
            await MainActor.run {
                realmModel.container.updatePhotoMetadata(metadata: metadata)
            }
        }
        Find.prioritizedAction = nil /// paused now, do whatever
    }
}
