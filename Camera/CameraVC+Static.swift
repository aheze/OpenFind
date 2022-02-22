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
        model.pausedImage = nil
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
                
                let text = await self.findAndAddHighlights(image: cgImage, wait: true)
                guard currentUUID == self.model.pausedImage?.id else { return }
                
                /// set the findText
                self.model.pausedImage?.findText = text
                
                Find.prioritizedAction = nil
                self.endAutoProgress()
                self.hideLivePreview()
            }
        }
    }
}
