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
        model.currentPausedUUID = nil
        livePreviewViewController.livePreviewView.videoPreviewLayer.connection?.isEnabled = true
        endAutoProgress()
        removeScrollZoomImage()
        showLivePreview()
        showZoomView()
    }

    func pause() {
        model.currentPausedUUID = UUID()
        livePreviewViewController.livePreviewView.videoPreviewLayer.connection?.isEnabled = false
        startAutoProgress()
        hideZoomView()

        Task {
            let currentUUID = model.currentPausedUUID
            let image = await livePreviewViewController.takePhoto()
            guard currentUUID == self.model.currentPausedUUID else { return }
            self.setScrollZoomImage(image: image)

            if let cgImage = image.cgImage {
                self.model.pausedImage = cgImage
                _ = await self.findAndAddHighlights(image: cgImage, wait: true)
                guard currentUUID == self.model.currentPausedUUID else { return }
                Find.prioritizedAction = nil
                self.endAutoProgress()
                self.hideLivePreview()
            }
        }
    }
}
