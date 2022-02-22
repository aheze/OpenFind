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
        let pausedImage = PausedImage()
        model.pausedImage = pausedImage
        livePreviewViewController.livePreviewView.videoPreviewLayer.connection?.isEnabled = false
        startAutoProgress()
        hideZoomView()

        Task {
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

                let sentences = await self.findAndAddHighlights(image: cgImage, wait: true)
                guard currentUUID == self.model.pausedImage?.id else { return }

                /// set the sentences
                self.model.pausedImage?.scanned = true
                self.model.pausedImage?.sentences = sentences

                /// photo was saved to the photo library. Update the sentences

                if let assetIdentifier = self.model.pausedImage?.assetIdentifier {
                    let metadata = PhotoMetadata(
                        assetIdentifier: assetIdentifier,
                        sentences: sentences,
                        isScanned: true,
                        isStarred: false
                    )
                    await MainActor.run {
                        realmModel.updatePhotoMetadata(metadata: metadata)
                    }
                }

                Find.prioritizedAction = nil
                self.endAutoProgress()
                self.hideLivePreview()
            }
        }
    }
}
