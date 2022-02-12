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
        livePreviewViewController.livePreviewView.videoPreviewLayer.connection?.isEnabled = false
        startAutoProgress()
        hideZoomView()
        livePreviewViewController.takePhoto { [weak self] image in
            guard let self = self else { return }
            self.setScrollZoomImage(image: image)
            
            if let cgImage = image.cgImage {
                self.model.pausedImage = cgImage
                self.findAndAddHighlights(image: cgImage) { _ in
                    self.endAutoProgress()
                    self.hideLivePreview()
                }
            }
        }
    }
}
