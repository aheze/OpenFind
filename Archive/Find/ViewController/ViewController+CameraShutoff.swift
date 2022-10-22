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
        camera.allowSearchFocus = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 8, execute: cameraShutoffTask)
    }

    func startCamera() {
        camera.allowSearchFocus = true
        cancelShutoff()
        camera.startSession()
    }

    func cancelShutoff() {
        cameraShutoffTask.cancel()
        cameraShutoffTask = DispatchWorkItem { self.shutoffCamera?() }
    }
}
