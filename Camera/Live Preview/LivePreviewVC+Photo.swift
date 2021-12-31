//
//  LivePreviewVC+Photo.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/31/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//


import UIKit
import AVFoundation

extension LivePreviewViewController {
    func takePhoto(completion: @escaping ((UIImage) -> Void)) {
        let photoSettings = AVCapturePhotoSettings()
        let videoPreviewLayerOrientation = livePreviewView.videoPreviewLayer.connection?.videoOrientation
        
        if
            let photoOutputConnection = photoDataOutput.connection(with: .video),
            let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first
        {
            photoCaptured = { [weak self] image in
                completion(image)
                print("done.")
                self?.photoCaptured = nil
            }
            
            photoOutputConnection.videoOrientation = videoPreviewLayerOrientation!
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
            photoDataOutput.capturePhoto(with: photoSettings, delegate: self)
        }

    }
}
