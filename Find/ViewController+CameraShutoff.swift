//
//  ViewController+CameraShutoff.swift
//  Find
//
//  Created by Zheng on 1/7/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension ViewController {
    /// navigated away from camera
    func startCameraShutoff() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: cameraShutoffTask)
    }
    func cancelShutoff() {
        cameraShutoffTask.cancel()
    }
    func shutoffCamera() -> (() -> Void) {
        let shutoffBlock = {
            print("Shutt off cam!!")
        }
        
        return shutoffBlock
    }
}
