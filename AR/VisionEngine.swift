//
//  VisionEngine.swift
//  AR
//
//  Created by Zheng on 11/24/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import Vision

class VisionEngine {
    var requestHandler: VNSequenceRequestHandler?
    var previousObservation: VNDetectedObjectObservation?
    
    
    init() {
    }
    
    func beginTracking(with image: CVPixelBuffer, boundingBox: CGRect) {
        let startObservation = VNDetectedObjectObservation(boundingBox: boundingBox)
        previousObservation = startObservation
        requestHandler = VNSequenceRequestHandler()
    }
    func updateTracking(with updatedImage: CVPixelBuffer, completion: @escaping ((CGRect) -> Void)) {
        guard let previousObservation = previousObservation else { return }
        
        let request = VNTrackObjectRequest(detectedObjectObservation: previousObservation) { request, error in
//            let translation = self.processRequestTranslation(request: request)
//            completion(translation)
            let rect = self.processRequestTranslation(request: request)
            completion(rect)
        }
        do {
            try requestHandler?.perform([request], on: updatedImage)
        } catch {
            print("Error performing request: \(error)")
        }
        
    }
    func processRequestTranslation(request: VNRequest) -> CGRect {
        guard
            let observations = request.results,
            let observation = observations.compactMap({ $0 as? VNDetectedObjectObservation }).first,
            let previousObservation = self.previousObservation
        else {
            self.previousObservation = nil
            return .zero
        }
        
//        let xDifference = observation.boundingBox.midX - previousObservation.boundingBox.midX
//        let yDifference = observation.boundingBox.midY - previousObservation.boundingBox.midY
        
        
        let boundingBox = observation.boundingBox
        self.previousObservation = observation
        return boundingBox
        
    }
//    func processRequestTranslation(request: VNRequest) -> CGSize {
//        guard
//            let observations = request.results,
//            let observation = observations.compactMap({ $0 as? VNDetectedObjectObservation }).first,
//            let previousObservation = self.previousObservation
//        else {
//            self.previousObservation = nil
//            return .zero
//        }
//
//        let xDifference = observation.boundingBox.midX - previousObservation.boundingBox.midX
//        let yDifference = observation.boundingBox.midY - previousObservation.boundingBox.midY
//
//        self.previousObservation = observation
//        return CGSize(width: xDifference, height: yDifference)
//
//    }
}
