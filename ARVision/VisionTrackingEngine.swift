//
//  VisionTrackingEngine.swift
//  ARVision
//
//  Created by Zheng on 11/24/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import Vision

class VisionTrackingEngine {
    var requestHandler: VNSequenceRequestHandler?
    var previousObservation: VNDetectedObjectObservation?
    var startTime: Date?
    
    
    var referenceTrackingRect: CGRect?
    
    func beginTracking(with image: CVPixelBuffer, boundingBox: CGRect) {
        print("staritn new tradking session")
        self.referenceTrackingRect = nil
        startTime = Date()
        let startObservation = VNDetectedObjectObservation(boundingBox: boundingBox)
        previousObservation = startObservation
        requestHandler = VNSequenceRequestHandler()
    }
    func updateTracking(with updatedImage: CVPixelBuffer, completion: @escaping ((CGSize) -> Void)) {
        guard let previousObservation = previousObservation else { return }
        let startTime = startTime
        let request = VNTrackObjectRequest(detectedObjectObservation: previousObservation) { request, error in
            let rect = self.processRequestTranslation(request: request)
            if self.startTime.isPastCoolDown(Constants.waitTimeUntilTracking) {
                
                DispatchQueue.main.async {
                    /// make sure it's still the same tracking session
                    if startTime == self.startTime {
                        if let referenceTrackingRect = self.referenceTrackingRect {
                            let xDifference = rect.midX - referenceTrackingRect.midX
                            let yDifference = rect.midY - referenceTrackingRect.midY
                            completion(CGSize(width: xDifference, height: yDifference))
                        } else {
                            self.referenceTrackingRect = rect
                        }
                    }
                }
            }
        }
        
        request.trackingLevel = .accurate
        
        do {
            try requestHandler?.perform([request], on: updatedImage)
        } catch {
            print("Error performing request: \(error)")
        }
        
    }
    func processRequestTranslation(request: VNRequest) -> CGRect {
        guard
            let results = request.results,
            let observation = results.compactMap({ $0 as? VNDetectedObjectObservation }).first
        else {
            previousObservation = nil
            startTime = nil
            return .zero
        }
        let boundingBox = observation.boundingBox
        previousObservation = observation
        return boundingBox
        
    }
}
