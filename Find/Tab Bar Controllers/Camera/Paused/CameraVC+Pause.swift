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
    }
    func startLivePreview() {
        cameraView.videoPreviewLayer.connection?.isEnabled = true
        self.showImageView(false)
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
}
