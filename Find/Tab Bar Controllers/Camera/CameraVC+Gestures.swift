//
//  CameraVC+Gestures.swift
//  Find
//
//  Created by Zheng on 3/6/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension CameraViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: focusView)
        
        let cameraFrame = passthroughGroupView.convert(cameraIconHolder.frame, to: focusView)
        if cameraFrame.contains(location) {
            return false
        }
        return true
    }
}
