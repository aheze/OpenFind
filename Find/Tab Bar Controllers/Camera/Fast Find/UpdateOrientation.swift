//
//  UpdateOrientation.swift
//  Find
//
//  Created by Andrew on 1/19/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import CoreMotion
import UIKit

extension CameraViewController {
    func updateHighlightOrientations(attitude: CMAttitude) {
        if let initAttitude = initialAttitude {
            attitude.multiply(byInverseOf: initAttitude)
            let rollValue = attitude.roll.radiansToDegrees
            let pitchValue = attitude.pitch.radiansToDegrees
            let yawValue = attitude.yaw.radiansToDegrees
            let xConversion = Double(8)
            let yConversion = Double(8)
            let finalRollDiff = (rollValue - motionXAsOfHighlightStart) * xConversion
            let finalPitchDiff = (pitchValue - motionYAsOfHighlightStart) * yConversion
            
            for highlight in currentComponents {
                let theView = highlight.baseView
                theView?.frame.origin.x += CGFloat(finalRollDiff)
                theView?.frame.origin.y += CGFloat(finalPitchDiff)
            }
            
            motionXAsOfHighlightStart = rollValue
            motionYAsOfHighlightStart = pitchValue
            motionZAsOfHighlightStart = yawValue
        }
    }
}

extension BinaryInteger {
    var degreesToRadians: CGFloat { CGFloat(self) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
}
