//
//  UpdateOrientation.swift
//  Find
//
//  Created by Andrew on 1/19/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import CoreMotion

extension ViewController {
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
extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}
