//
//  ConvertPoint.swift
//  Find
//
//  Created by Andrew on 8/24/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import Foundation
import ARKit
import Vision

//MARK: FOCUSMODE ._. FIND in NODE
extension ViewController {
    func cartesianForPoint(point:CGPoint,extent:CGRect) -> CGPoint { return CGPoint(x: point.x,y: extent.height - point.y) }
    func findInNode(points: [CGPoint], buffer: CVPixelBuffer) {
        findingInNode = true
        
        var ciImage = CIImage(cvPixelBuffer: buffer).oriented(.right)
        let height = ciImage.extent.height
        let width = ciImage.extent.width
        let screenScale = UIScreen.main.bounds
        let sw = screenScale.width
        let sh = screenScale.height
        let correctScale = sw / sh
        let nw = height * correctScale
        var offSet = width - nw
        var nsw = offSet / 2
        
        let bufferRect = CGRect(x: nsw, y: 0, width: nw, height: height)
        
        var tL = points[3]
        var tR = points[2]
        var bL = points[1]
        var bR = points[0]
        tL.x /= sw
        tL.y /= sh
        tR.x /= sw
        tR.y /= sh
        bL.x /= sw
        bL.y /= sh
        bR.x /= sw
        bR.y /= sh
        guard let filter = CIFilter(name: "CIPerspectiveCorrection") else {
            print("Error: Rectangle detection failed - Could not create perspective correction filter.")
            return
        }
        ciImage = ciImage.cropped(to: bufferRect)
        let topLeft = CGPoint(x: tL.x * nw + nsw, y: tL.y * height)
        let topRight = CGPoint(x: tR.x * nw + nsw, y: tR.y * height)
        let bottomLeft = CGPoint(x: bL.x * nw + nsw, y: bL.y * height)
        let bottomRight = CGPoint(x: bR.x * nw + nsw, y: bR.y * height)
        var extent = CGRect(x: 0, y: 0, width: nw, height: height)
        filter.setValue(CIVector(cgPoint: cartesianForPoint(point: topLeft, extent: extent)), forKey: "inputTopLeft")
        filter.setValue(CIVector(cgPoint: cartesianForPoint(point: topRight, extent: extent)), forKey: "inputTopRight")
        filter.setValue(CIVector(cgPoint: cartesianForPoint(point: bottomLeft, extent: extent)), forKey: "inputBottomLeft")
        filter.setValue(CIVector(cgPoint: cartesianForPoint(point: bottomRight, extent: extent)), forKey: "inputBottomRight")

        filter.setValue(ciImage, forKey: kCIInputImageKey)
        guard var perspectiveImage: CIImage = filter.value(forKey: kCIOutputImageKey) as? CIImage else {
            print("Error: Rectangle detection failed - perspective correction filter has no output image.")
            return
        }
        let context = CIContext(options: nil)
//        var persOrient = perspectiveImage.oriented(.left)
        guard let cgImageOrig = context.createCGImage(perspectiveImage, from: perspectiveImage.extent) else {
            print("cgimage error")
            findingInNode = false
            return
        }
        
        let cgImageSize = CGSize(width: cgImageOrig.width, height: cgImageOrig.height)
        focusImageSize = cgImageSize
        extentOfPerspectiveImage = perspectiveImage.extent
        
        let requests = [focusTextDetectionRequest]
        let imageRequestHandler = VNImageRequestHandler(cgImage: cgImageOrig, orientation: CGImagePropertyOrientation.up, options: [:])
        do {
            try imageRequestHandler.perform(requests)
        } catch {
            print("Error occured \(error)")
        }
        
        findingInNode = false
    }
    
    func fadeFocusHighlights() {
        
        
        let firstFadeOutNodeAction = SCNAction.fadeOut(duration: 0.6)
        
        if focusHasFoundOne == true {
            if numberOfFocusTimes % 2 == 0 {
                
                for h in self.focusHighlightArray {
                    
                    h.runAction(firstFadeOutNodeAction, completionHandler: {() in
                        h.removeFromParentNode()
                        print("remove")
                    })
                    
                }
            } else {
                for h in self.secondFocusHighlightArray {
                    
                    h.runAction(firstFadeOutNodeAction, completionHandler: {
                        () in h.removeFromParentNode()
                        
                        print("remove123")
                    })
                    
                }
            }
        }
        
    }
    
}
