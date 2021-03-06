//
//  CameraVC+Flashlight.swift
//  Find
//
//  Created by Zheng on 3/5/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension CameraViewController {
    
    /// lock when preview is paused
    func lockFlashlight(lock: Bool) {
        flashButton.isEnabled = !lock
        
        UIView.animate(withDuration: 0.5) {
            self.flashImageView.alpha = lock ? 0.5 : 1
        }
        
        if flashlightOn {
            if lock {
                toggleFlashlight(false)
            } else {
                toggleFlashlight(true)
            }
        }
    }
    
    func toggleFlashlight(_ on: Bool) {
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
        
        let flashlightImage = on ? UIImage(systemName: "flashlight.on.fill") : UIImage(systemName: "flashlight.off.fill")
        UIView.transition(
            with: flashImageView,
            duration: 0.75,
            options: .transitionCrossDissolve,
            animations: { self.flashImageView.image = flashlightImage },
            completion: nil
        )
        
        UIView.animate(withDuration: 0.1) {
            self.flashView.backgroundColor = on ? #colorLiteral(red: 0.5, green: 0.4678574155, blue: 0, alpha: 0.75) : UIColor(named: "50Black")
        }
        
    }
}
