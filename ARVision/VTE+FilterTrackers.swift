//
//  VTE+FilterTrackers.swift
//  ARVision
//
//  Created by Zheng on 11/27/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import Vision

extension VisionTrackingEngine {
    func keepBestTrackers(_ trackers: [UUID: Tracker]) -> [UUID: Tracker] {
        guard trackers.count > 0 else { return [:] }
        let averageConfidence = trackers.map { $0.value.confidence }.reduce(Float(0), +) / Float(trackers.count)
        
        var keptTrackers = [UUID: Tracker]()
        for (uuid, tracker) in trackers {
            if !keptTrackers.contains(where: {
                let distance = CGPointDistanceSquared(
                    from: CGPoint(x: $0.value.boundingBox.midX, y: $0.value.boundingBox.midY),
                    to: CGPoint(x: tracker.boundingBox.midX, y: tracker.boundingBox.midY)
                )

                return distance <= CGFloat(VisionConstants.trackerMinimumProximitySquared)
            }), tracker.confidence >= averageConfidence {
                keptTrackers[uuid] = tracker
            }
        }
        
        return keptTrackers
    }
    
    func getUpdatedTracker(for tracker: Tracker) -> Tracker? {
        if !VisionConstants.highlightTrackingArea.contains(
            tracker.boundingBox
        ) {
            return nil /// immediately remove this tracker
        }
        
        var newTracker = tracker
        
        if let dateWhenBecameInaccurate = newTracker.dateWhenBecameInaccurate {
            if newTracker.confidence < VisionConstants.minimumConfidenceForSuccess {
                newTracker.dateWhenBecameInaccurate = nil
            } else if dateWhenBecameInaccurate.distance(to: Date()) > Double(VisionConstants.maximumTimeWithoutConfidence) {
                return nil
            }
        } else if newTracker.confidence < VisionConstants.minimumConfidenceForSuccess {
            newTracker.dateWhenBecameInaccurate = Date()
        }
        
        return newTracker
    }
}
