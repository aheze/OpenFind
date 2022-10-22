//
//  LivePreviewVC+Photo.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/31/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//

import AVFoundation
import UIKit

extension LivePreviewViewController {
    func takePhoto() async -> UIImage {
        let photoSettings = AVCapturePhotoSettings()
        let videoPreviewLayerOrientation = livePreviewView.videoPreviewLayer.connection?.videoOrientation

        if
            session.isRunning,
            let photoOutputConnection = photoDataOutput.connection(with: .video),
            let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first
        {
            photoOutputConnection.videoOrientation = videoPreviewLayerOrientation!
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
            photoDataOutput.capturePhoto(with: photoSettings, delegate: self)

            return await withCheckedContinuation { continuation in
                photoCaptured = { [weak self] image in
                    self?.photoCaptured = nil
                    continuation.resume(returning: image)
                }
            }
        } else {
            return UIImage()
        }
    }
}
