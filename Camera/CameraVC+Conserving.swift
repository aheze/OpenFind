//
//  CameraVC+Conserving.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import CoreMotion
import UIKit

extension CameraViewController {
    /// conserve resources by stopping finding from the live preview
    func stopLivePreviewScanning() {
        Find.prioritizedAction = nil
        model.livePreviewScanning = false
        presentStatusView()

        model.motionManager = CMMotionManager()
        model.motionManager?.accelerometerUpdateInterval = 0.2

        /// Wait a bit, because the phone might still be shaking from being put down
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.model.motionManager?.startAccelerometerUpdates(to: .main) { [weak self] data, error in
                guard let data = data, error == nil else { return }
                let acceleration = data.acceleration.x + data.acceleration.y

                if abs(acceleration) >= 0.6 {
                    self?.resumeLivePreviewScanning()
                }
            }
        }
    }

    func resumeLivePreviewScanning() {
        Find.prioritizedAction = .camera
        model.motionManager?.stopAccelerometerUpdates()
        model.motionManager = nil
        model.livePreviewScanning = true
        hideStatusView()
    }
}
