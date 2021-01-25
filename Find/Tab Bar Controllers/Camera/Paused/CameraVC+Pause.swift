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
        }
    }
    func startLivePreview() {
        cameraView.videoPreviewLayer.connection?.isEnabled = true
    }
}
