//
//  VTE+FilterTrackedObservations.swift
//  ARVision
//
//  Created by Zheng on 11/27/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import Vision

extension VisionTrackingEngine {
    func filterTrackedObservations(observations: [VNDetectedObjectObservation]) {
        let averageConfidence = observations.map { $0.confidence }.reduce(Float(0), +) / Float(observations.count)
        print("average: \(averageConfidence)")
        
        var keptObservations = observations
        keptObservations = keptObservations.filter { observation in
            if observation.confidence < averageConfidence {
                return false
            }
            
            if !VisionConstants.highlightTrackingArea.contains(CGPoint(x: observation.boundingBox.midX, y: observation.boundingBox.minY)) {
                return false
            }
            
            return true
        }
        
        
    }
}
