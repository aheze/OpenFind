//
//  CameraVC+Gestures.swift
//  FindAppClip1
//
//  Created by Zheng on 3/19/21.
//

import UIKit

extension CameraViewController: UIGestureRecognizerDelegate {
    func setupGestures() {
        focusGestureRecognizer.delegate = self
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == focusGestureRecognizer {
            return true
        }
        return false
    }
}
