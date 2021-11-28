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
    var startTime: Date?
    var busy = false
    
    var trackingObservations = [UUID : VNDetectedObjectObservation]()
    
//    var referenceTrackingRect: CGRect?
    
    func beginTracking(with image: CVPixelBuffer, observations: [VNRecognizedTextObservation]) {
        print("staritn new tradking session")
//        self.referenceTrackingRect = nil
        
        var trackingObservations = [UUID : VNDetectedObjectObservation]()
        for candidateArea in VisionConstants.highlightCandidateAreas {
            if let firstObservation = observations.first(where: {
                $0.confidence >= 1 &&
                candidateArea.contains(CGPoint(x: $0.boundingBox.midX, y: $0.boundingBox.midY)) &&
                $0.confidence >= 1
            }) {
                let trackingObservation = VNDetectedObjectObservation(boundingBox: firstObservation.boundingBox)
                trackingObservations[trackingObservation.uuid] = trackingObservation
            }
        }
        self.trackingObservations = trackingObservations
        startTime = Date()
        requestHandler = VNSequenceRequestHandler()
    }
    func updateTracking(with updatedImage: CVPixelBuffer, completion: @escaping ((CGSize) -> Void)) {
        let timeSinceLastTracking = Date().seconds(from: startTime ?? Date())
        guard !busy, timeSinceLastTracking > VisionConstants.debugDelay else { return }
        busy = true
        
        let group = DispatchGroup()
        
        var newTrackingObservations = [UUID : VNDetectedObjectObservation]()
        var trackingRequests = [VNRequest]()
        
        
        for trackingObservation in trackingObservations {
            group.enter()
            
            let request = VNTrackObjectRequest(detectedObjectObservation: trackingObservation.value) { request, error in
                let newObservation = self.getRequestedObservation(request: request)
                newTrackingObservations[trackingObservation.key] = newObservation
                group.leave()
            }
            request.trackingLevel = .accurate
            trackingRequests.append(request)
        }
        
        print("resustss: \(trackingRequests)")
        
        do {
            try requestHandler?.perform(trackingRequests, on: updatedImage)
        } catch {
            print("Error performing request: \(error)")
            busy = false
        }
    
        group.notify(queue: .main) {
            self.startTime = Date()
            self.busy = false
            print("Done!")
            print("Old: \(self.trackingObservations.values.map { "(\(preciseRound($0.boundingBox.midX)), \(preciseRound($0.boundingBox.midY)))" })")
            print("New: \(newTrackingObservations.values.map { "(\(preciseRound($0.boundingBox.midX)), \(preciseRound($0.boundingBox.midY)))" })")
            self.trackingObservations = newTrackingObservations
        }
        
        
        
//
//        if self.startTime.isPastCoolDown(Constants.waitTimeUntilTracking) {
//
//            DispatchQueue.main.async {
//                /// make sure it's still the same tracking session
//                if startTime == self.startTime {
//                    if let referenceTrackingRect = self.referenceTrackingRect {
//                        let xDifference = rect.midX - referenceTrackingRect.midX
//                        let yDifference = rect.midY - referenceTrackingRect.midY
//                        completion(CGSize(width: xDifference, height: yDifference))
//                    } else {
//                        self.referenceTrackingRect = rect
//                    }
//                }
//            }
//        }
    }
    func getRequestedObservation(request: VNRequest) -> VNDetectedObjectObservation {
        guard
            let results = request.results,
            let observation = results.compactMap({ $0 as? VNDetectedObjectObservation }).first
        else {
            return VNDetectedObjectObservation(boundingBox: .zero)
        }
        return observation
        
    }
}



public enum RoundingPrecision {
    case ones
    case tenths
    case hundredths
}

// Round to the specific decimal place
public func preciseRound(
    _ value: CGFloat,
    precision: RoundingPrecision = .hundredths) -> Double
{
    let double = Double(value)
    switch precision {
    case .ones:
        return round(double)
    case .tenths:
        return round(double * 10) / 10.0
    case .hundredths:
        return round(double * 100) / 100.0
    }
}
