//
//  CameraVC+Focus.swift
//  FindAppClip1
//
//  Created by Zheng on 3/19/21.
//

import UIKit
import AVFoundation

extension CameraViewController {
    func focused(sender: UILongPressGestureRecognizer) {
        guard
            sender.state == .ended,
            !CurrentState.currentlyPaused
        else { return }
        
        let location = sender.location(in: focusView)
        let focusPoint = cameraView.videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: location) /// might be reversed horizontally
        
        if let device = cameraDevice {
            do {
                try device.lockForConfiguration()
                
                device.focusPointOfInterest = focusPoint
                device.focusMode = .autoFocus
                device.exposurePointOfInterest = focusPoint
                device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
                device.unlockForConfiguration()
            }
            catch {

            }
        }
        
        let focusViewIndicator = CameraFocusView()
        let focusLength: CGFloat = 100
        let halfFocusLength = focusLength / 2
        
        focusViewIndicator.frame = CGRect(x: location.x - halfFocusLength, y: location.y - halfFocusLength, width: focusLength, height: focusLength)
        
        focusViewIndicator.alpha = 0
        
        focusViewIndicator.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        
        let existingFocusViews = focusView.subviews
        focusView.addSubview(focusViewIndicator)
        
        UIView.animate(withDuration: 0.2) {
            for existingFocusView in existingFocusViews {
                existingFocusView.alpha = 0
                existingFocusView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
        }
        
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: .curveLinear) {
            focusViewIndicator.alpha = 1
            focusViewIndicator.transform = CGAffineTransform.identity
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveLinear) {
                    focusViewIndicator.alpha = 0
                    focusViewIndicator.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                } completion: { _ in
                    for existingFocusView in self.focusView.subviews {
                        if existingFocusView.alpha == 0 {
                            existingFocusView.removeFromSuperview()
                        }
                    }
                }
            }
        }
    }
    func removeFocusRects() {
        UIView.animate(withDuration: 0.2) {
            for existingFocusView in self.focusView.subviews {
                existingFocusView.alpha = 0
                existingFocusView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
        } completion: { _ in
            for existingFocusView in self.focusView.subviews {
                existingFocusView.removeFromSuperview()
            }
        }
    }
}
