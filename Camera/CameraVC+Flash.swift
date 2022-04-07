//
//  CameraVC+Flash.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/7/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

extension CameraViewController {
    func toggleFlashlight(_ on: Bool) {
        guard
            let device = livePreviewViewController.cameraDevice,
            device.hasTorch
        else {
            return
        }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
        } catch {}
    }
}
