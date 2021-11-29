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
    
    func beginTracking(with image: CVPixelBuffer, observations: [VNRecognizedTextObservation]) {
        print("starting new tracking session")
        
        var trackingObservations = [UUID : VNDetectedObjectObservation]()
        
        /// text observations that met the criteria, in case I need more
        var availableTextObservations = [VNRecognizedTextObservation]()
        for candidateArea in VisionConstants.highlightCandidateAreas {
            if let firstObservation = observations.first(where: {
                $0.confidence >= 1 &&
                candidateArea.contains(CGPoint(x: $0.boundingBox.midX, y: $0.boundingBox.midY)) &&
                $0.confidence >= 1
            }) {
                
                /// add it to the available  text observations
                availableTextObservations.append(firstObservation)
                
                /// only use the first word for now
                let firstWordBoundingBox = VisionFindingUtilities.getWordBoundingBox(
                    textObservation: firstObservation,
                    firstWord: true
                )
                
                let trackingObservation = VNDetectedObjectObservation(boundingBox: firstWordBoundingBox)
                trackingObservations[trackingObservation.uuid] = trackingObservation
            }
        }
        
        /// need more trackers!
        if trackingObservations.count < VisionConstants.maxTrackers {
            var index = 0
            while trackingObservations.count < VisionConstants.maxTrackers {
                
                guard let textObservation = availableTextObservations[safe: index] else {
                    break
                }
                
                let lastWordBoundingBox = VisionFindingUtilities.getWordBoundingBox(
                    textObservation: textObservation,
                    firstWord: false
                )
                let trackingObservation = VNDetectedObjectObservation(boundingBox: lastWordBoundingBox)
                trackingObservations[trackingObservation.uuid] = trackingObservation
                
                index += 1
            }
        }
        
        self.trackingObservations = trackingObservations
        startTime = Date()
        requestHandler = VNSequenceRequestHandler()
    }
    
    func updateTracking(with updatedImage: CVPixelBuffer, completion: @escaping (([VNDetectedObjectObservation]) -> Void)) {
        let timeSinceLastTracking = Date().seconds(from: startTime ?? Date())
        guard !busy, timeSinceLastTracking >= VisionConstants.debugDelay else { return }
        busy = true
        
        var newTrackingObservations = [UUID : VNDetectedObjectObservation]()
        var trackingRequests = [VNRequest]()
        
        for trackingObservation in trackingObservations {
            let request = VNTrackObjectRequest(detectedObjectObservation: trackingObservation.value) { request, error in }
            request.trackingLevel = .accurate
            trackingRequests.append(request)
        }
        
        do {
            try requestHandler?.perform(trackingRequests, on: updatedImage, orientation: .up)
        } catch {
            print("Error performing request: \(error)")
            busy = false
        }
        
        for request in trackingRequests {
            if let observation = getRequestedObservation(request: request) {
                newTrackingObservations[observation.uuid] = observation
            }
        }
        self.startTime = Date()
        self.trackingObservations = newTrackingObservations
        self.busy = false
        
        DispatchQueue.main.async {
            completion(Array(newTrackingObservations.values))
        }
    }
    
    func getRequestedObservation(request: VNRequest) -> VNDetectedObjectObservation? {
        guard
            let results = request.results,
            let observation = results.compactMap({ $0 as? VNDetectedObjectObservation }).first
        else {
            return nil
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
