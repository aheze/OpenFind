//
//  VisionSamplingEngine.swift
//  ARVision
//
//  Created by Zheng on 11/30/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import Vision

class VisionSamplingEngine {
    var focusedBoundingBox = CGRect.zero
    func start(in boundingBox: CGRect) {
        focusedBoundingBox = boundingBox
    }
    
    var startTime: Date?
    func update(pixelBuffer: CVPixelBuffer, completion: @escaping (([VNRecognizedTextObservation]) -> Void)) {
        startTime = Date()
        let request = VNRecognizeTextRequest { request, _ in
            let observations = self.textFound(request: request)
            completion(observations)
            self.startTime = nil
        }
        
        request.revision = VNRecognizeTextRequestRevision1
        request.recognitionLevel = .fast
        request.regionOfInterest = focusedBoundingBox
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
        
        startTime = Date()
        do {
            try imageRequestHandler.perform([request])
        } catch {}
    }
}

extension VisionSamplingEngine {
    func textFound(request: VNRequest) -> [VNRecognizedTextObservation] {
        guard
            let results = request.results
        else {
            startTime = nil
            return []
        }
        
        let observations = results.compactMap { $0 as? VNRecognizedTextObservation }
        
//        for observation in observations {
//            observation.topCandidates(1)
//        }
        
        startTime = nil
        return observations
    }
}
