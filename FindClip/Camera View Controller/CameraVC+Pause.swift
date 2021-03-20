//
//  CameraVC+Pause.swift
//  FindAppClip1
//
//  Created by Zheng on 3/18/21.
//

import UIKit
import AVFoundation

extension CameraViewController {
    func pausePressed() {
        if CurrentState.currentlyPaused {
            pauseLivePreview()
            removeFocusRects()
        } else {
            startLivePreview()
        }
    }
    
    func pauseLivePreview() {
        cameraView.videoPreviewLayer.connection?.isEnabled = false
        capturePhoto { image in
            self.currentPausedImage = image
            self.showImageView(true, image: image)
        }
    }
    func startLivePreview() {
        /// make sure it's running (can stop when going to app switcher and back)
        if !avSession.isRunning {
            self.avSession.startRunning()
        }
        cameraView.videoPreviewLayer.connection?.isEnabled = true
        self.showImageView(false)
        DispatchQueue.main.async {
            self.removeCurrentComponents()
        }
    }
    func showImageView(_ show: Bool, image: UIImage = UIImage()) {
        if show {
            pausedImageView.image = image
            UIView.animate(withDuration: 0.2) {
                self.pausedImageView.alpha = 1
            }

        } else {
            UIView.animate(withDuration: 0.1) {
                self.pausedImageView.alpha = 0
            }
        }
    }
    
    func findWhenPaused() {
        if let currentImage = currentPausedImage, let cgImage = currentImage.cgImage {
            if busyFastFinding {
                waitingToFind = true
            } else {
                fastFind(orIn: cgImage)
            }
        }
    }
}
