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
        print("find")
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
            request.progressHandler = { (request, value, error) in
                //print(value)
                self.updateStatusViewProgress(to: CGFloat(value))
            }
            
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
    func updateStatusViewProgress(to value: CGFloat) {
       // print("changing")
        changeDelegate?.changeValue(to: value)
//        DispatchQueue.main.async {
//            if let sublayers = self.statusView.layer.sublayers {
//                for shapeLayer in sublayers {
//                    // ...
//                    if shapeLayer.name == "shape" {
//                        print("ads")
//                        let s = shapeLayer as! CAShapeLayer
//                        //s.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
//                        //s.strokeColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1).cgColor
//                        //s.lineWidth = 5
//                        //s.path = path.cgPath
//                        //s.strokeStart = 0.8
//
////                        let startAnimation = CABasicAnimation(keyPath: "strokeStart")
////                        startAnimation.fromValue = 0
////                        startAnimation.toValue = 0.8
//
//                        let endAnimation = CABasicAnimation(keyPath: "strokeEnd")
//                        //endAnimation.fromValue = 0.1
//                        endAnimation.toValue = value
//
//                        let animation = CAAnimationGroup()
//                        animation.animations = [endAnimation]
//                        animation.duration = 0.1
//                        s.add(animation, forKey: "MyAnimation")
//
//                    }
//                }
//            }
//        }
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
