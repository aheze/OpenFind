//
//  CameraVC+Pause.swift
//  Find
//
//  Created by Zheng on 1/24/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension CameraViewController {
    func pauseLivePreview() {
        cameraView.videoPreviewLayer.connection?.isEnabled = false
        capturePhoto { image in
            self.currentPausedImage = image
            self.showImageView(true)
        }
        pausedAccessibility(paused: true)
    }
    func startLivePreview() {
        /// make sure it's running (can stop when going to app switcher and back)
        if !avSession.isRunning {
            self.avSession.startRunning()
        }
        cameraView.videoPreviewLayer.connection?.isEnabled = true
        self.showImageView(false)
        pausedAccessibility(paused: false)
    }
    
    func showImageView(_ show: Bool) {
        if show {
            pausedImageView.image = currentPausedImage
            UIView.animate(withDuration: 0.2) {
                self.pausedImageView.alpha = 1
            }

        } else {
            UIView.animate(withDuration: 0.1) {
                self.pausedImageView.alpha = 0
            }
        }
    }
    
    func removeFocusRects(_ remove: Bool) {
        focusView.isUserInteractionEnabled = !remove
        
        if remove {
            UIView.animate(withDuration: 0.2) {
                for existingFocusView in self.focusView.subviews {
                    existingFocusView.alpha = 0
                    existingFocusView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                }
            } completion: { _ in
                for existingFocusView in self.focusView.subviews {
                    existingFocusView.removeFromSuperview()
                }
            }
        }
    }
   
}
