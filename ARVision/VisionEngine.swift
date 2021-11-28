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
}
class VisionEngine {
    
    weak var delegate: VisionEngineDelegate?
    
    let trackingEngine = VisionTrackingEngine()
    let findingEnding = VisionFindingEngine()
    
    
    // MARK: Tracking
    /// not nil if tracking gave an updated rect
    
    var startTime: Date?
    var canFind: Bool {
        var canFind = true
        if findingEnding.startTime != nil {
            print("Currently finding")
            canFind = false
        }
        if !startTime.isPastCoolDown(Constants.findCoolDownTime) {
            print("Still in cooldown!")
            canFind = false
        }
        
        print("Can find? \(canFind)")
        return canFind
    }
    func startToFind(_ text: [String], in pixelBuffer: CVPixelBuffer) {
        startTime = Date()
        findingEnding.fastFind(text, in: pixelBuffer) { [weak self] observations in
            guard let self = self else { return }
            self.delegate?.textFound(observations: observations)
        }
        trackingEngine.beginTracking(with: pixelBuffer, boundingBox: Constants.defaultTrackingBoundingBox)
    }
    func updatePixelBuffer(_ pixelBuffer: CVPixelBuffer) {
        
        let startTime = startTime
        trackingEngine.updateTracking(with: pixelBuffer) { [weak self] translation in
//            print("reference: \(self?.referenceTrackingRect) vs \(rect)")
            
            guard
                let self = self,
                startTime == self.startTime
            else {
                print("start time diff.. \(startTime) vs before \(self?.startTime)")
                return
            }
            self.delegate?.cameraMoved(by: translation)
//            if let referenceTrackingRect = self.referenceTrackingRect {
//                let xDifference = rect.midX - referenceTrackingRect.midX
//                let yDifference = rect.midY - referenceTrackingRect.midY
//                self.delegate?.cameraMoved(by: CGSize(width: xDifference, height: yDifference))
//            } else {
//                self.referenceTrackingRect = rect
//            }
        }
    }
}
