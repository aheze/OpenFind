//
//  CameraVC+Static.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/31/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//
    

import UIKit

/**
 When the camera view controller is paused
 */

extension CameraViewController {
    func pause(_ isPaused: Bool) {
        if isPaused {
            livePreviewViewController.takePhoto { image in
                print("imagegot!")
            }
        }
    }
}
