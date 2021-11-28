//
//  VisionConstants.swift
//  ARVision
//
//  Created by Zheng on 11/27/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

struct VisionConstants {
    
    static var maxTrackers = 9
    
    /// number of seconds before starting another tracking request
    static var debugDelay = 0
    
    /// add highlights somewhere in this area
    static let highlightCandidateTotalArea = CGRect(x: 0.25, y: 0.3, width: 0.5, height: 0.4)
    
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
        
        print("candidates: \(candidates)")
        return candidates
    }()
}
