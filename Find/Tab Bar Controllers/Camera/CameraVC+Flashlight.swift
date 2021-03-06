//
//  CameraVC+Flashlight.swift
//  Find
//
//  Created by Zheng on 3/5/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension CameraViewController {
    func toggleFlashlight(_ on: Bool) {
        print("cam: \(cameraDevice)")
        print("Has? \(cameraDevice?.hasTorch)")
        guard
            let device = cameraDevice,
            device.hasTorch
        else {
            print("No device")
            return
            
        }
        
        
        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("Torch could not be used")
        }
        
    }
}
