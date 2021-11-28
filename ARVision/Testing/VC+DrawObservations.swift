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
        print("darw!")
        for existingSubview in imageFitView.subviews {
            existingSubview.removeFromSuperview()
        }
        
        for observation in observations {
            let scaledRect = observation.boundingBox.scaleTo(imageFitViewRect)
            
            let trackerView = UIView(frame: scaledRect)
            trackerView.addDebugBorders(.green)
            imageFitView.addSubview(trackerView)
        }
        
    }
}
