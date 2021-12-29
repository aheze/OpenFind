//
//  CameraVC+Motion.swift
//  FindAppClip1
//
//  Created by Zheng on 3/18/21.
//

import CoreMotion
import UIKit

extension CameraViewController {
    func configureMotion() {
        motionManager.deviceMotionUpdateInterval = 0.01
        
        if let deviceMot = motionManager.deviceMotion?.attitude {
            initialAttitude = deviceMot
        }

        motionManager.startDeviceMotionUpdates(to: .main) {
            [weak self] data, error in
                if !CurrentState.currentlyPaused {
                    guard let data = data, error == nil else {
                        return
                    }
                    self?.updateHighlightOrientations(attitude: data.attitude)
                }
        }
    }

    func updateHighlightOrientations(attitude: CMAttitude) {
        if let initAttitude = initialAttitude {
            attitude.multiply(byInverseOf: initAttitude)
            let rollValue = attitude.roll.radiansToDegrees
            let pitchValue = attitude.pitch.radiansToDegrees
            let xConversion = Double(8)
            let yConversion = Double(8)
            let finalRollDiff = (rollValue - motionXAsOfHighlightStart) * xConversion
            let finalPitchDiff = (pitchValue - motionYAsOfHighlightStart) * yConversion
            
            for highlight in currentComponents {
                let baseView = highlight.baseView
                baseView?.frame.origin.x += CGFloat(finalRollDiff)
                baseView?.frame.origin.y += CGFloat(finalPitchDiff)
            }
            
            motionXAsOfHighlightStart = rollValue
            motionYAsOfHighlightStart = pitchValue
        }
    }
}
