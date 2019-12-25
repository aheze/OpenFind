//
//  FastMode.swift
//  Find
//
//  Created by Andrew on 12/21/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit
import Vision

extension ViewController {
  
    func fastFind() {
      // print("status: \(fastFindingToggle)")
            if fastFindingToggle == .notBusy {
                fastFindingToggle = .busy
                guard let capturedImage = sceneView.session.currentFrame?.capturedImage else {
                     print("no captured image")
                     return
                }
                let ciImage = CIImage(cvPixelBuffer: capturedImage)
                let width = ciImage.extent.width
                let height = ciImage.extent.height
                sizeOfPixelBufferFast = CGSize(width: width, height: height)
                
                aspectRatioWidthOverHeight = height / width ///opposite
                if aspectRatioWidthOverHeight != CGFloat(0) {
                    aspectRatioSucceeded = true
                }
                let requests = [fastTextDetectionRequest]
                let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: capturedImage, orientation: .right, options: [:])
                do {
                    try imageRequestHandler.perform(requests)
                } catch let error {
                    print("Error: \(error)")
                }
                fastFindingToggle = .notBusy
            }
            
            
        
        
    }
}
    
    
    
