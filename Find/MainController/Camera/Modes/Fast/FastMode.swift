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
  
    func fastFind(in pixelBuffer: CVPixelBuffer) {
        busyFastFinding = true
       
        DispatchQueue.global(qos: .background).async {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let width = ciImage.extent.width
            let height = ciImage.extent.height
            self.sizeOfPixelBufferFast = CGSize(width: width, height: height)
            
            self.aspectRatioWidthOverHeight = height / width ///opposite
            if self.aspectRatioWidthOverHeight != CGFloat(0) {
                self.aspectRatioSucceeded = true
            }
            //let request = fastTextDetectionRequest
            let request = VNRecognizeTextRequest { request, error in
                self.handleFastDetectedText(request: request, error: error)
            }
            request.customWords = [self.finalTextToFind, self.finalTextToFind.lowercased(), self.finalTextToFind.uppercased(), self.finalTextToFind.capitalizingFirstLetter()]
            
            request.recognitionLevel = .fast
            request.recognitionLanguages = ["en_GB"]
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right)
            //DispatchQueue.global().async {
                do {
                    try imageRequestHandler.perform([request])
                } catch let error {
                    self.busyFastFinding = false
                    print("Error: \(error)")
                }
            //}
        }
        
        
        
        
    }
    
}
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
