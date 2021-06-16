//
//  CameraVC+Pause.swift
//  Find
//
//  Created by Zheng on 1/24/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import AVFoundation

extension CameraViewController {
    func pauseLivePreview() {
        currentlyCapturing = true
        cameraView.videoPreviewLayer.connection?.isEnabled = false
        let photoSettings = AVCapturePhotoSettings()
        
        let videoPreviewLayerOrientation = cameraView.videoPreviewLayer.connection?.videoOrientation
        if let photoOutputConnection = photoDataOutput.connection(with: .video) {
            photoOutputConnection.videoOrientation = videoPreviewLayerOrientation!
        }
        if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
            photoDataOutput.capturePhoto(with: photoSettings, delegate: self)
        }
        pausedAccessibility(paused: true)
    }
    func startLivePreview() {
        currentlyCapturing = false
        /// make sure it's running (can stop when going to app switcher and back)
        if !avSession.isRunning {
            self.avSession.startRunning()
        }
        cameraView.videoPreviewLayer.connection?.isEnabled = true
        self.showImageView(false)
        pausedAccessibility(paused: false)
    }
    
    func showImageView(_ show: Bool) {
        if show {
            pausedImageView.image = currentPausedImage
            pausedImageView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            UIView.animate(withDuration: 0.2) {
                self.pausedImageView.alpha = 1
                self.pausedImageView.transform = CGAffineTransform.identity
            }
        } else {
            UIView.animate(withDuration: 0.1) {
                self.pausedImageView.alpha = 0
                self.pausedImageView.transform = CGAffineTransform.identity
            }
        }
    }
    
    func removeFocusRects(_ remove: Bool) {
        focusView.isUserInteractionEnabled = !remove
        
        if remove {
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
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if currentlyCapturing {
            currentlyCapturing = false
            guard let imageData = photo.fileDataRepresentation() else { return }
            if let unrotatedImage = UIImage(data: imageData), let image = unrotatedImage.rotated() {
                self.currentPausedImage = image
                self.showImageView(true)
                self.findWhenPaused()
                self.cameraIcon.animateLoading(start: false)
            }
            switch UserDefaults.standard.integer(forKey: "hapticFeedbackLevel") {
            case 2:
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.prepare()
                generator.impactOccurred()
            case 3:
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.prepare()
                generator.impactOccurred()
            default:
                break
            }
        }
    }
}

extension UIImage {
    func rotated() -> UIImage? {
        if (self.imageOrientation == UIImage.Orientation.up ) {
            return self
        }
        UIGraphicsBeginImageContext(self.size)
        self.draw(in: CGRect(origin: CGPoint.zero, size: self.size))
        let copy = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return copy
    }
}
