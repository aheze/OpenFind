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
    func setupStatic() {
        /// Listen to shutter press events
        cameraViewModel.shutterPressed = { [weak self] in
            guard let self = self else { return }
            
            if self.cameraViewModel.shutterOn {
                self.pause()
            } else {
                self.resume()
            }
        }
    }
    func resume() {
        livePreviewViewController.livePreviewView.videoPreviewLayer.connection?.isEnabled = true
        endAutoProgress()
    }
    func pause() {
        livePreviewViewController.livePreviewView.videoPreviewLayer.connection?.isEnabled = false
        startAutoProgress()
        livePreviewViewController.takePhoto { [weak self ]image in
            guard let self = self else { return }
            self.endAutoProgress()
        }
    }
}
