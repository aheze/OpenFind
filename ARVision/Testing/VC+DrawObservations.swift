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
//        print("darw!")
        for existingSubview in imageFitView.subviews {
//            print("widt: \(existingSubview.layer.borderWidth)")
            if existingSubview.layer.borderWidth != 1.5 {
                existingSubview.removeFromSuperview()
            }
        }
        print("draing--------count: \(observations.count)")
        for observation in observations {
            var adjustedBoundingBox = observation.boundingBox
            
            /// adjust for vision coordinates
            adjustedBoundingBox.origin.y = 1 - observation.boundingBox.minY - observation.boundingBox.height
            
            let adjustedBoundingBoxScaled = adjustedBoundingBox.scaleTo(imageFitViewRect)
            let newView = UIView(frame: adjustedBoundingBoxScaled)
            newView.addDebugBorders(.green, width: 1)
            imageFitView.addSubview(newView)
            
            print(adjustedBoundingBoxScaled)
        }
//        for observation in observations {
//            let scaledRect = observation.boundingBox.scaleTo(imageFitViewRect)
//
//            let trackerView = UIView(frame: scaledRect)
//            trackerView.addDebugBorders(.green)
//            imageFitView.addSubview(trackerView)
//        }
        
    }
}
