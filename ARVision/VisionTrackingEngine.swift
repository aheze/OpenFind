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
    
    /// request more trackers
    var reportTrackerCount: ((Int) -> Void)?
    
    var requestHandler: VNSequenceRequestHandler?
    var startTime: Date?
    var busy = false
    
    var trackers = [UUID: Tracker]()
        
    func beginTracking(with image: CVPixelBuffer, observations: [VNRecognizedTextObservation]) {
        
        var trackers = [UUID : Tracker]()
        
        /// text observations that met the criteria, in case I need more
        var availableTextObservations = [VNRecognizedTextObservation]()
        for candidateArea in VisionConstants.highlightCandidateAreas {
            if let firstObservation = observations.first(where: {
                $0.confidence >= VisionConstants.minimumFindConfidenceForTrackable &&
                candidateArea.contains(CGPoint(x: $0.boundingBox.midX, y: $0.boundingBox.midY))
            }) {
                
                /// add it to the available  text observations
                availableTextObservations.append(firstObservation)
                
                /// only use the first word for now
                let middleWordBoundingBox = VisionFindingUtilities.getMiddleWordBoundingBox(
                    textObservation: firstObservation
                )
                
                let trackingObservation = VNDetectedObjectObservation(boundingBox: middleWordBoundingBox.insetBy(dx: 0.005, dy: 0.005))
                let tracker = Tracker(objectObservation: trackingObservation, dateInitialized: Date())
                trackers[tracker.uuid] = tracker
            }
        }
        
        /// https://stackoverflow.com/a/47681156/14351818
        trackers = trackers.merging(self.trackers) { last, _ in last }
        trackers = keepBestTrackers(trackers)
        
        /// need more trackers!
        if trackers.count < VisionConstants.maxTrackers {
            var index = 0
            while trackers.count < VisionConstants.maxTrackers {
                
                guard let textObservation = availableTextObservations[safe: index] else {
                    break
                }
                
                let lastWordBoundingBox = VisionFindingUtilities.getWordBoundingBox(
                    textObservation: textObservation,
                    firstWord: false
                )
                let trackingObservation = VNDetectedObjectObservation(boundingBox: lastWordBoundingBox)
                let tracker = Tracker(objectObservation: trackingObservation, dateInitialized: Date())
                trackers[tracker.uuid] = tracker
                
                index += 1
            }
        }
        
        self.trackers = trackers
        startTime = Date()
        requestHandler = VNSequenceRequestHandler()
    }
    
    func updateTracking(with updatedImage: CVPixelBuffer, completion: @escaping (([Tracker]) -> Void)) {
        let timeSinceLastTracking = Date().seconds(from: startTime ?? Date())
        guard !busy, timeSinceLastTracking >= VisionConstants.debugDelay else { return }
        busy = true
        
        var newTrackers = [UUID : Tracker]()
        var trackingRequests = [VNRequest]()
        
        for tracker in trackers {
            let request = VNTrackObjectRequest(detectedObjectObservation: tracker.value.objectObservation) { request, error in }
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
                let previousTracker = trackers[observation.uuid]
                let newTracker = Tracker(objectObservation: observation, dateInitialized: previousTracker?.dateInitialized ?? Date())
                
                /// update, or remove
                if let updatedTracker = getUpdatedTracker(for: newTracker) {
                    newTrackers[observation.uuid] = updatedTracker
                }
            }
        }
        
        self.startTime = Date()
        self.trackers = newTrackers
        self.reportTrackerCount?(newTrackers.count)
        self.busy = false
        
        DispatchQueue.main.async {
            completion(Array(newTrackers.values))
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



enum RoundingPrecision {
    case ones
    case tenths
    case hundredths
}

// Round to the specific decimal place
func preciseRound(
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
