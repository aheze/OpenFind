//
//  VisionEngine.swift
//  ARVision
//
//  Created by Zheng on 11/25/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import Vision

protocol VisionEngineDelegate: AnyObject {
    func textFound(observations: [VNRecognizedTextObservation])
    func cameraMoved(by translation: CGSize)
    func drawTrackers(_ trackers: [Tracker])
}
class VisionEngine {
    
    weak var delegate: VisionEngineDelegate?
    
//    let trackingEngine = VisionTrackingEngine()
    let findingEnding = VisionFindingEngine()
    
    
    let visionSamplingEngine = VisionSamplingEngine()
    
    
    // MARK: Tracking
    /// not nil if tracking gave an updated rect
    
    var startTime: Date?
    var canFind: Bool {
        var canFind = true
        if findingEnding.startTime != nil {

            canFind = false
        }
        if !startTime.isPastCoolDown(VisionConstants.findCoolDownTime) {

            canFind = false
        }
        

        return canFind
    }
    
    func startToFind(_ text: [String], in pixelBuffer: CVPixelBuffer) {
        startTime = Date()
        visionSamplingEngine.start(in: CGRect(x: 0.4, y: 0.4, width: 0.2, height: 0.2))
//        findingEnding.fastFind(text, in: pixelBuffer) { [weak self] observations in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                self.delegate?.textFound(observations: observations)
//            }
//            self.trackingEngine.beginTracking(with: pixelBuffer, observations: observations)
//        }
//        trackingEngine.reportTrackerCount = { [weak self] numberOfTrackers in
//            if numberOfTrackers < VisionConstants.maxTrackers {
//                let trackersNeeded = VisionConstants.maxTrackers - numberOfTrackers
//            }
//        }
    }
    
    
    var canSample: Bool {
        var canSample = true
        if visionSamplingEngine.startTime != nil {

            canSample = false
        }
        if !visionSamplingEngine.startTime.isPastCoolDown(VisionConstants.findCoolDownTime) {

            canSample = false
        }
        

        return canSample
    }
    func updatePixelBuffer(_ pixelBuffer: CVPixelBuffer) {
        _ = VisionConstants.highlightCandidateAreas
        
//        let startTime = startTime
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.visionSamplingEngine.update(pixelBuffer: pixelBuffer, completion: { observations in
                
                if self?.canSample ?? false {
                    DispatchQueue.main.async {

                        self?.delegate?.textFound(observations: observations)
                    }
                }
            })
            
            
            
//            self?.trackingEngine.updateTracking(with: pixelBuffer) { trackers in
//                self?.delegate?.drawTrackers(trackers)
//                guard
//                    let self = self,
//                    startTime == self.startTime
//                else {
//                    return
//                }
//            }
        }
    }
}
