//
//  VC+DrawObservations.swift
//  ARVision
//
//  Created by Zheng on 11/27/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import Vision

extension ViewController {
    func drawObservations(_ observations: [VNDetectedObjectObservation]) {
        for existingSubview in imageFitView.subviews {
            if existingSubview.layer.borderWidth != 1.5 {
                existingSubview.removeFromSuperview()
            }
        }
        for observation in observations {
            var adjustedBoundingBox = observation.boundingBox
            
            /// adjust for vision coordinates
            adjustedBoundingBox.origin.y = 1 - observation.boundingBox.minY - observation.boundingBox.height
            
            let adjustedBoundingBoxScaled = adjustedBoundingBox.scaleTo(imageFitViewRect)
            let newView = UIView(frame: adjustedBoundingBoxScaled)
            newView.addDebugBorders(.green, width: 1)
            imageFitView.addSubview(newView)
            
        }
    }
}
