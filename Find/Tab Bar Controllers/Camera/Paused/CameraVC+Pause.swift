//
//  CameraVC+Pause.swift
//  Find
//
//  Created by Zheng on 1/24/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension CameraViewController {
    func pauseLivePreview() {
        cameraView.videoPreviewLayer.connection?.isEnabled = false
        capturePhoto { image in
            self.currentPausedImage = image
            
//            let date = Date()
//            let formatter = DateFormatter()
//            formatter.dateFormat = "MMddyy"
//            let dateAsString = formatter.string(from: date)
//
//            let timeFormatter = DateFormatter()
//            timeFormatter.dateFormat = "HHmmss-SSSS"
//            let timeAsString = timeFormatter.string(from: date)
//            print("Date=\(dateAsString), time=\(timeAsString)")
//            self.saveImage(url: self.globalUrl, imageName: "=\(dateAsString)=\(timeAsString)", image: image, dateCreated: date)
        }
        
        
    }
    func startLivePreview() {
        cameraView.videoPreviewLayer.connection?.isEnabled = true
        
        
        
    }
    
    
}
