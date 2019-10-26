//
//  ARExtensions.swift
//  Find
//
//  Created by Andrew on 10/25/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit
import ARKit

extension ViewController {
    func runImageTrackingSession(with trackingImages: Set<ARReferenceImage>,
                                         runOptions: ARSession.RunOptions = [.removeExistingAnchors, .resetTracking]) {
        let configuration = ARImageTrackingConfiguration()
        configuration.maximumNumberOfTrackedImages = 20
        configuration.trackingImages = trackingImages
        sceneView.session.run(configuration, options: runOptions)
        print("run image tracking session")
    }
}
