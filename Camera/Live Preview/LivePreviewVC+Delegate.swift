//
//  LivePreviewVC+Delegate.swift
//  Camera
//
//  Created by Zheng on 11/21/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import AVFoundation
import UIKit

extension LivePreviewViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        frameCaptured?(pixelBuffer)
        
        let size = CVImageBufferGetDisplaySize(pixelBuffer)
        if imageSize == nil {
            imageSize = CGSize(width: size.height, height: size.width)
            needSafeViewUpdate?()
        }
    }
}

extension LivePreviewViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        
        if
            let image = UIImage(data: imageData),
            let photo = image.rotated()
        {
            photoCaptured?(photo)
        }
    }
}

extension UIImage {
    func rotated() -> UIImage? {
        if imageOrientation == UIImage.Orientation.up {
            return self
        }
        UIGraphicsBeginImageContext(size)
        draw(in: CGRect(origin: CGPoint.zero, size: size))
        let copy = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return copy
    }
}
