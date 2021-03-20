//
//  CameraVC+Find.swift
//  FindAppClip1
//
//  Created by Zheng on 3/14/21.
//

import UIKit
import Vision

class Component: NSObject {
    var x: CGFloat = 0
    var y: CGFloat = 0
    var height: CGFloat = 0
    var width: CGFloat = 0
    
    var text = ""
    var baseView: UIView?
}


extension CameraViewController {
    
    func fastFind(in pixelBuffer: CVPixelBuffer? = nil, orIn cgImage: CGImage? = nil) {
        
        /// busy finding
        busyFastFinding = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let request = VNRecognizeTextRequest { request, error in
                self.handleFastDetectedText(request: request, error: error)
            }
            
            if let pixelBuffer = pixelBuffer {
                let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
                self.pixelBufferSize = CGSize(width: ciImage.extent.height, height: ciImage.extent.width)
            } else if let cgImage = cgImage {
                let width = cgImage.width
                let height = cgImage.height
                self.pixelBufferSize = CGSize(width: width, height: height)
            }
            
            
            var customFindArray = [String]()
            customFindArray.append(self.findText)
            customFindArray.append(self.findText.lowercased())
            customFindArray.append(self.findText.uppercased())
            customFindArray.append(self.findText.capitalizingFirstLetter())
            
            request.customWords = customFindArray
            
            request.recognitionLevel = .fast
            request.recognitionLanguages = ["en_GB"]
            
            if let pixelBuffer = pixelBuffer {
                let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right)
                do {
                    try imageRequestHandler.perform([request])
                } catch let error {
                    self.busyFastFinding = false
                    print("Error: \(error)")
                }
            } else if let cgImage = cgImage {
                let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: .up)
                do {
                    try imageRequestHandler.perform([request])
                } catch let error {
                    self.busyFastFinding = false
                    print("Error: \(error)")
                }
            }
        }
    }
    
    func getConvertedRect(boundingBox: CGRect, inImage imageSize: CGSize, containedIn containerSize: CGSize) -> CGRect {
        
        let rectOfImage: CGRect
        
        let imageAspect = imageSize.width / imageSize.height
        let containerAspect = containerSize.width / containerSize.height
        
        if imageAspect > containerAspect { /// image extends left and right
            let newImageWidth = containerSize.height * imageAspect /// the width of the overflowing image
            let newX = -(newImageWidth - containerSize.width) / 2
            rectOfImage = CGRect(x: newX, y: 0, width: newImageWidth, height: containerSize.height)
            
        } else { /// image extends top and bottom
            let newImageHeight = containerSize.width * (1 / imageAspect) /// the width of the overflowing image
            let newY = -(newImageHeight - containerSize.height) / 2
            rectOfImage = CGRect(x: 0, y: newY, width: containerSize.width, height: newImageHeight)
        }
        
        let newOriginBoundingBox = CGRect(
        x: boundingBox.origin.x,
        y: 1 - boundingBox.origin.y - boundingBox.height,
        width: boundingBox.width,
        height: boundingBox.height
        )
        
        var convertedRect = VNImageRectForNormalizedRect(newOriginBoundingBox, Int(rectOfImage.width), Int(rectOfImage.height))
        
        /// add the margins
        convertedRect.origin.x += rectOfImage.origin.x
        convertedRect.origin.y += rectOfImage.origin.y
        
        return convertedRect
    }
}
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}

