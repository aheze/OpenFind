//
//  VisionConstants.swift
//  ARVision
//
//  Created by Zheng on 11/27/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

struct VisionConstants {
    
    // MARK: Finding
    
    /// how long to wait between finds
    static var findCoolDownTime = 1.8
    static var minimumFindConfidenceForTrackable: Float = 0.4
    
    // MARK: Tracking
    static var maximumTimeWithoutConfidence: Float = 1.5
    static var minimumConfidenceForSuccess: Float = 0.5
    static var minimumTimeSinceInitialization: Float = 0.2
    static var maxTrackers = 12
    static var trackerMinimumProximitySquared = pow(Float(8) / Float(300), 2)
    
    /// number of seconds before starting another tracking request
    static var debugDelay = 0
    
    /// add highlights somewhere in this area
    static let highlightCandidateTotalArea = CGRect(x: 0.25, y: 0.1, width: 0.5, height: 0.8)
    
    /// tracking area, if go out, cut it off
    static let highlightTrackingArea = CGRect(x: 0.06, y: 0.06, width: 0.88, height: 0.88)
    
    static var highlightCandidateAreas: [CGRect] = {
        var candidates = [CGRect]()
        
        let horizontalAreaLength = (highlightCandidateTotalArea.maxX - highlightCandidateTotalArea.minX) / 3
        for xOrigin in stride(
            from: highlightCandidateTotalArea.minX,
            to: highlightCandidateTotalArea.maxX,
            by: horizontalAreaLength
        ) {
            let verticalAreaLength = (highlightCandidateTotalArea.maxY - highlightCandidateTotalArea.minY) / 3
            for yOrigin in stride(
                from: highlightCandidateTotalArea.minY,
                to: highlightCandidateTotalArea.maxY,
                by: verticalAreaLength
            ) {
                let rectangle = CGRect(
                        x: xOrigin,
                        y: yOrigin,
                        width: horizontalAreaLength,
                        height: verticalAreaLength
                )
                candidates.append(rectangle)
            }
        }
        

        return candidates
    }()
}
