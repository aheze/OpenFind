//
//  ProcessImage.swift
//  Find
//
//  Created by Andrew on 10/13/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import Foundation
import ARKit
import Vision

extension ViewController {
    func processImage() {
        isBusyProcessingImage = true
        processImageNumberOfPasses += 1
        
        
        
        guard let capturedImage = sceneView.session.currentFrame?.capturedImage else {
            print("no captured image")
            processImageNumberOfPasses -= 1
            isBusyProcessingImage = false
            return
        }
        let requests = [textDetectionRequest]
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: capturedImage, orientation: .right, options: [:])
        
            do {
                try imageRequestHandler.perform(requests)
            } catch let error {
                self.isBusyProcessingImage = false
                print("Error: \(error)")
            }
        //matchesCanAcceptNewValue = false
        isBusyProcessingImage = false
    }
    func fadeHighlights() {
        let firstFadeOutNodeAction = SCNAction.fadeOut(duration: 0.6)

        if classicHasFoundOne == true {
            
            if classicHighlightArray.count >= 1, secondClassicHighlightArray.count >= 1 {
            if processImageNumberOfPasses % 2 == 0 {
                for h in classicHighlightArray {
                    
                    h.runAction(firstFadeOutNodeAction, completionHandler: {() in
                        h.removeFromParentNode()
                        //print("removeNormal")
                    })
                }
            } else {
                for h in secondClassicHighlightArray {
                    
                    h.runAction(firstFadeOutNodeAction, completionHandler: {
                        () in h.removeFromParentNode()
                        
                        //print("removeAlternate")
                    })
                }
            }
            }
            
        }
    }
}
