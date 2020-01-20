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
            
            //print(data.gravity.z)
            //let asf = data.attitude.yaw
            //print("initAlt: \(attitude)")
            //print("attitude pitch: \(attitude.pitch)") ///IN RADIANS
            
            let rollValue = attitude.roll.radiansToDegrees
            let pitchValue = attitude.pitch.radiansToDegrees
            let yawValue = attitude.yaw.radiansToDegrees
            
            
            let xConversion = Double(8)
            let yConversion = Double(8)
            //let zConversion = Double(0.05)
            
            let finalRollDiff = (rollValue - motionXAsOfHighlightStart) * xConversion
            let finalPitchDiff = (pitchValue - motionYAsOfHighlightStart) * yConversion
            //let finalYawDiff = (yawValue - motionZAsOfHighlightStart) * zConversion
            
            //print("pitch difference: \(motionYAsOfHighlightStart - pitchValue)")
            //print(pitchValue)
            for highlight in currentComponents {
                //print("highlight")
                let theView = highlight.baseView
                          //  print("before frame \(index): \(theView?.frame)")
                            
//                let rect = CGRect(x: highlight.x + CGFloat(finalRoll), y: highlight.y + CGFloat(finalPitch), width: highlight.width, height: highlight.height)
//                theView?.frame = rect
                            theView?.frame.origin.x += CGFloat(finalRollDiff)
                            theView?.frame.origin.y += CGFloat(finalPitchDiff)
                            
           // theView?.transform = CGAffineTransform(rotationAngle: CGFloat(yawValue * zConversion))
                           // print("after frame \(index): \(theView?.frame)")
                            
            }
            
            
            
//            let xDiff = (data.gravity.x - (motionXAsOfHighlightStart ?? 0)) * xConversion
//           // let yDiff = (data.gravity.y - (self?.motionYAsOfHighlightStart ?? 0)) * yConversion
//    //                let zDiff = (data.gravity.z - (self?.motionZAsOfHighlightStart ?? 0)) * zConversion
//
//    //                let xDiff = ((self?.motionXAsOfHighlightStart ?? 0) - data.gravity.x) * xConversion
//            let yDiff = ((motionYAsOfHighlightStart ?? 0) - data.gravity.y) * yConversion
//            let zDiff = ((motionZAsOfHighlightStart ?? 0) - data.gravity.z) * zConversion
//
//            let newZRotationDiff =  atan2(data.gravity.x,
//            data.gravity.y) - .pi
//            numberLabel.transform = CGAffineTransform(rotationAngle: CGFloat(newZRotationDiff))
//            print(newZRotationDiff)
            motionXAsOfHighlightStart = rollValue
            motionYAsOfHighlightStart = pitchValue
            motionZAsOfHighlightStart = yawValue
            //print("motionY: \(motionYAsOfHighlightStart)_____________")
           // print("xdiff: \(xDiff)")
            
        }
    }
}
extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}
