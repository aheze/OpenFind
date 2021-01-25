//
//  CameraVC+FindWhenPaused.swift
//  Find
//
//  Created by Zheng on 1/24/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension CameraViewController {
    func findWhenPaused() {
        if let currentImage = currentPausedImage, let cgImage = currentImage.cgImage {
            if allowSearch == true && displayingOrientationError == false && allowSearchFocus == true {
                if busyFastFinding {
                    waitingToFind = true
                } else {
                    fastFind(orIn: cgImage)
                }
            }
        }
    }
}
