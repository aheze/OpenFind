//
//  CameraVC+Focus.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import AVFoundation
import UIKit

extension CameraViewController {
    func setupFocusGesture() {
        _ = focusGestureRecognizer
        focusGestureRecognizer.minimumPressDuration = 0
        focusGestureRecognizer.addTarget(self, action: #selector(focusTapped))
        focusGestureRecognizer.delegate = self
        safeView.addGestureRecognizer(focusGestureRecognizer)
    }

    @objc func focusTapped(gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began else {
            gestureRecognizer.isEnabled = false
            gestureRecognizer.isEnabled = true
            return
        }
        guard let livePreviewViewController = livePreviewViewController else { return }
        let location = gestureRecognizer.location(in: livePreviewViewController.livePreviewView)
        focus(at: location)
        
        let visibleLocation = gestureRecognizer.location(in: safeView)
        addFocusIndicator(at: visibleLocation)
    }
    
    func addFocusIndicator(at point: CGPoint) {
        let currentUUID = UUID()
        model.currentFocusUUID = currentUUID
        
        func getExistingFocusIndicators() -> [FocusIndicatorView] {
            let views = view.subviews.compactMap { $0 as? FocusIndicatorView }
            return views
        }
        
        func hideExistingFocusIndicators() {
            UIView.animate(withDuration: 0.2) {
                for existingFocusView in getExistingFocusIndicators() {
                    existingFocusView.alpha = 0
                    existingFocusView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                }
            }
        }
        func removeExistingFocusIndicators() {
            for existingFocusView in getExistingFocusIndicators() {
                existingFocusView.removeFromSuperview()
            }
        }
        
        hideExistingFocusIndicators()
        
        let indicatorView = FocusIndicatorView()
        indicatorView.frame = CGRect(
            x: point.x - CameraConstants.focusIndicatorLength / 2,
            y: point.y - CameraConstants.focusIndicatorLength / 2,
            width: CameraConstants.focusIndicatorLength,
            height: CameraConstants.focusIndicatorLength
        )
        safeView.addSubview(indicatorView)

        indicatorView.alpha = 0
        indicatorView.transform = .init(scaleX: 1.1, y: 1.1)

        UIView.animate(duration: 0.6, dampingFraction: 0.8) {
            indicatorView.alpha = 1
            indicatorView.transform = .identity
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            UIView.animate(duration: 0.6, dampingFraction: 0.8) {
                indicatorView.alpha = 0
                indicatorView.transform = .init(scaleX: 0.3, y: 0.3)
            } completion: {
                if currentUUID == self.model.currentFocusUUID {
                    self.model.currentFocusUUID = nil
                    removeExistingFocusIndicators()
                }
            }
        }
    }
    
    func focus(at point: CGPoint) {
        guard let livePreviewViewController = livePreviewViewController else { return }
        let focusPoint = livePreviewViewController.livePreviewView.videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: point) /// might be reversed horizontally
        
        if let device = livePreviewViewController.cameraDevice {
            do {
                try device.lockForConfiguration()
                
                device.focusPointOfInterest = focusPoint
                device.focusMode = .autoFocus
                device.exposurePointOfInterest = focusPoint
                device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
                device.unlockForConfiguration()
            } catch {}
        }
    }
}

extension CameraViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
