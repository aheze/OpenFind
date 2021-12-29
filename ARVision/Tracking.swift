//
//  Tracking.swift
//  ARVision
//
//  Created by Zheng on 11/28/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import Vision

struct Tracker {
    let objectObservation: VNDetectedObjectObservation
    let dateInitialized: Date
    
    init(objectObservation: VNDetectedObjectObservation, dateInitialized: Date) {
        self.objectObservation = objectObservation
        self.dateInitialized = dateInitialized
    }
    
    /// the date when the observation's confidence dropper
    /// wait 1.5 seconds for it to become accurate again.
    /// - if became accurate, set this to `nil`
    /// - if not, remove the observation
    var dateWhenBecameInaccurate: Date?
    
    var timeSinceInitialization: TimeInterval {
        return dateInitialized.distance(to: Date())
    }
    
    var uuid: UUID {
        return objectObservation.uuid
    }
    
    var confidence: VNConfidence {
        return objectObservation.confidence
    }
    
    var boundingBox: CGRect {
        return objectObservation.boundingBox
    }
    
    var isActive: Bool {
        let confident = confidence > VisionConstants.minimumConfidenceForSuccess
        let oldEnough = timeSinceInitialization > Double(VisionConstants.minimumTimeSinceInitialization)
        return confident && oldEnough
    }
}
