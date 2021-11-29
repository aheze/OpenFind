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
    func getUpdatedTracker(for tracker: Tracker) -> Tracker? {
        //        let averageConfidence = trackers.map { $0.confidence }.reduce(Float(0), +) / Float(trackers.count)
        //        print("average: \(averageConfidence)")
        
        //        var keptObservations = observations
        
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
    //    func filterTrackers(trackers: [Tracker]) -> [Tracker] {
    //        let averageConfidence = trackers.map { $0.confidence }.reduce(Float(0), +) / Float(trackers.count)
    //        print("average: \(averageConfidence)")
    //
    ////        var keptObservations = observations
    //
    //        var newTrackers = [Tracker]()
    //        for tracker in trackers {
    //            if !VisionConstants.highlightTrackingArea.contains(
    //                CGPoint(x: tracker.boundingBox.midX, y: tracker.boundingBox.minY)
    //            ) {
    //                continue /// immediately remove this tracker
    //            }
    //
    //            var newTracker = tracker
    //            if
    //                newTracker.dateWhenBecameInaccurate == nil,
    //                newTracker.confidence < averageConfidence
    //            {
    //                newTracker.dateWhenBecameInaccurate = Date()
    //            }
    //            newTrackers.append(newTracker)
    //        }
    //
    //        return newTrackers
    //
    //    }
}
