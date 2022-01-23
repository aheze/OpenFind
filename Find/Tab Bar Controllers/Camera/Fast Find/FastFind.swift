//
//  FastFind.swift
//  Find
//
//  Created by Andrew on 12/21/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit
import Vision

extension CameraViewController {
    func fastFind(in pixelBuffer: CVPixelBuffer? = nil, orIn cgImage: CGImage? = nil) {
        /// busy finding
        busyFastFinding = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let pixelBuffer = pixelBuffer {
                let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
                self.pixelBufferSize = CGSize(width: ciImage.extent.height, height: ciImage.extent.width)
            } else if let cgImage = cgImage {
                let width = cgImage.width
                let height = cgImage.height
                self.pixelBufferSize = CGSize(width: width, height: height)
            }
            
            let request = VNRecognizeTextRequest { request, error in
                self.handleFastDetectedText(request: request, error: error)
            }
            
            var customFindArray = [String]()
            for list in self.selectedLists {
                for cont in list.words {
                    customFindArray.append(cont)
                    customFindArray.append(cont.lowercased())
                    customFindArray.append(cont.uppercased())
                    customFindArray.append(cont.capitalizingFirstLetter())
                }
            }
            
            request.customWords = [self.finalTextToFind, self.finalTextToFind.lowercased(), self.finalTextToFind.uppercased(), self.finalTextToFind.capitalizingFirstLetter()] + customFindArray
            
            request.recognitionLevel = .fast
            request.recognitionLanguages = Defaults.recognitionLanguages
            
            if let pixelBuffer = pixelBuffer {
                let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right)
                do {
                    try imageRequestHandler.perform([request])
                } catch {
                    self.busyFastFinding = false
                }
            } else if let cgImage = cgImage {
                let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: .up)
                do {
                    try imageRequestHandler.perform([request])
                } catch {
                    self.busyFastFinding = false
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
