//
//  VC+DrawTrackers.swift
//  ARVision
//
//  Created by Zheng on 11/27/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import Vision

extension ViewController {
    func drawTrackers(_ trackers: [Tracker]) {
        for existingSubview in imageFitView.subviews {
            if existingSubview.layer.borderWidth != 1.5 {
                existingSubview.removeFromSuperview()
            }
        }
        for tracker in trackers {
            var adjustedBoundingBox = tracker.boundingBox
            
            /// adjust for vision coordinates
            adjustedBoundingBox.origin.y = 1 - tracker.boundingBox.minY - tracker.boundingBox.height
            
            let adjustedBoundingBoxScaled = adjustedBoundingBox.scaleTo(imageFitViewRect)
            let newView = UIView(frame: adjustedBoundingBoxScaled)
            
            if tracker.isActive {
                newView.addDebugBorders(.green, width: 1)
            } else {
                newView.addDebugBorders(.red, width: 0.5)
            }
            imageFitView.addSubview(newView)
            
        }
    }
}
